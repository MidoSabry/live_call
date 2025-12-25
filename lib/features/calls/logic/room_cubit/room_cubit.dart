import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../data/livekit/livekit_service.dart';
import 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit(this._liveKit) : super(RoomState.idle());

  final LiveKitService _liveKit;

  StreamSubscription<RoomEvent>? _sub;

  Future<void> join({
    required String wsUrl,
    required String token,
  }) async {
    emit(state.copyWith(connecting: true, connected: false, error: null));

    try {
      await _liveKit.connect(wsUrl: wsUrl, token: token);

      _sub?.cancel();
      _sub = _liveKit.roomEvents.listen((_) {
        // Any relevant event: update participants snapshot
        emit(state.copyWith(participants: _liveKit.participantsSnapshot()));
      });

      emit(state.copyWith(
        connecting: false,
        connected: true,
        participants: _liveKit.participantsSnapshot(),
      ));
    } catch (e) {
      emit(state.copyWith(
        connecting: false,
        connected: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> leave() async {
    await _sub?.cancel();
    _sub = null;

    await _liveKit.disconnect();

    emit(RoomState.idle());
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
