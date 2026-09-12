import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/validators/password_validator.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // Empty fields show no error: a form that opens already shouting "required"
  // at someone who hasn't typed yet is scolding them for arriving.
  String? get _passwordError => _password.text.isEmpty
      ? null
      : PasswordValidator.validate(_password.text);

  String? get _confirmError {
    if (_confirm.text.isEmpty) return null;
    if (_confirm.text != _password.text) return 'Passwords do not match';
    return null;
  }

  bool get _valid =>
      _password.text.isNotEmpty &&
      _confirm.text.isNotEmpty &&
      _passwordError == null &&
      _confirmError == null;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: 'Choose a new password',
      subtitle: 'It needs to be at least 8 characters long.',
      children: [
        AppInput(
          controller: _password,
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
        const SizedBox(height: AppShape.space3),
        AppInput(
          controller: _confirm,
          hintText: 'Confirm new password',
          prefixIcon: LucideIcons.lockKeyhole,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        Text(
          'You will be signed out of other devices once the password changes.',
          style: AppTypography.tiny.copyWith(
            color: t.mutedForeground,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Update password',
          fullWidth: true,
          size: AppButtonSize.lg,
          // No reset endpoint is wired yet. The button validates the form but
          // does not pretend the password changed.
          onPressed: _valid ? () {} : null,
        ),
      ],
    );
  }
}
