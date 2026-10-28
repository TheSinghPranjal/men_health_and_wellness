import 'reflection.dart';

/// Deterministic, transparent rules that turn answers into a neutral,
/// non-diagnostic summary. Every rule maps to plain public-health guidance;
/// none assigns a condition or severity.
class ReflectionRules {
  const ReflectionRules();

  ReflectionOutcome evaluate(Reflection reflection, ReflectionAnswers answers) {
    final b = _Builder(reflection, answers);
    switch (reflection.id) {
      case 'erectile':
        _erectile(b);
      case 'ejaculation':
        _ejaculation(b);
      case 'desire':
        _desire(b);
      case 'energy':
        _energy(b);
      case 'porn':
        _porn(b);
    }
    return b.build();
  }

  void _erectile(_Builder b) {
    b.article('understanding-ed');
    final persistent = b.any('duration', {'3to6m', 'gt6m'}) && b.any('frequency', {'often', 'mostly'});

    if (b.has('symptoms', 'chest')) {
      b.care(
        CareLevel.prompt,
        'Chest pain or breathlessness on exertion should be checked by a clinician soon. If it happens during sex or at rest, stop and seek emergency care.',
      );
      b.article('emergency-signs');
    }
    if (b.has('symptoms', 'numbness')) {
      b.care(CareLevel.prompt, 'New numbness in the genitals or legs should be assessed promptly.');
    }
    if (b.has('onset', 'sudden')) {
      b.care(CareLevel.appointment, 'A sudden change in erections is worth discussing with a clinician.');
    }
    if (persistent) {
      b.care(
        CareLevel.appointment,
        'Difficulties that are frequent and have lasted several months are a common reason to see a clinician.',
      );
      b.point(
        'Erection difficulties share risk factors with heart health. A check of blood pressure, blood sugar and cholesterol may be worthwhile.',
      );
    }
    if (b.has('distress', 'alot')) {
      b.care(CareLevel.appointment, 'This is bothering you a lot, and that alone is a good reason to get support.');
    }
    if (b.has('symptoms', 'pain')) {
      b.care(CareLevel.appointment, 'Penile pain or a new or worsening curve should be checked by a clinician.');
    }
    if (b.has('symptoms', 'urinary')) {
      b.care(CareLevel.appointment, 'Changes when urinating are worth mentioning to a clinician.');
    }
    if (b.has('changes', 'medication')) {
      b.care(
        CareLevel.discuss,
        'A new or changed medicine could be relevant. Ask your prescriber — do not stop it on your own.',
      );
    }
    if (b.any('frequency', {'sometimes', 'often', 'mostly'}) || b.has('duration', '1to3m')) {
      b.care(CareLevel.discuss, 'If this continues, it is reasonable to mention it at a check-up.');
    }

    if (b.has('context', 'some')) {
      b.point(
        'Difficulty that happens only in some situations often has a strong situational or emotional component, although physical factors can still play a part.',
      );
      b.article('performance-anxiety');
    }
    if (b.has('context', 'all')) {
      b.point(
        'Difficulty in every situation, including alone, can point to physical contributors that are worth checking.',
      );
      b.article('ed-causes');
    }
    if (b.has('changes', 'stress')) {
      b.point(
        'Stress works against the relaxation erections need. Short breathing practices may help you step out of "monitoring mode".',
      );
      b.article('performance-anxiety');
    }
    if (b.has('changes', 'sleep')) {
      b.point(
        'Sleep affects energy, mood and arousal. Small changes to your sleep routine are a practical place to start.',
      );
      b.article('sleep-and-sexual-wellbeing');
    }
    if (b.has('changes', 'alcohol')) {
      b.point('Alcohol and some substances can directly affect erections.');
      b.article('alcohol-smoking-substances');
    }
    if (b.has('changes', 'relationship')) {
      b.point('Relationship changes can affect arousal. A calm, blame-free conversation may help.');
      b.article('talking-with-partner');
    }
    if (b.has('symptoms', 'lowDesire')) {
      b.point(
        'Low desire or tiredness alongside erection changes has many possible causes; a clinician can help look at the whole picture.',
      );
      b.article('libido-contributors');
    }
    if (b.any('frequency', {'rarely'}) && !persistent) {
      b.point('Occasional difficulty is common and often linked to tiredness, stress or alcohol.');
      b.article('erection-variability');
    }
    if (b.has('learnCare', 'yes')) {
      b.article('when-to-see-clinician');
      b.article('ed-treatments');
    }
  }

