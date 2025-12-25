import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'features/calls/logic/media_cubit/media_cubit.dart';
import 'features/calls/logic/room_cubit/room_cubit.dart';
import 'features/calls/presentation/screens/join_room_screen.dart';
import 'features/calls/presentation/screens/call_room_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lockdown orientations if desired, or keep flexible
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // These will now be available globally
        BlocProvider<RoomCubit>(create: (_) => sl<RoomCubit>()),
        BlocProvider<MediaCubit>(create: (_) => sl<MediaCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LiveKit Calls',
        theme: ThemeData(
          brightness: Brightness.dark, // Better for Video Call apps
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const JoinRoomScreen(),
          CallRoomScreen.routeName: (_) => const CallRoomScreen(),
        },
      ),
    );
  }
}
