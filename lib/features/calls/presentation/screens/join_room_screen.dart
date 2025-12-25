import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/room_cubit/room_cubit.dart';
import '../../logic/room_cubit/room_state.dart';
import 'call_room_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _wsUrl = TextEditingController(text: 'ws://192.168.1.20:7880');
  final _token = TextEditingController();

  @override
  void dispose() {
    _wsUrl.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomCubit = context.read<RoomCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Join Room (Dev Test)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _wsUrl,
              decoration: const InputDecoration(
                labelText: 'LiveKit wsUrl',
                hintText: 'ws://<LAN-IP>:7880',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _token,
              decoration: const InputDecoration(
                labelText: 'Token',
                hintText: 'Paste token from LiveKit CLI',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            BlocConsumer<RoomCubit, RoomState>(
              listener: (context, state) {
                // When connected, navigate to call screen
                if (state.connected == true) {
                  Navigator.pushNamed(context, CallRoomScreen.routeName);
                }
              },
              builder: (context, state) {
                final connecting = state.connecting == true;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: connecting
                          ? null
                          : () async {
                              await roomCubit.join(
                                wsUrl: _wsUrl.text.trim(),
                                token: _token.text.trim(),
                              );
                            },
                      child: Text(connecting ? 'Connecting...' : 'Join'),
                    ),
                    const SizedBox(height: 8),
                    if (state.error != null)
                      Text(
                        state.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                );
              },
            ),
            const Spacer(),
            const Text(
              'Note: This screen is for dev testing.Later you will replace it with Contacts + Call flow.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
