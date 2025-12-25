import 'package:equatable/equatable.dart';

enum CallInviteStatus { idle, outgoingRinging, incomingRinging, accepted, rejected, ended }

class CallInviteState extends Equatable {
  final CallInviteStatus status;
  final String? error;

  const CallInviteState({required this.status, this.error});

  factory CallInviteState.idle() => const CallInviteState(status: CallInviteStatus.idle);

  CallInviteState copyWith({CallInviteStatus? status, String? error}) {
    return CallInviteState(status: status ?? this.status, error: error);
  }

  @override
  List<Object?> get props => [status, error];
}
