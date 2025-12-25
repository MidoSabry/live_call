import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

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
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    super.dispose();
  }

  void _onParticipantChanged() {
    final pubs = widget.participant.videoTrackPublications;
    final audioPubs = widget.participant.audioTrackPublications;

    TrackPublication? found;
    for (final pub in pubs) {
      if (pub.subscribed && pub.track is VideoTrack) {
        found = pub;
        break;
      }
    }

    // Check if muted
    final muted = audioPubs.isEmpty || audioPubs.first.muted;

    if (mounted) {
      setState(() {
        _videoPub = found;
        _isMuted = muted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = _videoPub?.track;
    final name = widget.participant.name.isNotEmpty
        ? widget.participant.name
        : widget.participant.identity;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 16),
      ),
      child: Stack(
        children: [
          // 1. Video or Avatar
          Positioned.fill(
            child: (track is VideoTrack && !(_videoPub?.muted ?? true))
                ? VideoTrackRenderer(
                    track,
                    fit: widget.isFullScreen
                        ? VideoViewFit.cover
                        : VideoViewFit.contain,
                  )
                : _buildAvatar(name),
          ),

          // 2. Mute Indicator (Top Right)
          if (_isMuted)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic_off,
                  color: Colors.redAccent,
                  size: 16,
                ),
              ),
            ),

          // 3. Name Tag (Bottom Left) - Hidden in Mini View
          if (!widget.isMiniView)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF434343), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: widget.isMiniView ? 24 : 40,
          backgroundColor: Colors.blueAccent.withOpacity(0.2),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMiniView ? 20 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
