import 'package:get_it/get_it.dart';

import '../../features/calls/data/livekit/livekit_service.dart';
import '../../features/calls/logic/media_cubit/media_cubit.dart';
import '../../features/calls/logic/room_cubit/room_cubit.dart';
import '../../features/calls/logic/call_invite_cubit/call_invite_cubit.dart';

final sl = GetIt.I;

void configureDependencies() {
  // Services
  sl.registerLazySingleton<LiveKitService>(() => LiveKitService());

  // Cubits
  sl.registerFactory<RoomCubit>(() => RoomCubit(sl<LiveKitService>()));
  sl.registerFactory<MediaCubit>(() => MediaCubit(sl<LiveKitService>()));
  sl.registerFactory<CallInviteCubit>(() => CallInviteCubit());
}
