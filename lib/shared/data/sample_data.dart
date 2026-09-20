import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/shared/widgets/ui/app_status_pill.dart';

/// Placeholder content for the non-auth screens.
///
/// Auth talks to the API through `core/network/api_client.dart` and the
/// clean-architecture stack under `features/auth/`. Nothing else does yet:
/// feed, search, chat, notifications, applications and the rest have no data
/// source, repository or use case, so every one of those screens renders from
/// here.
///
/// It lives in one file, and the screens read it through the models rather than
/// inlining literals, so wiring a feature to the API is a matter of swapping the
/// source behind these types instead of hunting string literals through a dozen
/// widgets. Delete each piece as its feature gets a real data layer — do not
/// "temporarily" keep it as a fallback, or a network failure will silently
/// render fake jobs.
class SampleData {
  const SampleData._();

  static const viewer = SampleProfile(
    name: 'Rithy Bondeth',
    headline: 'Software Engineer',
    location: 'Phnom Penh, Cambodia',
    availability: SampleAvailability.openToWork,
    skills: ['Flutter', 'TypeScript', 'NestJS', 'PostgreSQL', 'Next.js'],
    languages: ['Khmer', 'English'],
    completion: 0.72,
  );

  static const companies = <SampleCompany>[
    SampleCompany(
      name: 'Quantum Edge',
      industry: 'Quantum & Cloud Computing',
      location: 'Phnom Penh',
      openRoles: 6,
      size: '120–200',
      benefits: ['Health cover', 'Remote friendly', 'Learning budget'],
      matchScore: 92,
    ),
    SampleCompany(
      name: 'Mekong Data Works',
      industry: 'Data Infrastructure',
      location: 'Siem Reap',
      openRoles: 3,
      size: '40–80',
      benefits: ['Hybrid', 'Stock options'],
      matchScore: 84,
    ),
    SampleCompany(
      name: 'Angkor Fintech',
      industry: 'Payments & Banking',
      location: 'Phnom Penh',
      openRoles: 11,
      size: '300+',
      benefits: ['Health cover', 'Annual bonus', 'Gym'],
      matchScore: 77,
    ),
  ];

  static const jobs = <SampleJob>[
    SampleJob(
      title: 'Senior Flutter Engineer',
      company: 'Quantum Edge',
      location: 'Phnom Penh · Hybrid',
      employmentType: 'Full time',
      postedAgo: '2 days ago',
      matchScore: 92,
      skills: ['Flutter', 'Dart', 'Riverpod', 'CI/CD'],
    ),
    SampleJob(
      title: 'Backend Engineer (NestJS)',
      company: 'Mekong Data Works',
      location: 'Remote',
      employmentType: 'Contract',
      postedAgo: '5 days ago',
      matchScore: 81,
      skills: ['NestJS', 'PostgreSQL', 'Redis'],
    ),
    SampleJob(
      title: 'Product Designer',
      company: 'Angkor Fintech',
      location: 'Phnom Penh · On site',
      employmentType: 'Full time',
      postedAgo: '1 week ago',
      matchScore: 64,
      skills: ['Figma', 'Design systems'],
    ),
  ];

  static const applications = <SampleApplication>[
    SampleApplication(
      role: 'Senior Flutter Engineer',
      company: 'Quantum Edge',
      stage: 'Interview',
      status: AppStatus.info,
      updatedAgo: 'Updated 3h ago',
    ),
    SampleApplication(
      role: 'Mobile Lead',
      company: 'Angkor Fintech',
      stage: 'Offer',
      status: AppStatus.success,
      updatedAgo: 'Updated yesterday',
    ),
    SampleApplication(
      role: 'Backend Engineer',
      company: 'Mekong Data Works',
      stage: 'Rejected',
      status: AppStatus.destructive,
      updatedAgo: 'Updated 4 days ago',
    ),
    SampleApplication(
      role: 'Platform Engineer',
      company: 'Bayon Cloud',
      stage: 'In review',
      status: AppStatus.warning,
      updatedAgo: 'Updated 6 days ago',
    ),
  ];

