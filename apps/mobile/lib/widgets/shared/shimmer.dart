import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Bloque con brillo animado (shimmer) estilo Manus, usado como skeleton de
/// carga y como fondo del indicador "pensando".
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final slide = _controller.value * (w * 2) - w;
                    final height =
                        constraints.maxHeight > 0 ? constraints.maxHeight : 1.0;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: Offset(slide, 0),
                        child: SizedBox(
                          width: w * 0.55,
                          height: height,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  c.surfaceContainerLow.withValues(alpha: 0.0),
                                  c.surfaceContainerHighest
                                      .withValues(alpha: 0.55),
                                  c.surfaceContainerLow.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Indicador de escritura "pensando": tres puntos con fade secuencial, al
/// estilo de los estados en curso de Manus.
class TypingDots extends StatefulWidget {
  final double size;
  final Color? color;

  const TypingDots({super.key, this.size = 6, this.color});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? ThemeScope.of(context).primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Opacity(
                  opacity: _dotOpacity(i),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  double _dotOpacity(int i) {
    final t = (_controller.value * 3 - i).clamp(0.0, 1.0);
    return (1 - t).clamp(0.3, 1.0);
  }
}