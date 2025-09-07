import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../../shared/extensions/text_extensions.dart';
import '../../../../shared/themes/tailwind_styles.dart';
import '../../../../shared/widgets/custom_dialog_widget.dart';

enum UserRole { company, employee }

class RoleSelectionDialog extends StatefulWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionDialog({
    super.key,
    required this.onRoleSelected,
  });

  @override
  State<RoleSelectionDialog> createState() => _RoleSelectionDialogState();
}

class _RoleSelectionDialogState extends State<RoleSelectionDialog> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TW.roundedFull),
                    ),
                    child: Icon(
                      LucideIcons.users,
                      color: context.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose Your Path',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select how you want to use Apsara Talent',
                    style: context.bodyMedium.copyWith(
                      color: context.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Role Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
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
                    onTap: () =>
                        setState(() => selectedRole = UserRole.company),
                  ),
                  const SizedBox(height: 16),
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
                    onTap: () =>
                        setState(() => selectedRole = UserRole.employee),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TW.roundedLg),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: context.mutedForeground),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: selectedRole != null
                          ? () {
                              Navigator.of(context).pop();
                              widget.onRoleSelected(selectedRole!);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.primaryForeground,
                        disabledBackgroundColor: context.muted,
                        disabledForegroundColor: context.mutedForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TW.roundedLg),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        padding: const EdgeInsets.all(24),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.titleLarge.copyWith(
                          color:
                              isSelected ? context.primary : context.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: context.bodyMedium.copyWith(
                          color: context.mutedForeground,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: context.primaryForeground,
                      size: 16,
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
