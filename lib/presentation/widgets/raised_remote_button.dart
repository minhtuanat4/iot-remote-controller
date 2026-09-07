import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Raised 3D remote button with press animation (border/shadow).
class RaisedRemoteButton extends StatefulWidget {
  const RaisedRemoteButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.size = 56,
    this.color,
    this.enabled = true,
  });

  final VoidCallback onPressed;
  final Widget? child;
  final String? label;
  final IconData? icon;
  final double size;
  final Color? color;
  final bool enabled;

  @override
  State<RaisedRemoteButton> createState() => _RaisedRemoteButtonState();
}

class _RaisedRemoteButtonState extends State<RaisedRemoteButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (!widget.enabled) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final face = widget.color ?? AppTheme.buttonFace;
    final depth = _pressed ? 1.0 : 5.0;
    final offset = _pressed ? 1.0 : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) {
            _setPressed(false);
            if (widget.enabled) {
              HapticFeedback.lightImpact();
              widget.onPressed();
            }
          },
          onTapCancel: () => _setPressed(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            transform: Matrix4.translationValues(0, offset, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size / 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(face, Colors.white, 0.12)!,
                  face,
                  Color.lerp(face, Colors.black, 0.25)!,
                ],
              ),
              border: Border.all(
                color: _pressed
                    ? AppTheme.accent.withValues(alpha: 0.8)
                    : AppTheme.buttonEdge,
                width: _pressed ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  offset: Offset(0, depth),
                  blurRadius: _pressed ? 2 : 8,
                  spreadRadius: _pressed ? 0 : 1,
                ),
                if (!_pressed)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.08),
                    offset: const Offset(-1, -1),
                    blurRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: widget.child ??
                  (widget.icon != null
                      ? Icon(widget.icon, color: Colors.white70, size: 22)
                      : null),
            ),
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.label!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
