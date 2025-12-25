import 'package:livekit_client/livekit_client.dart';

class RoomState {
  final bool connecting;
  final bool connected;
  final List<Participant> participants;
  final String? error;

  RoomState({
    required this.connecting,
    required this.connected,
    required this.participants,
    this.error,
  });

  factory RoomState.idle() =>
      RoomState(connecting: false, connected: false, participants: []);

  RoomState copyWith({
    bool? connecting,
    bool? connected,
    List<Participant>? participants,
    String? error,
  }) {
    return RoomState(
      connecting: connecting ?? this.connecting,
      connected: connected ?? this.connected,
      participants: participants ?? this.participants,
      error: error,
    );
  }
}
