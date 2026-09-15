import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/validators/email_validator.dart';
import 'package:apsaratalent_mobile/core/validators/password_validator.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/password_rules.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/step_header.dart';
import 'package:apsaratalent_mobile/features/auth/providers/signup/signup_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SignupAccountScreen extends ConsumerStatefulWidget {
  const SignupAccountScreen({super.key});

  @override
  ConsumerState<SignupAccountScreen> createState() => _SignupAccountScreenState();
}

class _SignupAccountScreenState extends ConsumerState<SignupAccountScreen> {
  late final _email = TextEditingController(text: ref.read(signupProvider).email);
  late final _phone = TextEditingController(text: ref.read(signupProvider).phone);
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _submitted = false;

  /// The web's rule: an optional Cambodian number, +855 or a leading zero.
  static final _phonePattern = RegExp(r'^(\+855|0)[0-9]{8,9}$');

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? get _emailError =>
      _submitted ? EmailValidator.validate(_email.text.trim()) : null;

  String? get _phoneError {
    final v = _phone.text.replaceAll(RegExp(r'\s'), '');
    if (v.isEmpty || _phonePattern.hasMatch(v)) return null;
    return _submitted ? 'Use +855 or 0 followed by 8–9 digits' : null;
  }

  String? get _passwordError =>
      _submitted ? PasswordValidator.validateStrong(_password.text) : null;

  String? get _confirmError {
    if (!_submitted && _confirm.text.isEmpty) return null;
    if (_confirm.text.isEmpty) return 'Confirm your password';
    return _confirm.text == _password.text ? null : 'Passwords do not match';
  }

  void _continue() {
    setState(() => _submitted = true);
    final phone = _phone.text.replaceAll(RegExp(r'\s'), '');
    final ok = EmailValidator.validate(_email.text.trim()) == null &&
        (phone.isEmpty || _phonePattern.hasMatch(phone)) &&
        PasswordValidator.validateStrong(_password.text) == null &&
        _confirm.text == _password.text;
    if (!ok) return;
    ref.read(signupProvider.notifier).setAccount(
          email: _email.text,
          password: _password.text,
          phone: phone,
        );
    context.router.push(const SignupProfileRoute());
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: 'Your sign-in details',
      subtitle: 'You will sign in with this email. We will send a code to it to '
          'confirm it is yours.',
      children: [
        const StepHeader(step: 2, total: 3),
        const SizedBox(height: AppShape.space5),
        AppInput(
          controller: _email,
          labelText: 'Email',
          hintText: 'you@example.com',
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: _emailError,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _phone,
          labelText: 'Phone (optional)',
          hintText: '+855 12 345 678',
          prefixIcon: LucideIcons.phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
          errorText: _phoneError,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _password,
          labelText: 'Password',
          hintText: 'Create a password',
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
          labelText: 'Confirm password',
          hintText: 'Repeat the password',
          prefixIcon: LucideIcons.lockKeyhole,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _continue(),
        ),
        const SizedBox(height: AppShape.space6),
        AppButton(
          label: 'Continue',
          trailingIcon: LucideIcons.arrowRight,
          fullWidth: true,
          size: AppButtonSize.lg,
          onPressed: _continue,
        ),
      ],
    );
  }
}
