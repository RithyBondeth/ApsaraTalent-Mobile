import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shown while the signed-in account's email is unverified.
///
/// "Verify later" after signup keeps the session, but the API refuses the
/// next password login until the address is confirmed. Without this there is
/// no way back to the code screen short of signing out and hitting that wall.
/// The previous code has usually expired by now, so it asks for a fresh one.
///
/// Draws nothing for verified accounts, phone accounts and signed-out state.
class VerifyEmailNotice extends ConsumerWidget {
  const VerifyEmailNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value?.user;
    final email = user?.email;
    if (user == null || user.isEmailVerified || email == null || email.isEmpty) {
      return const SizedBox.shrink();
    }

    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space4),
      child: Material(
        color: t.warningSubtle,
        child: InkWell(
          onTap: () => context.router.push(
            EmailVerificationRoute(email: email, sendCode: true),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppShape.space3),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: t.warningAccent, width: 3),
                top: BorderSide(color: t.warningBorder, width: AppShape.hairline),
                right: BorderSide(color: t.warningBorder, width: AppShape.hairline),
                bottom: BorderSide(color: t.warningBorder, width: AppShape.hairline),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.mailWarning, size: 18, color: t.warningAccent),
                const SizedBox(width: AppShape.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify your email',
                        style: AppTypography.small.copyWith(
                          color: t.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "You'll need it to log in again. We'll send a code to $email.",
                        style: AppTypography.tiny.copyWith(
                          color: t.mutedForeground,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 18, color: t.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
