import 'package:flutter/material.dart';

import '../../domain/models/ac_state.dart';
import '../theme/app_theme.dart';
import 'mode_icon_animated.dart';

/// Modern animated LCD-style display for temp / mode / fan / timer.
class AcDisplay extends StatelessWidget {
  const AcDisplay({super.key, required this.state});

  final AcState state;

  @override
  Widget build(BuildContext context) {
    final on = state.power;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.displayBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: on
              ? AppTheme.displayGlow.withValues(alpha: 0.45)
              : Colors.white12,
          width: 1.5,
        ),
        boxShadow: on
            ? [
                BoxShadow(
                  color: AppTheme.displayGlow.withValues(alpha: 0.18),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: on ? 1 : 0.25,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ModeIconAnimated(mode: state.mode, active: on, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.mode.labelVi,
                    style: TextStyle(
                      color: AppTheme.displayGlow.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (state.timerOn)
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: AppTheme.accent.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${state.timerMinutes}\'',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: state.temperature.toDouble()),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.round().toString(),
                      style: TextStyle(
                        color: AppTheme.displayGlow,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        shadows: [
                          Shadow(
                            color:
                                AppTheme.displayGlow.withValues(alpha: 0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '°C',
                        style: TextStyle(
                          color: AppTheme.displayGlow,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _chip(Icons.air, 'Quạt: ${state.fan.labelVi}'),
                _chip(
                  Icons.power_settings_new,
                  on ? 'BẬT' : 'TẮT',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
