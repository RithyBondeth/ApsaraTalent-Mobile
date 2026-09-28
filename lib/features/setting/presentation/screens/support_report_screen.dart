import 'dart:io';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/account_settings.dart';
import 'package:apsaratalent_mobile/features/setting/providers/account_settings_provider.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SupportReportScreen extends ConsumerStatefulWidget {
  const SupportReportScreen({super.key});
  @override
  ConsumerState<SupportReportScreen> createState() =>
      _SupportReportScreenState();
}

class _SupportReportScreenState extends ConsumerState<SupportReportScreen> {
  final _details = TextEditingController();
  ProblemCategory _category = ProblemCategory.bug;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _details.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Tell us what happened.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final message =
          await ref.read(accountSettingsRepositoryProvider).reportProblem(
                category: _category,
                details: value,
                userAgent:
                    '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
              );
      if (!mounted) return;
      _details.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppScreen(
        appBar: AppBar(title: const Text('Support')),
        children: [
          const PageBanner(
              eyebrow: 'Support',
              title: 'Report a problem',
              subtitle:
                  'Describe what went wrong and our team can investigate.'),
          AppSurface(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text('Category',
                    style: AppTypography.label
                        .copyWith(color: context.tokens.foreground)),
                const SizedBox(height: AppShape.space2),
                DropdownButtonFormField<ProblemCategory>(
                  initialValue: _category,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  items: [
                    for (final item in ProblemCategory.values)
                      DropdownMenuItem(value: item, child: Text(item.label))
                  ],
                  onChanged: _sending
                      ? null
                      : (value) =>
                          setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: AppShape.space4),
                AppInput(
                  controller: _details,
                  labelText: 'What happened?',
                  hintText:
                      'Include the steps you took and what you expected to happen.',
                  minLines: 5,
                  maxLines: 8,
                  enabled: !_sending,
                  errorText: _error,
                  inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: AppShape.space2),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text('${_details.text.length}/1000',
                        style: AppTypography.tiny
                            .copyWith(color: context.tokens.mutedForeground))),
                const SizedBox(height: AppShape.space4),
                AppButton(
                    label: 'Send report',
                    icon: LucideIcons.send,
                    fullWidth: true,
                    loading: _sending,
                    onPressed: _submit),
              ])),
        ],
      );
}
