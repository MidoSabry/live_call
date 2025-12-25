import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/livekit/livekit_service.dart';
import 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  MediaCubit(this._liveKit) : super(MediaState.initial());

  final LiveKitService _liveKit;

  Future<void> toggleMic() async {
    final next = !state.micEnabled;
    await _liveKit.setMicrophoneEnabled(next);
    emit(state.copyWith(micEnabled: next));
  }

  Future<void> toggleCamera() async {
    final next = !state.cameraEnabled;
    await _liveKit.setCameraEnabled(next);
    emit(state.copyWith(cameraEnabled: next));
  }

  Future<void> switchCamera() async {
    await _liveKit.switchCamera();
  }
}
