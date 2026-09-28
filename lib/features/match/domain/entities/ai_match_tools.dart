class AiMatchExplanation {
  const AiMatchExplanation(
      {required this.score,
      required this.verdict,
      required this.explanation,
      required this.strengths,
      required this.gaps});
  factory AiMatchExplanation.fromJson(Map<String, dynamic> json) =>
      AiMatchExplanation(
        score: (json['score'] as num?)?.toInt() ?? 0,
        verdict: '${json['verdict'] ?? 'Match analysis'}',
        explanation: '${json['explanation'] ?? ''}',
        strengths: _strings(json['strengths']),
        gaps: _strings(json['gaps']),
      );
  final int score;
  final String verdict;
  final String explanation;
  final List<String> strengths;
  final List<String> gaps;
}

class SkillGapItem {
  const SkillGapItem(
      {required this.skill,
      required this.criticality,
      required this.positions,
      required this.tip});
  factory SkillGapItem.fromJson(Map<String, dynamic> json) => SkillGapItem(
        skill: '${json['skill'] ?? ''}',
        criticality: '${json['criticality'] ?? 'medium'}',
        positions: _strings(json['positions']),
        tip: '${json['tip'] ?? ''}',
      );
  final String skill;
  final String criticality;
  final List<String> positions;
  final String tip;
}

class SkillGapAnalysis {
  const SkillGapAnalysis(
      {required this.matchedSkills,
      required this.missingSkills,
      required this.overallGap,
      required this.estimatedWeeks,
      required this.topPriority});
  final List<String> matchedSkills;
  final List<SkillGapItem> missingSkills;
  final String overallGap;
  final int estimatedWeeks;
  final String topPriority;
}

class InterviewQuestion {
  const InterviewQuestion(
      {required this.question,
      required this.questionKm,
      required this.category,
      required this.tip,
      required this.tipKm});
  factory InterviewQuestion.fromJson(Map<String, dynamic> json) =>
      InterviewQuestion(
        question: '${json['question'] ?? ''}',
        questionKm: '${json['questionKm'] ?? ''}',
        category: '${json['category'] ?? 'General'}',
        tip: '${json['tip'] ?? ''}',
        tipKm: '${json['tipKm'] ?? ''}',
      );
  final String question;
  final String questionKm;
  final String category;
  final String tip;
  final String tipKm;
}

List<String> _strings(dynamic value) => value is List
    ? value.map((e) => '$e').where((e) => e.isNotEmpty).toList()
    : const [];
