import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

const _logo = SvgAssetLoader('assets/images/imobibrasil-logo.svg');

/// Loads the splash logo before the app's first frame, so it is drawn at once
/// (on the web, the HTML splash stays up meanwhile).
Future<void> precacheSplashLogo() =>
    svg.cache.putIfAbsent(_logo.cacheKey(null), () => _logo.loadBytes(null));

/// Covers the app with the logo for [duration], then fades out.
///
/// Not a route on purpose: it never enters the history, and the app keeps
/// loading underneath, so the list is often ready when the splash leaves.
class SplashGate extends StatefulWidget {
  const SplashGate({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  final Widget child;
  final Duration duration;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  Timer? _timer;
  bool _visible = true;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _startAfterFirstFrame();
  }

  /// Counts the [SplashGate.duration] only once the logo is on screen, so slow
  /// first frames (debug builds, slow phones) don't eat into it.
  Future<void> _startAfterFirstFrame() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _timer = Timer(widget.duration, () => setState(() => _visible = false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Screen readers must not read the app hidden behind the splash.
        ExcludeSemantics(excluding: _visible, child: widget.child),
        if (!_gone)
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              onEnd: () => setState(() => _gone = true),
              child: const _Splash(),
            ),
          ),
      ],
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: const SvgPicture(_logo, semanticsLabel: 'ImobiBrasil'),
          ),
        ),
      ),
    );
  }
}
