import 'package:flutter/material.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Loading state of the list: card-shaped placeholders with a light sweeping
/// across them, so the screen already shows its layout while listings load.
/// Technique from the official cookbook ("Create a shimmer loading effect").
class PropertyListSkeleton extends StatefulWidget {
  const PropertyListSkeleton({super.key});

  @override
  State<PropertyListSkeleton> createState() => _PropertyListSkeletonState();
}

class _PropertyListSkeletonState extends State<PropertyListSkeleton>
    with SingleTickerProviderStateMixin {
  // -0.5 to 1.5: the highlight starts and ends outside the blocks.
  late final _controller = AnimationController(
    vsync: this,
    lowerBound: -0.5,
    upperBound: 1.5,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Remove animations" in the system settings: still blocks (WCAG 2.3.3).
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);

    // The blocks mean nothing to a screen reader; the label says what they do.
    return Semantics(
      label: 'Carregando imóveis…',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Column(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _SkeletonCard(slide: animate ? _controller.value : null),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.slide});

  /// Highlight position; null keeps the blocks still.
  final double? slide;

  @override
  Widget build(BuildContext context) {
    final blocks = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: ColoredBox(color: _block),
        ),
        Padding(
          // Same spacing as the card, so nothing jumps when listings arrive.
          padding: EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Line(widthFactor: 0.7, height: 18),
              SizedBox(height: 8),
              _Line(widthFactor: 0.4, height: 14),
              SizedBox(height: 8),
              _Line(widthFactor: 0.45, height: 18),
            ],
          ),
        ),
      ],
    );
    final slide = this.slide;

    return Card(
      child: slide == null
          ? blocks
          : ShaderMask(
              // Paints the gradient only where the blocks are drawn.
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                colors: const [_block, AppColors.surface, _block],
                stops: const [0.1, 0.3, 0.4],
                begin: const Alignment(-1, -0.3),
                end: const Alignment(1, 0.3),
                transform: _SlidingGradient(slide),
              ).createShader(bounds),
              child: blocks,
            ),
    );
  }
}

const _block = AppColors.border;

class _Line extends StatelessWidget {
  const _Line({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: _block,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}

class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.slide);

  final double slide;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}
