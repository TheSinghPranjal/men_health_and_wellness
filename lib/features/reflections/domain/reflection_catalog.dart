import 'package:flutter/material.dart';

import '../../../app/theme/clay_tokens.dart';
import 'reflection.dart';

const _none = ReflectionOption('none', 'None of these', exclusive: true);
const _unsure = ReflectionOption('unsure', 'Not sure');

const _duration = ReflectionQuestion(
  id: 'duration',
  prompt: 'How long have you noticed this?',
  options: [
    ReflectionOption('lt1m', 'Less than a month'),
    ReflectionOption('1to3m', '1–3 months'),
    ReflectionOption('3to6m', '3–6 months'),
    ReflectionOption('gt6m', 'More than 6 months'),
    _unsure,
  ],
);

const _frequency = ReflectionQuestion(
  id: 'frequency',
  prompt: 'How often does it happen?',
  options: [
    ReflectionOption('rarely', 'Rarely'),
    ReflectionOption('sometimes', 'Sometimes'),
    ReflectionOption('often', 'Often'),
    ReflectionOption('mostly', 'Most or all of the time'),
  ],
);

const _distress = ReflectionQuestion(
  id: 'distress',
  prompt: 'How much is this bothering you?',
  helper: 'Distress matters as much as any symptom.',
  options: [
    ReflectionOption('none', 'Not at all'),
    ReflectionOption('some', 'Somewhat'),
    ReflectionOption('alot', 'A lot'),
  ],
);

abstract final class ReflectionCatalog {
  static const erectile = Reflection(
    id: 'erectile',
    title: 'Erection health reflection',
    subtitle: '8 questions · about 2 minutes',
    intro:
        'Organise your thoughts about erection concerns. Your answers stay on this device and are only saved if you choose. This is not a diagnosis.',
    icon: Icons.favorite_rounded,
    tone: ClayTone.rose,
    questions: [
      _duration,
      _frequency,
      ReflectionQuestion(
        id: 'context',
        prompt: 'Does it happen in every situation?',
        options: [
          ReflectionOption('all', 'In every situation, including alone'),
          ReflectionOption('some', 'Only in some situations'),
          _unsure,
        ],
      ),
      ReflectionQuestion(
        id: 'onset',
        prompt: 'How did it begin?',
        options: [ReflectionOption('gradual', 'Gradually'), ReflectionOption('sudden', 'Suddenly'), _unsure],
      ),
      ReflectionQuestion(
        id: 'changes',
        prompt: 'Has anything changed recently?',
        helper: 'Choose any that apply.',
        type: QuestionType.multi,
        options: [
          ReflectionOption('stress', 'More stress or worry'),
          ReflectionOption('sleep', 'Less or worse sleep'),
          ReflectionOption('medication', 'A new or changed medicine'),
          ReflectionOption('alcohol', 'More alcohol or other substances'),
          ReflectionOption('health', 'A new health condition'),
          ReflectionOption('relationship', 'Relationship changes'),
          _none,
        ],
      ),
      _distress,
      ReflectionQuestion(
        id: 'symptoms',
        prompt: 'Have you also noticed any of these?',
        helper: 'Choose any that apply.',
        type: QuestionType.multi,
        options: [
          ReflectionOption('chest', 'Chest pain or breathlessness on exertion'),
          ReflectionOption('pain', 'Penile pain or a new or worsening curve'),
          ReflectionOption('numbness', 'Numbness in the genitals or legs'),
          ReflectionOption('lowDesire', 'Low desire or persistent tiredness'),
          ReflectionOption('urinary', 'Changes when urinating'),
          _none,
        ],
      ),
      ReflectionQuestion(
        id: 'learnCare',
        prompt: 'Would you like to learn about medical evaluation?',
        options: [ReflectionOption('yes', 'Yes, show me'), ReflectionOption('no', 'Not right now')],
      ),
    ],
  );

