import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'features/calls/logic/media_cubit/media_cubit.dart';
import 'features/calls/logic/room_cubit/room_cubit.dart';
import 'features/calls/presentation/screens/join_room_screen.dart';
import 'features/calls/presentation/screens/call_room_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RoomCubit>(create: (_) => sl<RoomCubit>()),
        BlocProvider<MediaCubit>(create: (_) => sl<MediaCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LiveKit Calls Starter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const JoinRoomScreen(),
          CallRoomScreen.routeName: (_) => const CallRoomScreen(),
        },
      ),
    );
  }
}
