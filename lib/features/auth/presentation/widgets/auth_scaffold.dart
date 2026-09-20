import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_logo.dart';

/// The frame every auth screen sits in: mark, headline, standfirst, content.
///
/// No hero illustration. The web app's auth and landing scopes used to
/// redefine the neutrals to a warm paper-cream so their ink read brown rather
/// than charcoal; that split is gone and both scopes inherit the base palette,
/// because the warmth was not worth its cost — the contrast gate parsed only
/// the root and dark blocks, so ~15 tokens per scope were ungated and the login
/// fields had drifted to 1.25:1 against the page. Auth here is the same palette
/// as everywhere else, for the same reason.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = false,
    this.showLogo = true,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBack;

  /// Matches the web page for page: login, signup and phone-number carry the
  /// lockup; forgot-password, reset-password and the OTP step do not.
  final bool showLogo;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.background,
      appBar: showBack
          ? AppBar(
              backgroundColor: t.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppShape.space6,
            vertical: AppShape.space6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showLogo) ...[
                // `!h-16` and `mt-5` on the web's auth pages.
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogo(height: 64),
                ),
                const SizedBox(height: AppShape.space5),
              ],
              Text(
                title,
                style: AppTypography.h2.copyWith(
                  color: t.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppShape.space2),
              Text(
                subtitle,
                style: AppTypography.small.copyWith(
                  color: t.mutedForeground,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: AppShape.space6),
              ...children,
              if (footer != null) ...[
                const SizedBox(height: AppShape.space6),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled rule: "or continue with".
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Row(
      children: [
        Expanded(child: Divider(color: t.border, height: AppShape.hairline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppShape.space3),
          child: Text(
            label,
            style: AppTypography.tiny.copyWith(color: t.mutedForeground),
          ),
        ),
        Expanded(child: Divider(color: t.border, height: AppShape.hairline)),
      ],
    );
  }
}
