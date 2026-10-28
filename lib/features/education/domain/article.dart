import 'package:flutter/material.dart';

import '../../../app/theme/clay_tokens.dart';

enum ArticleCategory {
  physiology('How it works', 'Desire, arousal, erection and orgasm explained', Icons.hub_rounded, ClayTone.blue),
  erectile('Erectile health', 'Erections, ED, and what affects them', Icons.favorite_rounded, ClayTone.rose),
  desire('Libido & desire', 'Why desire changes and what helps', Icons.local_fire_department_rounded, ClayTone.peach),
  ejaculation('Ejaculation health', 'Control, timing and orgasm concerns', Icons.timelapse_rounded, ClayTone.lavender),
  intimacy('Intimacy & communication', 'Foreplay, consent and talking together', Icons.forum_rounded, ClayTone.teal),
  porn('Porn & expectations', 'A balanced, judgment-free look', Icons.visibility_rounded, ClayTone.slate),
  ageHormones('Age & hormones', 'Ageing, testosterone and fertility', Icons.timeline_rounded, ClayTone.sand),
  lifestyle('Lifestyle', 'Exercise, food, sleep, substances, pelvic floor', Icons.eco_rounded, ClayTone.sage),
  stressSleep('Stress & energy', 'Anxiety, fatigue and recovery', Icons.spa_rounded, ClayTone.teal),
  treatments('Treatments', 'Medical options, testosterone and supplements', Icons.medication_rounded, ClayTone.blue),
  safety('Care & safety', 'When to see a clinician and emergencies', Icons.medical_services_rounded, ClayTone.rose);

  const ArticleCategory(this.label, this.description, this.icon, this.tone);
  final String label;
  final String description;
  final IconData icon;
  final ClayTone tone;
}

enum ReviewStatus {
  /// Written from cited public guidance but not yet signed off by a
  /// qualified clinician. Shown to users as-is; see docs/CONTENT_REVIEW.md.
  pendingClinicalReview('Awaiting clinical review'),
  clinicallyReviewed('Clinically reviewed');

  const ReviewStatus(this.label);
  final String label;
}

@immutable
class Source {
  const Source({required this.id, required this.title, required this.publisher, required this.url});
  final String id;
  final String title;
  final String publisher;
  final String url;
}

@immutable
class ArticleSection {
  const ArticleSection({required this.heading, this.paragraphs = const [], this.bullets = const []});
  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

@immutable
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.sections,
    required this.evidenceSupports,
    required this.uncertain,
    required this.nextSteps,
    required this.seeClinician,
    required this.sources,
    this.safetyWarnings = const [],
    this.keywords = const [],
    this.related = const [],
    this.version = 1,
    this.locale = 'en',
    this.reviewStatus = ReviewStatus.pendingClinicalReview,
    this.authoredOn = '2026-10-28',
    this.nextReviewOn = '2027-04-28',
  });

  final String id;
  final String title;
  final String summary;
  final ArticleCategory category;
  final List<ArticleSection> sections;
  final List<String> evidenceSupports;
  final List<String> uncertain;
  final List<String> nextSteps;
  final List<String> seeClinician;
  final List<String> safetyWarnings;
  final List<Source> sources;
  final List<String> keywords;
  final List<String> related;
  final int version;
  final String locale;
  final ReviewStatus reviewStatus;

  /// ISO dates (yyyy-mm-dd).
  final String authoredOn;
  final String nextReviewOn;

  int get readMinutes {
    final words = [
      summary,
      for (final s in sections) ...[...s.paragraphs, ...s.bullets],
      ...evidenceSupports,
      ...uncertain,
      ...nextSteps,
      ...seeClinician,
    ].fold<int>(0, (n, t) => n + t.split(' ').length);
    return (words / 200).ceil().clamp(1, 60);
  }
}

@immutable
class Myth {
  const Myth({
    required this.id,
    required this.myth,
    required this.evidence,
    required this.sources,
    this.relatedArticle,
  });
  final String id;
  final String myth;
  final String evidence;
  final List<Source> sources;
  final String? relatedArticle;
}
