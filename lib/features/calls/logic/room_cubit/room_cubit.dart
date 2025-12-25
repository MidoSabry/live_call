import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../data/livekit/livekit_service.dart';
import 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  final LiveKitService _liveKit;
  StreamSubscription<RoomEvent>? _sub;

  RoomCubit(this._liveKit) : super(RoomState.idle());

  Future<void> join({required String wsUrl, required String token}) async {
    emit(state.copyWith(connecting: true, connected: false, error: null));

    try {
      await _liveKit.connect(wsUrl: wsUrl, token: token);

      // Listen to events (Mute/Unmute/Join/Leave) to refresh the participant list
      _sub?.cancel();
      _sub = _liveKit.roomEvents.listen((event) {
        emit(state.copyWith(participants: _liveKit.participantsSnapshot()));
      });

      emit(
        state.copyWith(
          connecting: false,
          connected: true,
          participants: _liveKit.participantsSnapshot(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          connecting: false,
          connected: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> leave() async {
    // 1. Stop listening to events immediately to prevent state updates during teardown
    await _sub?.cancel();
    _sub = null;

    try {
      // 2. Await the actual network disconnection
      await _liveKit.disconnect();
    } catch (e) {
      print("RoomCubit: Error during leave: $e");
    } finally {
      // 3. Force the state back to idle so BlocBuilder clears the participants
      emit(RoomState.idle());
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