  static const ejaculation = Reflection(
    id: 'ejaculation',
    title: 'Ejaculation health reflection',
    subtitle: '7 questions · about 2 minutes',
    intro:
        'Reflect on concerns about ejaculation timing or control. There is no "right" time, and this reflection cannot diagnose anything.',
    icon: Icons.timelapse_rounded,
    tone: ClayTone.lavender,
    questions: [
      ReflectionQuestion(
        id: 'concern',
        prompt: 'Which best describes your concern?',
        options: [
          ReflectionOption('early', 'Ejaculating sooner than I would like'),
          ReflectionOption('delayed', 'Taking much longer than I would like, or not being able to'),
          ReflectionOption('both', 'Both, at different times'),
          _unsure,
        ],
      ),
      ReflectionQuestion(
        id: 'onset',
        prompt: 'When did it start?',
        options: [
          ReflectionOption('lifelong', 'Since my first sexual experiences'),
          ReflectionOption('acquired', 'It developed later'),
          ReflectionOption('varies', 'It comes and goes'),
          _unsure,
        ],
      ),
      _frequency,
      ReflectionQuestion(
        id: 'control',
        prompt: 'How does control feel?',
        options: [
          ReflectionOption('ok', 'I usually feel in control'),
          ReflectionOption('sometimes', 'Control is sometimes difficult'),
          ReflectionOption('hard', 'Control is usually difficult'),
        ],
      ),
      _distress,
      ReflectionQuestion(
        id: 'alsoPresent',
        prompt: 'Are any of these also present?',
        helper: 'Choose any that apply.',
        type: QuestionType.multi,
        options: [
          ReflectionOption('erection', 'Erection difficulties'),
          ReflectionOption('anxiety', 'Anxiety about sex'),
          ReflectionOption('pain', 'Pain with ejaculation or in the pelvis'),
          ReflectionOption('blood', 'Blood in semen or urine'),
          ReflectionOption('medication', 'A recent medicine change'),
          _none,
        ],
      ),
      _duration,
    ],
  );

  static const desire = Reflection(
    id: 'desire',
    title: 'Desire reflection',
    subtitle: '6 questions · about 2 minutes',
    intro:
        'Explore possible influences on changes in sexual desire. Desire varies naturally, and this reflection does not measure hormones.',
    icon: Icons.local_fire_department_rounded,
    tone: ClayTone.peach,
    questions: [
      ReflectionQuestion(
        id: 'pattern',
        prompt: 'What best describes the change?',
        options: [
          ReflectionOption('lower', 'Lower than usual for me'),
          ReflectionOption('mismatch', 'Different from my partner\'s'),
          ReflectionOption('longstanding', 'It has always been low'),
          _unsure,
        ],
      ),
      _duration,
      ReflectionQuestion(
        id: 'influences',
        prompt: 'Which of these are part of your life at the moment?',
        helper: 'Choose any that apply.',
        type: QuestionType.multi,
        options: [
          ReflectionOption('stress', 'Stress or a heavy workload'),
          ReflectionOption('sleep', 'Poor or short sleep'),
          ReflectionOption('relationship', 'Relationship tension or distance'),
          ReflectionOption('medication', 'A new or changed medicine'),
          ReflectionOption('alcohol', 'More alcohol or other substances'),
          ReflectionOption('life', 'A big life change'),
          _none,
        ],
      ),
      ReflectionQuestion(
        id: 'symptoms',
        prompt: 'Have you also noticed any of these?',
        helper: 'Choose any that apply.',
        type: QuestionType.multi,
        options: [
          ReflectionOption('fatigue', 'Tiredness that does not improve with rest'),
          ReflectionOption('mood', 'Low mood or loss of interest most days'),
          ReflectionOption('hormonal', 'Less body hair, breast tenderness, or loss of muscle'),
          ReflectionOption('erection', 'Erection difficulties'),
          _none,
        ],
      ),
      _distress,
      ReflectionQuestion(
        id: 'journal',
        prompt: 'Would a private desire journal be useful?',
        options: [ReflectionOption('yes', 'Yes, maybe'), ReflectionOption('no', 'No thanks')],
      ),
    ],
  );

