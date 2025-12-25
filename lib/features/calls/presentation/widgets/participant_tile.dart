import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;

  const ParticipantTile({super.key, required this.participant});

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  TrackPublication? _videoPub;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void didUpdateWidget(covariant ParticipantTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.participant != widget.participant) {
      oldWidget.participant.removeListener(_onParticipantChanged);
      widget.participant.addListener(_onParticipantChanged);
      _onParticipantChanged();
    }
  }

  void _onParticipantChanged() {
    // Pick the first subscribed video track
    final pubs = widget.participant.videoTrackPublications;
    TrackPublication? found;
    for (final pub in pubs) {
      if (pub.subscribed && pub.track is VideoTrack) {
        found = pub;
        break;
      }
    }
    setState(() => _videoPub = found);
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identity = widget.participant.identity;
    final name = widget.participant.name;

    final track = _videoPub?.track;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black12,
        child: Stack(
          children: [
            Positioned.fill(
              child: track is VideoTrack
                  ? VideoTrackRenderer(track)
                  : const Center(child: Icon(Icons.person, size: 64)),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  name.isNotEmpty ? name : identity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
