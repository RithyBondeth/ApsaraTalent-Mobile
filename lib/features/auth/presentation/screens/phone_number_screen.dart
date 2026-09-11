import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/validators/phone_validator.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => PhoneValidator.validate(_controller.text) == null;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AuthScaffold(
      showBack: true,
      title: 'Log in with your phone',
      subtitle: 'We will text you a six-digit code to confirm the number.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The dial code is fixed for now. It sits in its own box rather
            // than as a prefix inside the field so it reads as a distinct part
            // of the number, not as placeholder text.
            Container(
              height: AppShape.fieldHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppShape.space3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.muted,
                border: Border.all(color: t.input, width: AppShape.hairline),
              ),
              child: Text(
                '+855',
                style: AppTypography.field.copyWith(
                  color: t.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: AppInput(
                controller: _controller,
                hintText: 'Phone number',
                prefixIcon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Send code',
          trailingIcon: LucideIcons.arrowRight,
          fullWidth: true,
          size: AppButtonSize.lg,
          onPressed:
              _valid ? () => context.router.push(const OTPRoute()) : null,
        ),
      ],
    );
  }
}
