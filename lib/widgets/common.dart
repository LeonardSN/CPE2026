import 'package:flutter/material.dart';

import '../logic/sound.dart';
import '../theme.dart';

export 'math_text.dart';

/// Bouton « 3D » façon jeu mobile, avec un rebord en bas.
/// Sans couleur précisée, il prend la couleur principale du thème du cycle.
class ChunkyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? shadowColor;
  final Color? textColor;
  final double height;

  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.shadowColor,
    this.textColor,
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
    final base = widget.color ?? context.colors.primary;
    final color = enabled ? base : (context.isDark ? const Color(0xFF444444) : AppColors.grey);
    final shadow = enabled
        ? (widget.shadowColor ?? darker(base))
        : (context.isDark ? const Color(0xFF333333) : AppColors.greyDark);
    final textColor = enabled ? (widget.textColor ?? onColor(base)) : AppColors.greyDark;
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

/// L'image de la mascotte (le chat Mathou).
class MascotImage extends StatelessWidget {
  final double size;

  const MascotImage({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppInfo.mascotImage, width: size, height: size, fit: BoxFit.contain);
  }
}

/// Le logo « Mathou » : le nom en Nunito avec le petit sourire orange.
class MathouLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;

  const MathouLogo({super.key, this.fontSize = 44, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (context.isDark ? Colors.white : Brand.navy);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppInfo.appName,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
            color: c,
            height: 1,
          ),
        ),
        SizedBox(
          width: fontSize * 2.2,
          height: fontSize * 0.35,
          child: CustomPaint(painter: _SmilePainter()),
        ),
      ],
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Brand.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.28
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..quadraticBezierTo(size.width / 2, size.height * 1.1, size.width * 0.9, size.height * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        MascotImage(size: size),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.card,
              border: Border.all(color: context.colors.outline, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              style: AppText.body.copyWith(fontSize: 15),
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
  final Color? color;
  final double height;

  const RoundedProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: context.colors.outline),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: color ?? context.colors.primary,
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

/// Carte arrondie qui suit le thème (clair / sombre).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor ?? context.colors.outline, width: 2),
      ),
      child: child,
    );
  }
}
