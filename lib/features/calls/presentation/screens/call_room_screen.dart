import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../logic/media_cubit/media_cubit.dart';
import '../../logic/media_cubit/media_state.dart';
import '../../logic/room_cubit/room_cubit.dart';
import '../../logic/room_cubit/room_state.dart';
import '../widgets/controller_button.dart';
import '../widgets/participant_tile.dart';

class CallRoomScreen extends StatelessWidget {
  static const routeName = '/call-room';

  const CallRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomCubit = context.read<RoomCubit>();
    final mediaCubit = context.read<MediaCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // True deep black
      extendBody: true, // Allows content to flow under the navigation bar
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (!state.connected) {
            return _buildLoadingState();
          }

          final participants = state.participants;

          return Stack(
            children: [
              // 1. Dynamic Video Content Area
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: participants.length <= 2
                      ? _buildMessengerLayout(participants)
                      : _buildGridLayout(participants),
                ),
              ),

              // 2. Custom App Bar Overlay
              _buildTopOverlay(context, roomCubit),

              // 3. Bottom Controls with Gradient Fade
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomControls(mediaCubit, roomCubit),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          Text(
            "Connecting to Secure Room...",
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(BuildContext context, RoomCubit cubit) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () =>
                  cubit.leave().then((_) => Navigator.pop(context)),
            ),
            const Expanded(
              child: Text(
                "End-to-End Encrypted",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 48), // Spacer for balance
          ],
        ),
      ),
    );
  }

  Widget _buildMessengerLayout(List<Participant> participants) {
    final local = participants.firstWhere(
      (p) => p is LocalParticipant,
      orElse: () => participants.first,
    );
    final remote = participants.firstWhere(
      (p) => p is! LocalParticipant,
      orElse: () => local,
    );

    return Stack(
      key: const ValueKey('messenger_view'),
      children: [
        Positioned.fill(
          child: ParticipantTile(participant: remote, isFullScreen: true),
        ),
        if (participants.length > 1)
          Positioned(
            top: 110,
            right: 16,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ParticipantTile(participant: local, isMiniView: true),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGridLayout(List<Participant> participants) {
    return GridView.builder(
      key: const ValueKey('grid_view'),
      padding: const EdgeInsets.fromLTRB(12, 110, 12, 150),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) =>
          ParticipantTile(participant: participants[index]),
    );
  }

  Widget _buildBottomControls(MediaCubit mediaCubit, RoomCubit roomCubit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.9), Colors.transparent],
        ),
      ),
      child: BlocBuilder<MediaCubit, MediaState>(
        builder: (context, media) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoomControlButton(
                label: "Mute",
                isActive: media.micEnabled,
                icon: media.micEnabled
                    ? Icons.mic_rounded
                    : Icons.mic_off_rounded,
                onTap: () => mediaCubit.toggleMic(),
              ),
              RoomControlButton(
                label: "Video",
                isActive: media.cameraEnabled,
                icon: media.cameraEnabled
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                onTap: () => mediaCubit.toggleCamera(),
              ),
              RoomControlButton(
                label: "Flip",
                icon: Icons.flip_camera_ios_rounded,
                onTap: () => mediaCubit.switchCamera(),
              ),
              RoomControlButton(
                label: "End Call",
                isDestructive: true,
                icon: Icons.call_end_rounded,
                onTap: () => roomCubit.leave(),
              ),
            ],
          );
        },
      ),
    );
  }
}
