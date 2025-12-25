import 'package:flutter/material.dart';

class RoomControlButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final bool isActive;
  final bool isDestructive;
  final String label;

  const RoomControlButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    this.isActive = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive
        ? Colors.redAccent
        : (isActive
              ? Colors.white.withOpacity(0.15)
              : Colors.redAccent.withOpacity(0.2));

    final Color iconColor = isDestructive || !isActive
        ? Colors.white
        : Colors.white;

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
              color: color,
              border: Border.all(
                color: isActive
                    ? Colors.white10
                    : Colors.redAccent.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
