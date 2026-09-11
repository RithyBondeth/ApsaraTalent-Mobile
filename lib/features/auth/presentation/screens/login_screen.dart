import 'package:apsaratalent_mobile/core/constants/asset_path_constant.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_validation_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/login/login_state.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;

  void _onInputChanged(StateProvider<String> provider, String value) {
    ref.read(provider.notifier).state = value.trim();
    // A stale "wrong password" under a field the user is already correcting
    // reads as a second failure. Clear it on the first keystroke.
    if (ref.read(loginProvider).value?.error != null) {
      ref.read(loginProvider.notifier).clearError();
    }
  }

  void _submit() {
    ref.read(loginProvider.notifier).login(
          ref.read(emailInputProvider),
          ref.read(passwordInputProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final emailError = ref.watch(emailValidationProvider);
    final passwordError = ref.watch(passwordValidationProvider);
    final formValid = ref.watch(loginFormValidProvider);
    final rememberMe = ref.watch(rememberMeProvider);
    final authState = ref.watch(loginProvider);

    // LoginNotifier folds a failure back into `AsyncValue.data` carrying
    // `LoginState.error`, so the message lives on the value — an
    // `authState.whenOrNull(error: …)` branch never fires and the user would
    // see nothing at all.
    final loginError = authState.value?.error;

    ref.listen<AsyncValue<LoginState>>(loginProvider, (_, next) {
      final state = next.value;
      if (state == null) return;
      if (state.requiresTwoFactor) {
        final token = state.loginResponse?.twoFactorToken;
        if (token != null) {
          context.router.push(OTPRoute(twoFactorToken: token));
        }
      } else if (state.isLoggedIn) {
        context.router.replaceAll([const MainRoute()]);
      }
    });

    return AuthScaffold(
      title: 'Log in to your account',
      subtitle: 'Welcome back to Apsara Talent. Choose how you want to sign in.',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account yet? ",
            style: AppTypography.small.copyWith(color: t.mutedForeground),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Create account',
              style: AppTypography.button.copyWith(
                color: t.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      children: [
        // Social Section
        //
        // The full-colour raster marks stay on these buttons: Google's branding
        // terms require their own logo rather than a monochrome glyph.
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                asset: AppAssetPathContant.googleIcon,
                label: 'Google',
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: _SocialButton(
                asset: AppAssetPathContant.facebookIcon,
                label: 'Facebook',
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space2),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                asset: AppAssetPathContant.linkedInIcon,
                label: 'LinkedIn',
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: _SocialButton(
                asset: AppAssetPathContant.githubIcon,
                label: 'GitHub',
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space2),
        AppButton(
          label: 'Phone number',
          icon: LucideIcons.phone,
          variant: AppButtonVariant.outline,
          fullWidth: true,
          onPressed: () => context.router.push(const PhoneNumberRoute()),
        ),

        const SizedBox(height: AppShape.space5),
        const AuthDivider(label: 'or continue with'),
        const SizedBox(height: AppShape.space5),

        // Credentials Section
        AppInput(
          hintText: 'Email',
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: emailError,
          onChanged: (value) => _onInputChanged(emailInputProvider, value),
        ),
        const SizedBox(height: AppShape.space3),
        AppInput(
          hintText: 'Password',
          prefixIcon: LucideIcons.lockKeyhole,
          suffixIcon: _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
          onSuffixTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          errorText: passwordError,
          onChanged: (value) => _onInputChanged(passwordInputProvider, value),
          onSubmitted: (_) {
            if (formValid && !authState.isLoading) _submit();
          },
        ),

        const SizedBox(height: AppShape.space3),
        Row(
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: rememberMe,
                onChanged: (value) => ref
                    .read(rememberMeProvider.notifier)
                    .state = value ?? false,
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: Text(
                'Remember me',
                style: AppTypography.small.copyWith(color: t.mutedForeground),
              ),
            ),
            GestureDetector(
              onTap: () => context.router.push(const ForgotPasswordRoute()),
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Forgot password?',
                style: AppTypography.button.copyWith(color: t.primary),
              ),
            ),
          ],
        ),

        if (loginError != null) ...[
          const SizedBox(height: AppShape.space4),
          _LoginError(message: loginError),
        ],

        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Log in',
          fullWidth: true,
          size: AppButtonSize.lg,
          loading: authState.isLoading,
          onPressed: formValid ? _submit : null,
        ),
      ],
    );
  }
}

/// A failed login. Drawn on the destructive status tokens — this is a state,
/// and the status family is the one that carries severity.
class _LoginError extends StatelessWidget {
  const _LoginError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppShape.space3),
        decoration: BoxDecoration(
          color: t.destructiveSubtle,
          border: Border.all(
            color: t.destructiveBorder,
            width: AppShape.hairline,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.triangleAlert, size: 16, color: t.destructiveAccent),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.small.copyWith(
                  color: t.destructiveAccent,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: AppShape.controlHeightMd,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.background,
          border: Border.all(color: t.input, width: AppShape.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, height: 18, width: 18),
            const SizedBox(width: AppShape.space2),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.button.copyWith(color: t.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
