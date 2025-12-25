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
  final _wsUrl = TextEditingController(text: 'ws://10.30.20.74:7880');
  final _token = TextEditingController();

  @override
  void dispose() {
    _wsUrl.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Colors.blueAccent.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Welcome back,",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const Text(
                    "Join a Meeting",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildInputLabel("Server URL"),
                  _buildTextField(
                    _wsUrl,
                    "ws://10.0.0.1:7880",
                    Icons.lan_outlined,
                  ),

                  const SizedBox(height: 24),

                  _buildInputLabel("Access Token"),
                  _buildTextField(
                    _token,
                    "Paste security token...",
                    Icons.vpn_key_outlined,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 40),

                  BlocConsumer<RoomCubit, RoomState>(
                    listener: (context, state) {
                      if (state.connected) {
                        Navigator.pushNamed(context, CallRoomScreen.routeName);
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildJoinButton(state),
                          if (state.error != null)
                            _buildErrorCard(state.error!),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  const Center(
                    child: Text(
                      "LiveKit End-to-End Encryption Enabled",
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildJoinButton(RoomState state) {
    bool isConnecting = state.connecting;
    return GestureDetector(
      onTap: isConnecting
          ? null
          : () {
              FocusManager.instance.primaryFocus?.unfocus();
              context.read<RoomCubit>().join(
                wsUrl: _wsUrl.text,
                token: _token.text,
              );
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          color: isConnecting ? Colors.white10 : Colors.blueAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isConnecting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Join Meeting",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) => Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.redAccent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            error,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
