import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';

/// The profile's shape while it loads: identity, completion, one section.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          AppSurface(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 72, height: 72),
                SizedBox(width: AppShape.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(width: 170, height: 20),
                      SizedBox(height: AppShape.space2),
                      AppSkeleton(width: 120, height: 12),
                      SizedBox(height: AppShape.space2),
                      AppSkeleton(width: 90, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 140, height: 14),
                SizedBox(height: AppShape.space3),
                AppSkeleton(height: 8),
                SizedBox(height: AppShape.space3),
                AppSkeleton(width: 200, height: 10),
              ],
            ),
          ),
          AppSurface(
            child: Wrap(
              spacing: AppShape.space2,
              runSpacing: AppShape.space2,
              children: [
                AppSkeleton(width: 80, height: 24),
                AppSkeleton(width: 110, height: 24),
                AppSkeleton(width: 70, height: 24),
              ],
            ),
          ),
        ],
      );
}
