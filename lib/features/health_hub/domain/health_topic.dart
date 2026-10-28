import 'package:flutter/material.dart';

import '../../../app/theme/clay_tokens.dart';
import '../../education/domain/article.dart';

enum TopicTool { clinicianPrep, experiment, checkIn, habit, breathing, relaxation, grounding }

@immutable
class HealthTopic {
  const HealthTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.icon,
    required this.tone,
    required this.categories,
    this.reflectionId,
    this.tools = const [],
    this.guideTitle,
    this.guide = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String intro;
  final IconData icon;
  final ClayTone tone;
  final List<ArticleCategory> categories;
  final String? reflectionId;
  final List<TopicTool> tools;

  /// Optional short practical guide shown on the topic page.
  final String? guideTitle;
  final List<String> guide;
}

abstract final class HealthTopics {
  static const all = <HealthTopic>[
    HealthTopic(
      id: 'erectile',
      title: 'Erectile health',
      subtitle: 'How erections work and what affects them',
      intro:
          'Erections depend on blood vessels, nerves, hormones and your state of mind. Occasional difficulty is common; persistent difficulty is worth checking — it can be an early signal about heart health.',
      icon: Icons.favorite_rounded,
      tone: ClayTone.rose,
      categories: [ArticleCategory.erectile, ArticleCategory.physiology],
      reflectionId: 'erectile',
      tools: [TopicTool.clinicianPrep, TopicTool.breathing],
    ),
    HealthTopic(
      id: 'desire',
      title: 'Libido & desire',
      subtitle: 'Understand changes in sexual interest',
      intro:
          'Desire naturally varies with stress, sleep, mood, relationships and health. Low desire is not a character flaw, and it does not automatically mean low testosterone.',
      icon: Icons.local_fire_department_rounded,
      tone: ClayTone.peach,
      categories: [ArticleCategory.desire],
      reflectionId: 'desire',
      tools: [TopicTool.checkIn],
    ),
    HealthTopic(
      id: 'ejaculation',
      title: 'Ejaculation health',
      subtitle: 'Control, timing and orgasm concerns',
      intro:
          'Concerns about ejaculating too soon or too late are common and workable. Success is about control and satisfaction — not a number of minutes.',
      icon: Icons.timelapse_rounded,
      tone: ClayTone.lavender,
      categories: [ArticleCategory.ejaculation],
      reflectionId: 'ejaculation',
      tools: [TopicTool.breathing, TopicTool.clinicianPrep],
      guideTitle: 'Practising awareness (solo, no pressure)',
      guide: [
        'Notice arousal as a 1–10 scale rather than on/off.',
        'When you reach about 7, pause and breathe slowly until it settles.',
        'Resume, and repeat a few times before allowing ejaculation.',
        'Keep it low-pressure: the goal is noticing, not a time target.',
        'Results vary and take weeks. A therapist can tailor this approach.',
      ],
    ),
    HealthTopic(
      id: 'intimacy',
      title: 'Arousal & intimacy',
      subtitle: 'Foreplay, consent and communication',
      intro:
          'Intimacy is about connection, comfort and mutual enjoyment. Arousal takes time, varies day to day, and penetration is only one option among many.',
      icon: Icons.forum_rounded,
      tone: ClayTone.teal,
      categories: [ArticleCategory.intimacy],
      guideTitle: 'Conversation starters',
      guide: [
        '"What helps you feel comfortable and connected?"',
        '"Would you like to slow down or try something different?"',
        '"How can we make intimacy feel less pressured?"',
        '"Would you like us to explore this together or speak with a professional?"',
        '"Can we agree on a simple word for \'pause\'?"',
      ],
    ),
    HealthTopic(
      id: 'stress',
      title: 'Stress, sleep & energy',
      subtitle: 'Recover, relax and recharge',
      intro:
          'Stress and tiredness are among the most common reasons for changes in desire and arousal. Small, consistent recovery habits add up.',
      icon: Icons.spa_rounded,
      tone: ClayTone.teal,
      categories: [ArticleCategory.stressSleep],
      reflectionId: 'energy',
      tools: [TopicTool.breathing, TopicTool.relaxation, TopicTool.grounding, TopicTool.checkIn],
    ),
    HealthTopic(
      id: 'lifestyle',
      title: 'Nutrition & exercise',
      subtitle: 'Heart health is sexual health',
      intro:
          'What supports your heart and blood vessels also supports erections, energy and mood. Start small: realistic changes last longer than dramatic ones.',
      icon: Icons.eco_rounded,
      tone: ClayTone.sage,
      categories: [ArticleCategory.lifestyle],
      tools: [TopicTool.habit],
    ),
    HealthTopic(
      id: 'porn',
      title: 'Porn & expectations',
      subtitle: 'A private, judgment-free look',
      intro:
          'Evidence on pornography and sexual function is mixed. Some people notice effects on expectations or arousal; many do not. Explore only if it is useful to you.',
      icon: Icons.visibility_rounded,
      tone: ClayTone.slate,
      categories: [ArticleCategory.porn],
      reflectionId: 'porn',
      tools: [TopicTool.experiment],
    ),
    HealthTopic(
      id: 'treatments',
      title: 'Treatments & hormones',
      subtitle: 'Medical options, testosterone, supplements',
      intro:
          'Effective treatments exist for many concerns. They depend on the cause and your health, and they need a clinician. This app never prescribes or doses medicines.',
      icon: Icons.medication_rounded,
      tone: ClayTone.blue,
      categories: [ArticleCategory.treatments, ArticleCategory.ageHormones],
      tools: [TopicTool.clinicianPrep],
    ),
  ];

  static HealthTopic? byId(String id) => all.where((t) => t.id == id).firstOrNull;
}
