import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/step_header.dart';
import 'package:apsaratalent_mobile/features/auth/providers/signup/signup_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SignupRoleScreen extends ConsumerWidget {
  const SignupRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(signupProvider).role;

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: 'Create your account',
      subtitle: 'First, tell us which side of the match you are on.',
      children: [
        const StepHeader(step: 1, total: 3),
        const SizedBox(height: AppShape.space5),
        _RoleCard(
          icon: LucideIcons.userRound,
          title: 'I am looking for work',
          body: 'An employee or freelancer. Build a profile and get matched with '
              'companies hiring for what you do.',
          selected: role == ESignupRole.employee,
          onTap: () => ref.read(signupProvider.notifier).chooseRole(ESignupRole.employee),
        ),
        const SizedBox(height: AppShape.space3),
        _RoleCard(
          icon: LucideIcons.building2,
          title: 'I am hiring',
          body: 'A company or employer. Post open roles and get matched with '
              'people whose skills fit them.',
          selected: role == ESignupRole.company,
          onTap: () => ref.read(signupProvider.notifier).chooseRole(ESignupRole.company),
        ),
        const SizedBox(height: AppShape.space6),
        AppButton(
          label: 'Continue',
          trailingIcon: LucideIcons.arrowRight,
          fullWidth: true,
          size: AppButtonSize.lg,
          onPressed: role == null
              ? null
              : () => context.router.push(const SignupAccountRoute()),
        ),
      ],
    );
  }
}

/// A selectable card. Selected is a filled-primary edge and tint — the web's
/// "selected setting card" treatment — because the colour is carrying the
/// selection, which is exactly when an accent is allowed.
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppShape.space4),
          decoration: BoxDecoration(
            color: selected ? t.primary.withValues(alpha: 0.05) : t.card,
            border: Border.all(
              color: selected ? t.primary : t.border,
              width: selected ? 2 : AppShape.hairline,
            ),
            boxShadow: selected ? context.elevation.primary : context.elevation.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: selected ? t.primary : t.mutedForeground),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.label.copyWith(
                      color: t.foreground, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: AppShape.space1),
                    Text(body, style: AppTypography.small.copyWith(
                      color: t.mutedForeground, height: 1.45,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: AppShape.space2),
              Icon(
                selected ? LucideIcons.circleCheck : LucideIcons.circle,
                size: 20,
                color: selected ? t.primary : t.input,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
