import 'package:flutter_bloc/flutter_bloc.dart';

import 'call_invite_state.dart';

/// Stub Cubit.
/// لاحقًا هتوصل هنا signaling (backend minimal) عشان:
/// start call -> ringing -> accept/reject -> create/join room.
class CallInviteCubit extends Cubit<CallInviteState> {
  CallInviteCubit() : super(CallInviteState.idle());

  void reset() => emit(CallInviteState.idle());
}
