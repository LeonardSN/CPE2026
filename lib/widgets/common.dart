import 'package:flutter/material.dart';

import '../logic/sound.dart';
import '../theme.dart';

/// Bouton « 3D » façon jeu mobile, avec un rebord en bas.
class ChunkyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final double height;

  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.green,
    this.shadowColor = AppColors.greenDark,
    this.textColor = Colors.white,
    this.height = 56,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = enabled ? widget.color : AppColors.grey;
    final shadow = enabled ? widget.shadowColor : AppColors.greyDark;
    final textColor = enabled ? widget.textColor : AppColors.greyDark;
    const depth = 5.0;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: enabled
          ? (_) {
              setState(() => _down = false);
              Sfx.play(Sound.tap, volume: 0.6);
              widget.onPressed!();
            }
          : null,
      child: SizedBox(
        height: widget.height + depth,
        child: Stack(
          children: [
            Positioned.fill(
              top: depth,
              child: Container(
                decoration: BoxDecoration(
                  color: shadow,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              left: 0,
              right: 0,
              top: _down ? depth : 0,
              height: widget.height,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La mascotte avec une bulle de dialogue.
class Mascot extends StatelessWidget {
  final String message;
  final double size;

  const Mascot({super.key, required this.message, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(AppInfo.mascotEmoji, style: TextStyle(fontSize: size)),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Barre de progression arrondie.
class RoundedProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const RoundedProgress({
    super.key,
    required this.value,
    this.color = AppColors.green,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: AppColors.grey),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Petite pastille (XP, série, cœurs...).
class StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;

  const StatChip({
    super.key,
    required this.emoji,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
