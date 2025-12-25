import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../logic/media_cubit/media_cubit.dart';
import '../../logic/media_cubit/media_state.dart';
import '../../logic/room_cubit/room_cubit.dart';
import '../../logic/room_cubit/room_state.dart';
import '../widgets/participant_tile.dart';

class CallRoomScreen extends StatelessWidget {
  static const routeName = '/call-room';

  const CallRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomCubit = context.read<RoomCubit>();
    final mediaCubit = context.read<MediaCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Room'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await roomCubit.leave();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<RoomCubit, RoomState>(
              builder: (context, state) {
                if (!state.connected) {
                  return const Center(child: Text('Not connected'));
                }
                final participants = state.participants;

                if (participants.isEmpty) {
                  return const Center(child: Text('Waiting for participants...'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: participants.length,
                  itemBuilder: (_, i) => ParticipantTile(participant: participants[i]),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: BlocBuilder<MediaCubit, MediaState>(
              builder: (context, media) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: media.micEnabled ? 'Mute' : 'Unmute',
                      icon: Icon(media.micEnabled ? Icons.mic : Icons.mic_off),
                      onPressed: () => mediaCubit.toggleMic(),
                    ),
                    IconButton(
                      tooltip: media.cameraEnabled ? 'Video off' : 'Video on',
                      icon: Icon(media.cameraEnabled ? Icons.videocam : Icons.videocam_off),
                      onPressed: () => mediaCubit.toggleCamera(),
                    ),
                    IconButton(
                      tooltip: 'Switch camera',
                      icon: const Icon(Icons.cameraswitch),
                      onPressed: () => mediaCubit.switchCamera(),
                    ),
                    IconButton(
                      tooltip: 'End',
                      icon: const Icon(Icons.call_end),
                      onPressed: () async {
                        await roomCubit.leave();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
