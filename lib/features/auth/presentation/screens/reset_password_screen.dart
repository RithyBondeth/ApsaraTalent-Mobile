import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/validators/password_validator.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_message.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/password_rules.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/password_reset/password_reset_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.sentTo, this.viaPhone = false});

  /// Where the token was sent, when arriving from the forgot-password screen.
  final String? sentTo;
  final bool viaPhone;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _submitted = false;

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? get _tokenError =>
      _submitted && _token.text.trim().isEmpty ? 'Paste the token you were sent' : null;

  // Rules show as a live checklist; the field only turns red once the user has
  // tried to submit, so an unfinished password isn't scolded mid-keystroke.
  String? get _passwordError =>
      _submitted ? PasswordValidator.validateStrong(_password.text) : null;

  String? get _confirmError {
    if (_confirm.text.isEmpty) return _submitted ? 'Confirm your new password' : null;
    return _confirm.text == _password.text ? null : 'Passwords do not match';
  }

  bool get _valid =>
      _token.text.trim().isNotEmpty &&
      PasswordValidator.validateStrong(_password.text) == null &&
      _confirm.text == _password.text;

  Future<void> _pasteToken() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() => _token.text = text);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_valid) return;
    final ok = await ref.read(passwordResetProvider.notifier).reset(
          token: _token.text,
          newPassword: _password.text,
          confirmPassword: _confirm.text,
        );
    if (!ok || !mounted) return;
    // Login may still be under this screen holding the password that no
    // longer works.
    ref.invalidate(passwordInputProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated. Log in with your new password.')),
    );
    context.router.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final flow = ref.watch(passwordResetProvider);
    final destination = widget.viaPhone ? 'text message' : 'email';

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: 'Choose a new password',
      subtitle: widget.sentTo == null
          ? 'Enter the reset token you were sent, then your new password.'
          : 'We sent a reset token by $destination to ${widget.sentTo}. '
              'Paste it below, then choose a new password.',
      children: [
        AppInput(
          controller: _token,
          labelText: 'Reset token',
          hintText: 'Paste the token',
          prefixIcon: LucideIcons.keyRound,
          suffixIcon: LucideIcons.clipboardPaste,
          onSuffixTap: _pasteToken,
          textInputAction: TextInputAction.next,
          errorText: _tokenError,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _password,
          labelText: 'New password',
          hintText: 'New password',
          prefixIcon: LucideIcons.lockKeyhole,
          suffixIcon: _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
          onSuffixTap: () => setState(() => _obscure = !_obscure),
          obscureText: _obscure,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          errorText: _passwordError,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space2),
        PasswordRules(password: _password.text),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _confirm,
          labelText: 'Confirm new password',
          hintText: 'Repeat the new password',
          prefixIcon: LucideIcons.lockKeyhole,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        if (flow.error != null) ...[
          const SizedBox(height: AppShape.space4),
          AuthMessage.error(flow.error!),
        ],
        const SizedBox(height: AppShape.space4),
        Text(
          'Tokens expire. If yours has, go back and request a new one.',
          style: AppTypography.tiny.copyWith(color: t.mutedForeground, height: 1.5),
        ),
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Update password',
          fullWidth: true,
          size: AppButtonSize.lg,
          loading: flow.isLoading,
          onPressed: flow.isLoading ? null : _submit,
        ),
      ],
    );
  }
}
