import 'package:equatable/equatable.dart';

class MediaState {
  final bool micEnabled;
  final bool cameraEnabled;
  final bool isSpeakerOn;
  final Duration duration;

  MediaState({
    required this.micEnabled,
    required this.cameraEnabled,
    required this.isSpeakerOn,
    required this.duration,
  });

  MediaState copyWith({bool? mic, bool? cam, bool? speaker, Duration? dur}) {
    return MediaState(
      micEnabled: mic ?? micEnabled,
      cameraEnabled: cam ?? cameraEnabled,
      isSpeakerOn: speaker ?? isSpeakerOn,
      duration: dur ?? duration,
    );
  }
}
