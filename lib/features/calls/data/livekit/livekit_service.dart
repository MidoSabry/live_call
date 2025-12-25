import 'dart:async';
import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  bool _isSpeakerOn = true;

  Room? get room => _room;
  bool get isSpeakerOn => _isSpeakerOn;

  final _roomEventsController = StreamController<RoomEvent>.broadcast();
  Stream<RoomEvent> get roomEvents => _roomEventsController.stream;

  Future<Room> connect({required String wsUrl, required String token}) async {
    await disconnect();

    _room = Room(
      roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
    );

    await _room!.prepareConnection(wsUrl, token);
    await _room!.connect(wsUrl, token);

    // ✅ Set initial state to FALSE (OFF)
    await _room!.localParticipant?.setCameraEnabled(false);
    await _room!.localParticipant?.setMicrophoneEnabled(false);

    _listener = _room!.createListener()
      ..on<TrackMutedEvent>((event) => _roomEventsController.add(event))
      ..on<TrackUnmutedEvent>((event) => _roomEventsController.add(event))
      ..on<ParticipantConnectedEvent>(
        (event) => _roomEventsController.add(event),
      )
      ..on<ParticipantDisconnectedEvent>(
        (event) => _roomEventsController.add(event),
      );

    await Hardware.instance.setSpeakerphoneOn(_isSpeakerOn);
    return _room!;
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await Hardware.instance.setSpeakerphoneOn(_isSpeakerOn);
  }

  Future<void> switchCamera() async {
    final track =
        _room?.localParticipant?.videoTrackPublications.firstOrNull?.track;
    if (track is LocalVideoTrack) {
      final isFront =
          track.mediaStreamTrack.getSettings()['facingMode'] == 'user';
      await track.restartTrack(
        CameraCaptureOptions(
          cameraPosition: isFront ? CameraPosition.back : CameraPosition.front,
          params: VideoParametersPresets.h720_169,
        ),
      );
    }
  }

  Future<void> setCameraEnabled(bool enabled) async =>
      _room?.localParticipant?.setCameraEnabled(enabled);
  Future<void> setMicrophoneEnabled(bool enabled) async =>
      _room?.localParticipant?.setMicrophoneEnabled(enabled);

  Future<void> disconnect() async {
    try {
      await _listener?.dispose();
      _listener = null;

      if (_room != null) {
        // This is the critical part that actually stops the WebRTC stream
        await _room!.disconnect();
        await _room!.dispose(); // Clean up resources
        _room = null;
      }

      // Notify listeners that the room is gone
      _roomEventsController.add(
        RoomDisconnectedEvent(reason: DisconnectReason.unknown),
      );
    } catch (e) {
      print("Error during LiveKit disconnect: $e");
    }
  }

  List<Participant> participantsSnapshot() => [
    if (_room?.localParticipant != null) _room!.localParticipant!,
    ..._room?.remoteParticipants.values ?? [],
  ];
}
