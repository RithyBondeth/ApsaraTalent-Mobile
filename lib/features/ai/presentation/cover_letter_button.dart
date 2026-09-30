import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_writing_screen.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

class CoverLetterButton extends ConsumerStatefulWidget {
  const CoverLetterButton(
      {super.key, required this.job, required this.controller});
  final JobPosting job;
  final TextEditingController controller;
  @override
  ConsumerState<CoverLetterButton> createState() => _CoverLetterButtonState();
}

class _CoverLetterButtonState extends ConsumerState<CoverLetterButton> {
  bool _loading = false;
  String? _error;
  Future<void> _open() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ref.read(profileProvider.future);
      if (profile is! EmployeeProfile) {
        throw ApiException(
            message: 'A candidate profile is needed to write a cover letter.');
      }
      if (!mounted) return;
      final text = await Navigator.of(context).push<String>(MaterialPageRoute(
          builder: (_) => AiWritingScreen(
                initialText: widget.controller.text,
                contextData: {
                  'employeeName': profile.fullName,
                  'employeeJob': profile.job ?? '',
                  'employeeSkills': profile.skills,
                  'employeeExperience': profile.yearsOfExperience ?? '',
                  'employeeDescription': profile.description ?? '',
                  'companyName': widget.job.company?.name ?? '',
                  'companyIndustry': widget.job.company?.industry ?? '',
                  'openPositions': [widget.job.title],
                },
              )));
      if (mounted && text != null) widget.controller.text = text;
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException
            ? e.message
            : 'Your profile could not load. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppButton(
            label: 'Write with AI',
            variant: AppButtonVariant.outline,
            loading: _loading,
            onPressed: _loading ? null : _open),
        if (_error != null)
          Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]);
}