  void _ejaculation(_Builder b) {
    final delayed = b.any('concern', {'delayed', 'both'});
    final early = b.any('concern', {'early', 'both', 'unsure'});
    if (early) b.article('understanding-pe');
    if (delayed) b.article('delayed-ejaculation');

    if (b.has('alsoPresent', 'blood')) {
      b.care(CareLevel.appointment, 'Blood in semen or urine should be checked by a clinician.');
    }
    if (b.has('alsoPresent', 'pain')) {
      b.care(CareLevel.appointment, 'Pain with ejaculation or in the pelvis should be assessed by a clinician.');
    }
    if (b.has('distress', 'alot') || (b.any('duration', {'3to6m', 'gt6m'}) && b.any('control', {'hard'}))) {
      b.care(
        CareLevel.appointment,
        'Persistent difficulty with control, or significant distress, is a good reason to talk to a clinician or psychosexual therapist.',
      );
    }
    if (b.has('alsoPresent', 'medication')) {
      b.care(
        CareLevel.discuss,
        'A recent medicine change may be relevant. Ask your prescriber before changing anything.',
      );
    }
    if (b.any('frequency', {'often', 'mostly'})) {
      b.care(CareLevel.discuss, 'If this keeps happening, it is reasonable to raise it at a check-up.');
    }

    if (b.has('alsoPresent', 'erection')) {
      b.point(
        'Erection difficulties and early ejaculation can feed each other. Guidelines usually suggest addressing erection concerns first.',
      );
      b.article('ed-and-pe');
    }
    if (b.has('alsoPresent', 'anxiety')) {
      b.point(
        'Anxiety raises arousal and tension at the same time, which can speed ejaculation. Breathing and slowing down may help.',
      );
      b.article('performance-anxiety');
    }
    if (b.has('onset', 'varies')) {
      b.point(
        'Timing that comes and goes is common and often reflects circumstances such as a new partner, stress or time since last ejaculation.',
      );
    }
    if (b.has('control', 'ok') && b.any('distress', {'some', 'alot'})) {
      b.point(
        'You report usually feeling in control but still feel worried. Expectations about timing are often shaped by unrealistic comparisons.',
      );
      b.article('porn-and-expectations');
    }
    if (early) {
      b.point('Behavioural techniques such as start–stop and relaxed breathing help some people, though results vary.');
      b.article('pe-techniques');
    }
  }

  void _desire(_Builder b) {
    b.article('libido-variation');
    if (b.has('symptoms', 'mood')) {
      b.care(
        CareLevel.appointment,
        'Low mood or loss of interest most days deserves support. A doctor can help, and talking to someone you trust can too.',
      );
      b.mentalHealth();
    }
    if (b.has('symptoms', 'hormonal')) {
      b.care(
        CareLevel.appointment,
        'Some of the changes you noted can have hormonal causes. A clinician can decide whether testing is appropriate.',
      );
      b.article('testosterone-facts');
    }
    if (b.has('symptoms', 'fatigue')) {
      b.care(
        CareLevel.discuss,
        'Tiredness that does not improve with rest is worth checking; it has many possible causes.',
      );
      b.article('fatigue-and-energy');
    }
    if (b.has('distress', 'alot')) {
      b.care(CareLevel.appointment, 'This is bothering you a lot, which is reason enough to seek support.');
    }
    if (b.has('influences', 'medication')) {
      b.care(CareLevel.discuss, 'A medicine change may affect desire. Ask your prescriber rather than stopping it.');
    }
    if (b.any('duration', {'3to6m', 'gt6m'}) && b.has('pattern', 'lower')) {
      b.care(CareLevel.discuss, 'A drop in desire lasting several months is reasonable to raise at a check-up.');
    }

    if (b.has('influences', 'stress')) b.point('Stress is one of the most common reasons for lower desire.');
    if (b.has('influences', 'sleep')) {
      b.point('Short or poor sleep can reduce energy and interest in sex.');
      b.article('sleep-and-sexual-wellbeing');
    }
    if (b.has('influences', 'relationship') || b.has('pattern', 'mismatch')) {
      b.point(
        'Differences in desire between partners are common and not a disorder. Connection and low-pressure communication tend to help.',
      );
      b.article('talking-with-partner');
    }
    if (b.has('influences', 'alcohol')) b.point('Alcohol and other substances can reduce desire over time.');
    if (b.has('influences', 'life')) b.point('Big life changes often affect desire for a while.');
    if (b.has('symptoms', 'erection')) b.article('understanding-ed');
    b.point('Low desire alone does not mean low testosterone.');
    b.article('libido-contributors');
  }

