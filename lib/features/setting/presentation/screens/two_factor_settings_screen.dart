import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_message.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/otp_field.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/two_factor/two_factor_settings_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Turn two-step verification on or off.
///
/// Setup shows the secret as text rather than a QR code. The API returns the
/// `otpauth://` URI (it calls it `qrCodeUrl`), and on a phone the authenticator
/// app is usually on the same device as this screen — so there is no second
/// camera to scan with. Authenticator apps all accept a typed or pasted key.
@RoutePage()
class TwoFactorSettingsScreen extends ConsumerStatefulWidget {
  const TwoFactorSettingsScreen({super.key});

  @override
  ConsumerState<TwoFactorSettingsScreen> createState() =>
      _TwoFactorSettingsScreenState();
}

class _TwoFactorSettingsScreenState extends ConsumerState<TwoFactorSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpProvider.notifier).clear();
      // Make sure the on/off state shown is the account's current one.
      ref.read(authSessionProvider.notifier).refreshUser();
    });
  }

  Future<void> _confirm({required bool enabling}) async {
    final code = ref.read(otpProvider);
    if (!code.isComplete) return;
    final notifier = ref.read(twoFactorSettingsProvider.notifier);
    final ok = enabling ? await notifier.enable(code.otp) : await notifier.disable(code.otp);
    ref.read(otpProvider.notifier).clear();
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(enabling
            ? 'Two-step verification is on.'
            : 'Two-step verification is off.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final user = ref.watch(authSessionProvider).value?.user;
    final state = ref.watch(twoFactorSettingsProvider);
    final code = ref.watch(otpProvider);
    final enabled = user?.isTwoFactorEnabled ?? false;
    final setup = state.setup;
    final flow = state.flow;

    return AppScreen(
      appBar: AppBar(title: const Text('Two-step verification')),
      children: [
        AppSurface(
          child: Row(
            children: [
              Icon(
                enabled ? LucideIcons.shieldCheck : LucideIcons.shield,
                size: 22,
                color: enabled ? t.successAccent : t.mutedForeground,
              ),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enabled ? 'On' : 'Off',
                      style: AppTypography.label.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled
                          ? 'Signing in asks for a code from your authenticator app.'
                          : 'Add a code from an authenticator app to your password.',
                      style: AppTypography.tiny.copyWith(color: t.mutedForeground, height: 1.4),
                    ),
                  ],
                ),
              ),
              AppStatusPill(
                status: enabled ? AppStatus.success : AppStatus.info,
                label: enabled ? 'Protected' : 'Password only',
              ),
            ],
          ),
        ),

        if (flow.message != null && setup == null)
          AuthMessage.success(flow.message!),
        if (flow.error != null) AuthMessage.error(flow.error!),

        if (enabled) ...[
          const SectionTitle(
            title: 'Turn it off',
            subtitle: 'Enter a current code from your authenticator app to confirm.',
          ),
          OtpField(length: AppConstants.otpLength),
          AppButton(
            label: 'Turn off two-step verification',
            variant: AppButtonVariant.destructive,
            fullWidth: true,
            loading: flow.isLoading,
            onPressed: code.isComplete && !flow.isLoading
                ? () => _confirm(enabling: false)
                : null,
          ),
        ] else if (setup == null) ...[
          const SectionTitle(
            title: 'How it works',
            subtitle: 'You will need an authenticator app such as Google '
                'Authenticator, Microsoft Authenticator or 1Password.',
          ),
          AppButton(
            label: 'Set up two-step verification',
            icon: LucideIcons.shieldPlus,
            fullWidth: true,
            size: AppButtonSize.lg,
            loading: flow.isLoading,
            onPressed: flow.isLoading
                ? null
                : () => ref.read(twoFactorSettingsProvider.notifier).startSetup(),
          ),
        ] else ...[
          const SectionTitle(
            title: '1. Add this key to your authenticator app',
            subtitle: 'Choose "enter a setup key" in the app and paste it.',
          ),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  setup.groupedSecret,
                  textAlign: TextAlign.center,
                  style: AppTypography.h4.copyWith(
                    color: t.foreground,
                    fontFamily: 'Courier',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppShape.space3),
                AppButton(
                  label: 'Copy key',
                  icon: LucideIcons.copy,
                  variant: AppButtonVariant.outline,
                  fullWidth: true,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: setup.secret));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Setup key copied')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SectionTitle(
            title: '2. Enter the code it shows',
            subtitle: 'This confirms the app is set up before it is required.',
          ),
          OtpField(length: AppConstants.otpLength),
          AppButton(
            label: 'Turn on two-step verification',
            fullWidth: true,
            size: AppButtonSize.lg,
            loading: flow.isLoading,
            onPressed: code.isComplete && !flow.isLoading
                ? () => _confirm(enabling: true)
                : null,
          ),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => ref.read(twoFactorSettingsProvider.notifier).cancelSetup(),
          ),
        ],
      ],
    );
  }
}
