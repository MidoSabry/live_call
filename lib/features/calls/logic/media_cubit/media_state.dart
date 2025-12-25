import 'package:equatable/equatable.dart';

class MediaState extends Equatable {
  final bool micEnabled;
  final bool cameraEnabled;

  const MediaState({
    required this.micEnabled,
    required this.cameraEnabled,
  });

  factory MediaState.initial() => const MediaState(
        micEnabled: true,
        cameraEnabled: true,
      );

  MediaState copyWith({
    bool? micEnabled,
    bool? cameraEnabled,
  }) {
    return MediaState(
      micEnabled: micEnabled ?? this.micEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
    );
  }

  @override
  List<Object?> get props => [micEnabled, cameraEnabled];
}
