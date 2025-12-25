import 'dart:async';

import 'package:livekit_client/livekit_client.dart';

/// Single place to talk to LiveKit SDK.
/// UI should NOT call LiveKit directly; use Cubits instead.
class LiveKitService {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  Room? get room => _room;

  final _roomEventsController = StreamController<RoomEvent>.broadcast();
  Stream<RoomEvent> get roomEvents => _roomEventsController.stream;

  Future<Room> connect({required String wsUrl, required String token}) async {
    // Create a fresh room each connection (simpler for starter).
    await disconnect();

    final roomOptions = const RoomOptions(adaptiveStream: true, dynacast: true);

    final room = Room();

    // Optional: speed up connection
    await room.prepareConnection(wsUrl, token);

    await room.connect(wsUrl, token, roomOptions: roomOptions);

    _room = room;

    // Listen to room events to update cubits/UI.
    _listener = room.createListener()
      ..on<RoomDisconnectedEvent>((event) {
        _roomEventsController.add(event);
      })
      ..on<ParticipantConnectedEvent>((event) {
        _roomEventsController.add(event);
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        _roomEventsController.add(event);
      })
      ..on<TrackSubscribedEvent>((event) {
        _roomEventsController.add(event);
      })
      ..on<TrackUnsubscribedEvent>((event) {
        _roomEventsController.add(event);
      });

    return room;
  }

  Future<void> disconnect() async {
    _listener?.dispose();
    _listener = null;

    final room = _room;
    _room = null;

    if (room != null) {
      try {
        await room.disconnect();
      } catch (_) {}
    }
  }

  // ---- Media helpers ----
  Future<void> setCameraEnabled(bool enabled) async {
    final room = _room;
    if (room == null) return;
    await room.localParticipant?.setCameraEnabled(enabled);
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    final room = _room;
    if (room == null) return;
    await room.localParticipant?.setMicrophoneEnabled(enabled);
  }

  Future<void> switchCamera() async {
    final room = _room;
    if (room == null) return;

    // هات كاميرات الجهاز
    final inputs = await Hardware.instance.videoInputs();
    if (inputs.length < 2) return;

    // الكاميرا الحالية (لو LiveKit عارفها)
    final currentId = Hardware.instance.selectedVideoInput?.deviceId;

    // اختار كاميرا مختلفة (عادة أمامي/خلفي)
    final nextDevice = inputs.firstWhere(
      (d) => d.deviceId != currentId,
      orElse: () => inputs.first,
    );

    // هات LocalVideoTrack الحالي
    LocalVideoTrack? localTrack;
    final pubs = room.localParticipant?.videoTrackPublications ?? const [];
    for (final pub in pubs) {
      final t = pub.track;
      if (t is LocalVideoTrack) {
        localTrack = t;
        break;
      }
    }
    if (localTrack == null) return;

    // ✅ switchCamera محتاجة deviceId
    await localTrack.switchCamera(nextDevice.deviceId);

    // (اختياري) حدّث اختيار الهاردوير الحالي
    Hardware.instance.selectedVideoInput = nextDevice;
  }

  List<Participant> participantsSnapshot() {
    final room = _room;
    if (room == null) return [];
    final result = <Participant>[];
    if (room.localParticipant != null) result.add(room.localParticipant!);
    result.addAll(room.remoteParticipants.values);
    return result;
  }

  void dispose() {
    _listener?.dispose();
    _roomEventsController.close();
  }
}
