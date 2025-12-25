import 'package:flutter/material.dart';

class RoomControlButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final bool isActive;
  final bool isDestructive;
  final String label;
  final bool isSpeaker; // Added to trigger the growth effect

  const RoomControlButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    this.isActive = true,
    this.isDestructive = false,
    this.isSpeaker = false,
  });

  @override
  Widget build(BuildContext context) {
    // Red color for destructive (End Call) or inactive (Muted/Cam Off)
    final Color backgroundColor = isDestructive
        ? Colors.redAccent
        : (isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.redAccent.withValues(alpha: 0.2));

    final Color borderColor = isActive
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.redAccent.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              // Grows the icon specifically for the active speaker
              scale: (isSpeaker && isActive) ? 1.3 : 1.0,
              curve: Curves.easeOutBack,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
