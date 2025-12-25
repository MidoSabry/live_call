import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../logic/media_cubit/media_cubit.dart';
import '../../logic/media_cubit/media_state.dart';
import '../../logic/room_cubit/room_cubit.dart';
import '../../logic/room_cubit/room_state.dart';
import '../widgets/controller_button.dart';
import '../widgets/participant_tile.dart';

class CallRoomScreen extends StatefulWidget {
  static const routeName = '/call-room';
  const CallRoomScreen({super.key});

  @override
  State<CallRoomScreen> createState() => _CallRoomScreenState();
}

class _CallRoomScreenState extends State<CallRoomScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MediaCubit>().startTimer();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Participant Video Grid
          BlocBuilder<RoomCubit, RoomState>(
            builder: (context, state) {
              final p = state.participants;
              return p.length <= 2
                  ? _buildMessengerLayout(p)
                  : _buildGridLayout(p);
            },
          ),

          // 2. Top Bar Timer
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: BlocBuilder<MediaCubit, MediaState>(
              builder: (context, state) => Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Control Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildControlBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
        ),
      ),
      child: BlocBuilder<MediaCubit, MediaState>(
        builder: (context, state) {
          final media = context.read<MediaCubit>();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RoomControlButton(
                icon: state.micEnabled ? Icons.mic : Icons.mic_off,
                label: "Mic",
                isActive: state.micEnabled,
                onTap: media.toggleMic,
              ),
              RoomControlButton(
                icon: state.cameraEnabled ? Icons.videocam : Icons.videocam_off,
                label: "Video",
                isActive: state.cameraEnabled,
                onTap: media.toggleCamera,
              ),
              RoomControlButton(
                icon: state.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                label: "Speaker",
                isActive: state.isSpeakerOn,
                isSpeaker: true, // This enables the icon growth
                onTap: media.toggleSpeaker,
              ),
              RoomControlButton(
                icon: Icons.call_end,
                label: "End",
                isDestructive: true,
                onTap: () {
                  media.stopTimer();
                  context.read<RoomCubit>().leave();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessengerLayout(List<Participant> p) {
    if (p.isEmpty) return const SizedBox();
    final local = p.firstWhere(
      (e) => e is LocalParticipant,
      orElse: () => p.first,
    );
    final remote = p.firstWhere(
      (e) => e is! LocalParticipant,
      orElse: () => local,
    );
    return Stack(
      children: [
        Positioned.fill(
          child: ParticipantTile(participant: remote, isFullScreen: true),
        ),
        if (p.length > 1)
          Positioned(
            top: 110,
            right: 20,
            child: SizedBox(
              width: 120,
              height: 180,
              child: ParticipantTile(participant: local, isMiniView: true),
            ),
          ),
      ],
    );
  }

  Widget _buildGridLayout(List<Participant> p) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 120, 16, 150),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
    ),
    itemCount: p.length,
    itemBuilder: (context, i) => ParticipantTile(participant: p[i]),
  );
}