  static const energy = Reflection(
    id: 'energy',
    title: 'Sleep, stress & energy reflection',
    subtitle: '6 questions · about 2 minutes',
    intro:
        'Look at sleep, stress and tiredness — they affect mood, energy and sexual wellbeing. This is not a mental health assessment.',
    icon: Icons.spa_rounded,
    tone: ClayTone.teal,
    questions: [
      ReflectionQuestion(
        id: 'sleepHours',
        prompt: 'On a typical night, how long do you sleep?',
        options: [
          ReflectionOption('lt6', 'Less than 6 hours'),
          ReflectionOption('6to7', '6–7 hours'),
          ReflectionOption('7to9', '7–9 hours'),
          ReflectionOption('gt9', 'More than 9 hours'),
        ],
      ),
      ReflectionQuestion(
        id: 'sleepQuality',
        prompt: 'How rested do you usually feel on waking?',
        options: [
          ReflectionOption('good', 'Usually rested'),
          ReflectionOption('mixed', 'It varies'),
          ReflectionOption('poor', 'Rarely rested'),
        ],
      ),
      ReflectionQuestion(
        id: 'stress',
        prompt: 'How would you describe your stress lately?',
        options: [
          ReflectionOption('low', 'Manageable'),
          ReflectionOption('moderate', 'Noticeable'),
          ReflectionOption('high', 'Overwhelming at times'),
        ],
      ),
      ReflectionQuestion(
        id: 'fatigueDuration',
        prompt: 'If you feel tired a lot, for how long?',
        options: [
          ReflectionOption('notTired', 'I do not feel tired a lot'),
          ReflectionOption('weeks', 'A few weeks'),
          ReflectionOption('months', 'More than 3 months'),
        ],
      ),
      ReflectionQuestion(
        id: 'symptoms',
        prompt: 'Have you noticed any of these?',
        helper: 'Choose any that apply.',
        type: QuestionType.multi,
        options: [
          ReflectionOption('snoring', 'Loud snoring or pauses in breathing at night'),
          ReflectionOption('sleepy', 'Falling asleep during the day without meaning to'),
          ReflectionOption('mood', 'Low mood or loss of interest most days'),
          ReflectionOption('weight', 'Unexplained weight change'),
          _none,
        ],
      ),
      _distress,
    ],
  );

  static const porn = Reflection(
    id: 'porn',
    title: 'Porn & arousal reflection',
    subtitle: '6 questions · private and judgment-free',
    intro:
        'Explore whether you notice any links between pornography and your sexual experiences. Noticing a pattern does not prove cause, and using pornography is not a disorder.',
    icon: Icons.visibility_rounded,
    tone: ClayTone.slate,
    questions: [
      ReflectionQuestion(
        id: 'partnered',
        prompt: 'Do you notice difficulty becoming aroused with a partner compared with alone?',
        options: [
          ReflectionOption('no', 'No'),
          ReflectionOption('sometimes', 'Sometimes'),
          ReflectionOption('often', 'Often'),
          ReflectionOption('na', 'Not applicable'),
        ],
      ),
      ReflectionQuestion(
        id: 'mismatch',
        prompt: 'Do the kind or intensity of stimulation you prefer alone differ from partnered intimacy?',
        options: [
          ReflectionOption('no', 'No'),
          ReflectionOption('somewhat', 'Somewhat'),
          ReflectionOption('alot', 'A lot'),
          _unsure,
        ],
      ),
      ReflectionQuestion(
        id: 'control',
        prompt: 'Do you find it hard to cut back when you want to?',
        options: [
          ReflectionOption('no', 'No'),
          ReflectionOption('sometimes', 'Sometimes'),
          ReflectionOption('often', 'Often'),
        ],
      ),
      ReflectionQuestion(
        id: 'time',
        prompt: 'Does it take time away from sleep, work or relationships?',
        options: [
          ReflectionOption('no', 'No'),
          ReflectionOption('sometimes', 'Sometimes'),
          ReflectionOption('often', 'Often'),
        ],
      ),
      _distress,
      ReflectionQuestion(
        id: 'experiment',
        prompt: 'Would you be interested in a private, self-directed experiment?',
        helper: 'You set the goal. No streaks, no judgment, stop any time.',
        options: [ReflectionOption('yes', 'Maybe — show me'), ReflectionOption('no', 'Not now')],
      ),
    ],
  );

  static const all = [erectile, ejaculation, desire, energy, porn];

  static Reflection? byId(String id) => all.where((r) => r.id == id).firstOrNull;
}
