import 'package:apsaratalent_mobile/shared/extensions/tailwind_widget_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_button_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../../shared/extensions/text_extensions.dart';
import '../../../../shared/themes/tailwind_styles.dart';
import '../../../../shared/widgets/custom_dialog_widget.dart';

enum UserRole { company, employee }

// Riverpod provider for selected role
final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

class RoleSelectionDialog extends ConsumerWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionDialog({
    super.key,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(TW.roundedXl),
          boxShadow: TW.shadowXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Column(
              children: [
                CustomLogoWidget(withoutTitle: true, height: 100),
                const SizedBox(height: 10),
                Text('Choose Your Path', style: context.headlineMedium.bold),
                const SizedBox(height: 10),
                Text(
                  'Select how you want to use Apsara Talent',
                  style: context.bodyMedium.muted,
                  textAlign: TextAlign.center,
                ),
              ],
            ).p(30),
            // Role Options
            Column(
              children: [
                _buildRoleCard(
                  context: context,
                  role: UserRole.company,
                  icon: LucideIcons.building2,
                  title: 'I\'m a Company',
                  description:
                      'Post jobs, find talents, and manage hiring process',
                  gradient: [
                    context.primary.withValues(alpha: 0.1),
                    context.primary.withValues(alpha: 0.05),
                  ],
                  isSelected: selectedRole == UserRole.company,
                  onTap: () => ref.read(selectedRoleProvider.notifier).state =
                      UserRole.company,
                ),
                const SizedBox(height: 15),
                _buildRoleCard(
                  context: context,
                  role: UserRole.employee,
                  icon: LucideIcons.user,
                  title: 'I\'m Looking for Work',
                  description:
                      'Find jobs, apply for positions, and build your career',
                  gradient: [
                    context.secondary.withValues(alpha: 0.1),
                    context.secondary.withValues(alpha: 0.05),
                  ],
                  isSelected: selectedRole == UserRole.employee,
                  onTap: () => ref.read(selectedRoleProvider.notifier).state =
                      UserRole.employee,
                ),
              ],
            ).px(20),
            // Actions
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    text: 'Cancel',
                    onPressed: () {
                      ref.read(selectedRoleProvider.notifier).state = null;
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CustomButtonWidget(
                    text: 'Continue',
                    onPressed: selectedRole != null
                        ? () {
                            ref.read(selectedRoleProvider.notifier).state =
                                null;
                            Navigator.pop(context);
                            onRoleSelected(selectedRole);
                          }
                        : null,
                  ),
                ),
              ],
            ).p(20),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                )
              : null,
          color: isSelected ? null : context.card,
          border: Border.all(
            color: isSelected
                ? context.primary.withValues(alpha: 0.3)
                : context.border.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(TW.roundedXl),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primary.withValues(alpha: 0.15)
                        : context.muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(TW.roundedXl),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isSelected ? context.primary : context.mutedForeground,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.titleLarge
                            .copyWith(
                              color: isSelected
                                  ? context.primary
                                  : context.foreground,
                            )
                            .bold,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: context.bodyMedium.copyWith(
                          color: context.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: context.primaryForeground,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Utility function to show role selection dialog
class RoleSelectionUtils {
  static Future<UserRole?> showRoleSelectionDialog({
    required BuildContext context,
  }) async {
    UserRole? selectedRole;

    await DialogUtils.showCustomDialog<UserRole>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      dialog: RoleSelectionDialog(
        onRoleSelected: (role) {
          selectedRole = role;
        },
      ),
    );

    return selectedRole;
  }

  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.company:
        return 'Company';
      case UserRole.employee:
        return 'Employee';
    }
  }

  static IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.company:
        return LucideIcons.building2;
      case UserRole.employee:
        return LucideIcons.user;
    }
  }
}
