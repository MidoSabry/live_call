import 'package:equatable/equatable.dart';
import 'package:livekit_client/livekit_client.dart';

class RoomState extends Equatable {
  final bool connecting;
  final bool connected;
  final String? error;
  final List<Participant> participants;

  const RoomState({
    required this.connecting,
    required this.connected,
    required this.participants,
    this.error,
  });

  factory RoomState.idle() => const RoomState(
        connecting: false,
        connected: false,
        participants: [],
      );

  RoomState copyWith({
    bool? connecting,
    bool? connected,
    String? error,
    List<Participant>? participants,
  }) {
    return RoomState(
      connecting: connecting ?? this.connecting,
      connected: connected ?? this.connected,
      participants: participants ?? this.participants,
      error: error,
    );
  }

  @override
  List<Object?> get props => [connecting, connected, error, participants];
}
