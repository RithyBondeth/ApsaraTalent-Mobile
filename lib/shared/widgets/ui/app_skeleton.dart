import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// A loading placeholder.
///
/// Square, like the thing it stands in for. It pulses rather than sweeping a
/// gradient across itself: a shimmer needs a light source, and this UI's only
/// depth cue is a hard offset shadow with no light in it at all.
///
/// Nothing in the type system ties a component to its skeleton, so when you
/// change a layout, change its skeleton in the same commit. The web app shipped
/// six pages loading into a two-column shape they were never going to show
/// because a skeleton was left behind by a redesign.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.circle = false,
  });

  final double? width;
  final double height;
  final bool circle;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: t.muted,
          borderRadius: BorderRadius.circular(
            widget.circle ? AppShape.pill : AppShape.radius,
          ),
        ),
      ),
    );
  }
}
