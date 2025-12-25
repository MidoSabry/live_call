import 'package:equatable/equatable.dart';

enum CallType { audio, video }

enum CallStatus { idle, ringing, accepted, rejected, ended }

class CallSession extends Equatable {
  final String callId;
  final String roomName;
  final String callerId;
  final String calleeId;
  final CallType type;
  final CallStatus status;

  const CallSession({
    required this.callId,
    required this.roomName,
    required this.callerId,
    required this.calleeId,
    required this.type,
    required this.status,
  });

  @override
  List<Object?> get props => [callId, roomName, callerId, calleeId, type, status];
}
