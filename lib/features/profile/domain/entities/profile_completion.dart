/// How complete a profile is, and what is missing from it.
///
/// The API does not compute this — `profileCompleted` on the user record is a
/// bool for onboarding routing, not a score. The web computes a percentage
/// client-side in `utils/functions/profile/profile-completion.ts`, and this is
/// a port of it: the same fields, the same weights, the same rounding. Two
/// different numbers for the same profile on two clients would be worse than
/// no number at all, so the weights below must move together with the web's.
library;

class ProfileField {
  const ProfileField(this.label, this.weight, {required this.filled});

  /// Shown to the reader, so it is prose rather than the web's i18n key.
  final String label;
  final int weight;
  final bool filled;
}

class ProfileCompletion {
  const ProfileCompletion({required this.percent, required this.missing});

  /// 0–100, never higher.
  final int percent;

  /// The labels of the unfilled fields, heaviest first — the order to ask for
  /// them in, since it is the order that moves the number most.
  final List<String> missing;

  bool get isComplete => percent >= 100;

  factory ProfileCompletion.of(List<ProfileField> fields) {
    var total = 0;
    final missing = <ProfileField>[];
    for (final field in fields) {
      if (field.filled) {
        total += field.weight;
      } else {
        missing.add(field);
      }
    }
    missing.sort((a, b) => b.weight.compareTo(a.weight));
    return ProfileCompletion(
      percent: total > 100 ? 100 : total,
      missing: missing.map((f) => f.label).toList(),
    );
  }

  /// "Add your profile photo, skills and languages to reach 100%." Nothing at
  /// all when the profile is complete.
  String? get prompt {
    if (missing.isEmpty) return null;
    final top = missing.take(3).toList();
    final list = top.length == 1
        ? top.single
        : '${top.take(top.length - 1).join(', ')} and ${top.last}';
    return 'Add your $list to reach 100%.';
  }
}
