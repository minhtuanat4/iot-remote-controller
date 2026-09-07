import 'package:flutter/material.dart';

import '../../domain/models/ac_mode.dart';
import '../theme/app_theme.dart';

/// Mode icon with subtle movement animation when active.
class ModeIconAnimated extends StatefulWidget {
  const ModeIconAnimated({
    super.key,
    required this.mode,
    this.active = true,
    this.size = 28,
  });

  final AcMode mode;
  final bool active;
  final double size;

  @override
  State<ModeIconAnimated> createState() => _ModeIconAnimatedState();
}

class _ModeIconAnimatedState extends State<ModeIconAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _anim = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ModeIconAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 0.5;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.mode) {
      case AcMode.cool:
        return Icons.ac_unit;
      case AcMode.heat:
        return Icons.wb_sunny;
      case AcMode.dry:
        return Icons.water_drop;
      case AcMode.fan:
        return Icons.toys;
      case AcMode.auto:
        return Icons.autorenew;
    }
  }

  Color get _color {
    switch (widget.mode) {
      case AcMode.cool:
        return AppTheme.accent;
      case AcMode.heat:
        return Colors.orangeAccent;
      case AcMode.dry:
        return Colors.lightBlueAccent;
      case AcMode.fan:
        return Colors.greenAccent;
      case AcMode.auto:
        return AppTheme.displayGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        Widget icon = Icon(
          _icon,
          size: widget.size,
          color: widget.active ? _color : _color.withValues(alpha: 0.35),
        );
        if (!widget.active) return icon;

        switch (widget.mode) {
          case AcMode.fan:
          case AcMode.auto:
            return Transform.rotate(angle: _anim.value * 3, child: icon);
          case AcMode.cool:
            return Transform.translate(
              offset: Offset(0, _anim.value * 8),
              child: icon,
            );
          case AcMode.heat:
            return Transform.translate(
              offset: Offset(0, -_anim.value * 8),
              child: icon,
            );
          case AcMode.dry:
            return Transform.translate(
              offset: Offset(_anim.value * 6, _anim.value.abs() * 4),
              child: icon,
            );
        }
      },
    );
  }
}
