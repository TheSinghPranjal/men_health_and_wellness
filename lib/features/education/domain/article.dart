import 'package:flutter/material.dart';

import '../../../app/theme/clay_tokens.dart';

enum ArticleCategory {
  physiology(
    'How it works',
    'Desire, arousal, erection and orgasm explained',
    'Understand how the male body, brain and hormones work together for sexual health.',
    Icons.hub_rounded,
    ClayTone.blue,
  ),
  erectile(
    'Erectile health',
    'Erections, ED, and what affects them',
    'Learn about erections, common concerns and evidence-based solutions.',
    Icons.favorite_rounded,
    ClayTone.rose,
  ),
  desire(
    'Libido & desire',
    'Why desire changes and what helps',
    'Explore why desire rises and falls, what affects it and how to support a healthy libido.',
    Icons.local_fire_department_rounded,
    ClayTone.peach,
  ),
  ejaculation(
    'Ejaculation health',
    'Control, timing and orgasm concerns',
    'Understand early and delayed ejaculation, orgasm concerns and techniques that help.',
    Icons.timelapse_rounded,
    ClayTone.lavender,
  ),
  intimacy(
    'Intimacy & communication',
    'Foreplay, consent and talking together',
    'Foreplay, consent, partner support and communication tips for stronger relationships.',
    Icons.forum_rounded,
    ClayTone.teal,
  ),
  porn(
    'Porn & expectations',
    'A balanced, judgment-free look',
    'Understand the effects, the myths and how to build habits that feel right for you.',
    Icons.visibility_rounded,
    ClayTone.slate,
  ),
  ageHormones(
    'Age & hormones',
    'Ageing, testosterone and fertility',
    'What really changes with age, how testosterone works and what it means for fertility.',
    Icons.timeline_rounded,
    ClayTone.sand,
  ),
  lifestyle(
    'Lifestyle',
    'Exercise, food, sleep, substances, pelvic floor',
    'Exercise, nutrition, sleep and everyday habits that support better sexual health.',
    Icons.eco_rounded,
    ClayTone.sage,
  ),
  stressSleep(
    'Stress & energy',
    'Anxiety, fatigue and recovery',
    'Manage stress, anxiety and fatigue, and build the energy and confidence you need.',
    Icons.spa_rounded,
    ClayTone.teal,
  ),
  treatments(
    'Treatments',
    'Medical options, testosterone and supplements',
    'An honest look at medical treatments, testosterone therapy and supplement claims.',
    Icons.medication_rounded,
    ClayTone.blue,
  ),
  safety(
    'Care & safety',
    'When to see a clinician and emergencies',
    'Know when to talk to a clinician, what to expect and which symptoms need urgent care.',
    Icons.medical_services_rounded,
    ClayTone.rose,
  );

  const ArticleCategory(this.label, this.description, this.intro, this.icon, this.tone);
  final String label;
  final String description;

  /// One-sentence overview shown at the top of the topic screen.
  final String intro;
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
  const ArticleSection({
    required this.heading,
    this.paragraphs = const [],
    this.bullets = const [],
    this.comparison = const [],
    this.note,
  });
  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;

  /// Optional side-by-side concept cards, e.g. desire vs arousal.
  final List<ConceptCard> comparison;

  /// Optional "Important to know" callout shown after the section body.
  final String? note;

  /// Every piece of prose in the section, for search, checks and read time.
  List<String> get text => [
    ...paragraphs,
    for (final c in comparison) ...[c.body, ...c.examples],
    ?note,
    ...bullets,
  ];
}

/// A titled concept with a short definition and examples.
@immutable
class ConceptCard {
  const ConceptCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    required this.tone,
    this.examples = const [],
  });
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  final ClayTone tone;
  final List<String> examples;
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
      for (final s in sections) ...s.text,
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
