import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/livekit/livekit_service.dart';
import 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  final LiveKitService _liveKit;
  Timer? _timer;

  MediaCubit(this._liveKit)
    : super(
        MediaState(
          micEnabled: false, // Initial state OFF
          cameraEnabled: false, // Initial state OFF
          isSpeakerOn: true,
          duration: Duration.zero,
        ),
      );

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(dur: state.duration + const Duration(seconds: 1)));
    });
  }

  void stopTimer() {
    _timer?.cancel();
    emit(state.copyWith(dur: Duration.zero));
  }

  void toggleMic() {
    final newValue = !state.micEnabled;
    _liveKit.setMicrophoneEnabled(newValue);
    emit(state.copyWith(mic: newValue));
  }

  void toggleCamera() {
    final newValue = !state.cameraEnabled;
    _liveKit.setCameraEnabled(newValue);
    emit(state.copyWith(cam: newValue));
  }

  void toggleSpeaker() {
    _liveKit.toggleSpeaker();
    emit(state.copyWith(speaker: _liveKit.isSpeakerOn));
  }

  void switchCamera() => _liveKit.switchCamera();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
