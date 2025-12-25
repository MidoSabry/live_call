import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../logic/media_cubit/media_cubit.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;
  final bool isMiniView;
  final bool isFullScreen;

  const ParticipantTile({
    super.key,
    required this.participant,
    this.isMiniView = false,
    this.isFullScreen = false,
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  TrackPublication? _videoPub;
  bool _isMuted = true;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_updateState);
    _updateState();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (!mounted) return;
    setState(() {
      _isMuted = widget.participant.isMuted;
      _isSpeaking = widget.participant.isSpeaking;
      final pubs = widget.participant.videoTrackPublications;
      _videoPub = pubs
          .where((p) => p.subscribed && !p.muted && p.track is VideoTrack)
          .firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = _videoPub?.track;
    final name = widget.participant.name.isNotEmpty
        ? widget.participant.name
        : "User";

    return GestureDetector(
      onDoubleTap: () {
        if (widget.participant is LocalParticipant) {
          context.read<MediaCubit>().switchCamera();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 24),
          border: Border.all(
            color: _isSpeaking ? Colors.greenAccent : Colors.white10,
            width: _isSpeaking ? 3 : 1,
          ),
          boxShadow: [
            if (_isSpeaking)
              BoxShadow(
                color: Colors.greenAccent.withValues(alpha: 0.2),
                blurRadius: 15,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 22),
          child: Stack(
            children: [
              Positioned.fill(
                child: (track is VideoTrack)
                    ? VideoTrackRenderer(track, fit: VideoViewFit.cover)
                    : _buildAvatar(name),
              ),
              // ✅ Red Mute Badge
              if (_isMuted)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_off_rounded,
                      color: Colors.red,
                      size: 14,
                    ),
                  ),
                ),
              if (!widget.isMiniView)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
      child: Center(
        child: CircleAvatar(
          radius: widget.isMiniView ? 24 : 40,
          backgroundColor: Colors.white10,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