  static const conversations = <SampleConversation>[
    SampleConversation(
      name: 'Sokha Chan',
      company: 'Quantum Edge',
      preview: 'Great — does Thursday 10am work for the technical round?',
      timeAgo: '10m',
      unread: 2,
      online: true,
    ),
    SampleConversation(
      name: 'Dara Pich',
      company: 'Angkor Fintech',
      preview: 'Thanks for sending the portfolio through.',
      timeAgo: '2h',
      unread: 0,
      online: true,
    ),
    SampleConversation(
      name: 'Mekong Data Works',
      company: 'Recruiting team',
      preview: 'We have moved your application to the next stage.',
      timeAgo: '1d',
      unread: 0,
      online: false,
    ),
  ];

  static const notifications = <SampleNotification>[
    SampleNotification(
      title: 'Interview scheduled',
      body: 'Quantum Edge confirmed Thursday at 10:00.',
      timeAgo: '10m',
      category: AppCategory.blue,
      kind: 'Interview',
      icon: LucideIcons.calendarCheck,
      unread: true,
    ),
    SampleNotification(
      title: 'New match',
      body: 'Angkor Fintech matches 3 of your saved skills.',
      timeAgo: '3h',
      category: AppCategory.purple,
      kind: 'Match',
      icon: LucideIcons.sparkles,
      unread: true,
    ),
    SampleNotification(
      title: 'Profile viewed',
      body: 'Mekong Data Works looked at your profile.',
      timeAgo: '1d',
      category: AppCategory.gray,
      kind: 'Activity',
      icon: LucideIcons.eye,
      unread: false,
    ),
  ];
}

/* -------------------------------------------------------------------------- */
/* Models                                                                     */
/* -------------------------------------------------------------------------- */

/// Availability is one of the categorical labels — a *kind* of arrangement, not
/// a severity. Borrowing a status colour for these is what stops a real warning
/// from standing out, so each case names a category hue instead.
enum SampleAvailability {
  openToWork('Open to work', AppCategory.brown),
  freelance('Freelance', AppCategory.orange),
  notLooking('Not looking', AppCategory.purple);

  const SampleAvailability(this.label, this.category);

  final String label;
  final AppCategory category;
}

class SampleProfile {
  const SampleProfile({
    required this.name,
    required this.headline,
    required this.location,
    required this.availability,
    required this.skills,
    required this.languages,
    required this.completion,
  });

  final String name;
  final String headline;
  final String location;
  final SampleAvailability availability;
  final List<String> skills;
  final List<String> languages;

  /// 0–1. Drives the profile completion meter.
  final double completion;
}

class SampleCompany {
  const SampleCompany({
    required this.name,
    required this.industry,
    required this.location,
    required this.openRoles,
    required this.size,
    required this.benefits,
    required this.matchScore,
  });

  final String name;
  final String industry;
  final String location;
  final int openRoles;
  final String size;
  final List<String> benefits;
  final int matchScore;
}

class SampleJob {
  const SampleJob({
    required this.title,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.postedAgo,
    required this.matchScore,
    required this.skills,
  });

  final String title;
  final String company;
  final String location;
  final String employmentType;
  final String postedAgo;
  final int matchScore;
  final List<String> skills;
}

class SampleApplication {
  const SampleApplication({
    required this.role,
    required this.company,
    required this.stage,
    required this.status,
    required this.updatedAgo,
  });

  final String role;
  final String company;
  final String stage;
  final AppStatus status;
  final String updatedAgo;
}

class SampleConversation {
  const SampleConversation({
    required this.name,
    required this.company,
    required this.preview,
    required this.timeAgo,
    required this.unread,
    required this.online,
  });

  final String name;
  final String company;
  final String preview;
  final String timeAgo;
  final int unread;
  final bool online;
}

class SampleNotification {
  const SampleNotification({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.category,
    required this.kind,
    required this.icon,
    required this.unread,
  });

  final String title;
  final String body;
  final String timeAgo;
  final AppCategory category;
  final String kind;
  final IconData icon;
  final bool unread;
}