  void _energy(_Builder b) {
    b.article('fatigue-and-energy');
    if (b.has('symptoms', 'mood')) {
      b.care(
        CareLevel.appointment,
        'Low mood or loss of interest most days deserves support from a doctor or mental health professional.',
      );
      b.mentalHealth();
    }
    if (b.has('symptoms', 'snoring') || b.has('symptoms', 'sleepy')) {
      b.care(
        CareLevel.appointment,
        'Loud snoring, breathing pauses or unplanned daytime sleep can be signs of sleep apnoea, which is treatable.',
      );
      b.article('sleep-and-sexual-wellbeing');
    }
    if (b.has('symptoms', 'weight')) {
      b.care(CareLevel.appointment, 'Unexplained weight change alongside tiredness should be checked by a clinician.');
    }
    if (b.has('fatigueDuration', 'months')) {
      b.care(
        CareLevel.appointment,
        'Tiredness lasting more than a few months deserves a check-up; causes include anaemia, thyroid problems and others.',
      );
    }
    if (b.has('stress', 'high') || b.has('distress', 'alot')) {
      b.care(CareLevel.discuss, 'If stress feels overwhelming, talking to a clinician or counsellor can help.');
      b.article('performance-anxiety');
    }

    if (b.has('sleepHours', 'lt6')) {
      b.point('Most adults need around 7–9 hours. A consistent wind-down routine is a practical first step.');
    }
    if (b.has('sleepQuality', 'poor')) {
      b.point('Waking unrefreshed is worth paying attention to, even with enough hours in bed.');
    }
    if (b.any('stress', {'moderate', 'high'})) {
      b.point('Short daily breathing or relaxation practice may help with stress.');
    }
    b.point('Tiredness has many possible causes and is not, on its own, a sign of low testosterone.');
  }

  void _porn(_Builder b) {
    b.article('porn-and-expectations');
    final control = b.has('control', 'often');
    final impact = b.has('time', 'often');
    if ((control || impact) && b.has('distress', 'alot')) {
      b.care(
        CareLevel.appointment,
        'Finding it hard to cut back, alongside significant distress, is a good reason to talk with a psychologist or sex therapist. Support is non-judgmental.',
      );
    } else if (control || impact) {
      b.care(
        CareLevel.discuss,
        'If difficulty cutting back continues or starts to affect daily life, professional support is available.',
      );
    }
    if (b.any('partnered', {'sometimes', 'often'})) {
      b.point(
        'Differences between solo and partnered arousal are common and have many possible causes, including anxiety, tiredness and context.',
      );
      b.article('performance-anxiety');
    }
    if (b.any('mismatch', {'somewhat', 'alot'})) {
      b.point(
        'Some people find that varying solo habits makes partnered intimacy feel different. Exploring this is optional.',
      );
      b.article('foreplay-and-arousal');
    }
    b.point(
      'These patterns do not prove that pornography is causing anything, and using it does not make you addicted.',
    );
    if (b.has('experiment', 'yes')) b.experiment();
  }
}

class _Builder {
  _Builder(this.reflection, this.answers);
  final Reflection reflection;
  final ReflectionAnswers answers;

  CareLevel _care = CareLevel.selfCare;
  final _reasons = <String>[];
  final _points = <String>[];
  final _articles = <String>[];
  bool _mental = false;
  bool _experiment = false;

  bool has(String q, String option) => answers[q]?.contains(option) ?? false;
  bool any(String q, Set<String> options) => answers[q]?.any(options.contains) ?? false;

  void care(CareLevel level, String reason) {
    if (level.index > _care.index) _care = level;
    if (!_reasons.contains(reason)) _reasons.add(reason);
  }

  void point(String p) {
    if (!_points.contains(p)) _points.add(p);
  }

  void article(String id) {
    if (!_articles.contains(id)) _articles.add(id);
  }

  void mentalHealth() => _mental = true;
  void experiment() => _experiment = true;

  ReflectionOutcome build() {
    final summary = <(String, String)>[];
    for (final q in reflection.questions) {
      final chosen = answers[q.id];
      if (chosen == null || chosen.isEmpty) continue;
      summary.add((q.prompt, chosen.map(q.labelFor).join(', ')));
    }
    if (_care.index >= CareLevel.discuss.index) article('when-to-see-clinician');
    return ReflectionOutcome(
      answerSummary: summary,
      reflectionPoints: _points,
      careLevel: _care,
      careReasons: _reasons,
      articleIds: _articles,
      showMentalHealthSupport: _mental,
      showExperiment: _experiment,
    );
  }
}
