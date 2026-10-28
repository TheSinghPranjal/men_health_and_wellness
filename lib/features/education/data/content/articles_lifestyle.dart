import '../../domain/article.dart';
import 'sources.dart';

/// Lifestyle, stress and recovery.
const lifestyleArticles = <Article>[
  Article(
    id: 'exercise-for-sexual-health',
    title: 'Movement for vascular and sexual health',
    summary:
        'Regular activity supports the heart and blood vessels that erections rely on, plus mood, sleep and energy. Start where you are and build gradually.',
    category: ArticleCategory.lifestyle,
    keywords: ['exercise', 'walking', 'cardio', 'strength training', 'fitness', 'activity', '150 minutes'],
    related: ['eating-for-vascular-health', 'healthy-weight', 'pelvic-floor'],
    sections: [
      ArticleSection(
        heading: 'A general target',
        paragraphs: [
          'Public health guidance for adults suggests at least 150 minutes of moderate activity (such as brisk walking) or 75 minutes of vigorous activity a week, plus strengthening activities on at least two days, and reducing long periods of sitting.',
          'That is a target, not an entry requirement. Any increase from your starting point counts, and activity should be adapted to your health and abilities.',
        ],
      ),
      ArticleSection(
        heading: 'Making it realistic',
        bullets: [
          'Start with 10-minute walks and add a few minutes each week.',
          'Choose activities you enjoy enough to repeat.',
          'Break up long sitting with short movement breaks.',
          'Add simple strength work, such as body-weight exercises, twice a week.',
        ],
      ),
    ],
    evidenceSupports: [
      'Physical inactivity is a risk factor for ED, and activity improves cardiovascular risk factors linked to ED.',
    ],
    uncertain: ['The amount of improvement in erectile function from exercise alone varies between individuals.'],
    nextSteps: ['Create a walking habit in the Progress tab.'],
    seeClinician: [
      'Before starting vigorous exercise if you have heart disease, chest pain, or other significant health conditions.',
    ],
    sources: [Src.nhsActivity, Src.niddkEdCauses, Src.eauSexual],
  ),
  Article(
    id: 'eating-for-vascular-health',
    title: 'Eating for your heart (and everything it supplies)',
    summary:
        'Eating patterns that support the heart, blood pressure and blood sugar also support erectile health. No single food is a proven aphrodisiac.',
    category: ArticleCategory.lifestyle,
    keywords: ['diet', 'food', 'nutrition', 'mediterranean', 'aphrodisiac', 'vegetables', 'eating'],
    related: ['exercise-for-sexual-health', 'healthy-weight', 'supplements-guide'],
    sections: [
      ArticleSection(
        heading: 'Patterns that help',
        bullets: [
          'Plenty of vegetables and fruit.',
          'Whole grains instead of refined grains.',
          'Legumes, nuts and seeds.',
          'Fish, poultry and plant proteins more often than processed meats.',
          'Unsaturated fats such as olive oil.',
          'Fewer highly processed foods, sugary drinks and added sugars.',
          'Portions that suit your appetite and activity.',
        ],
      ),
      ArticleSection(
        heading: 'About "superfoods"',
        paragraphs: [
          'You will see claims that specific foods boost erections or testosterone. There is no good evidence that any single food reliably improves sexual function. The benefit comes from an overall pattern over time, mostly through blood vessel and metabolic health.',
        ],
      ),
    ],
    evidenceSupports: [
      'NIDDK notes that eating patterns that help prevent diabetes, heart disease and obesity may lower ED risk.',
    ],
    uncertain: ['Most diet and ED evidence is observational.'],
    nextSteps: ['Add one extra portion of vegetables a day this week.'],
    seeClinician: ['A dietitian can help if you have diabetes, high cholesterol or other conditions affected by diet.'],
    sources: [Src.niddkEdDiet, Src.nhsEatWell],
  ),
  Article(
    id: 'sleep-and-sexual-wellbeing',
    title: 'Sleep and sexual wellbeing',
    summary:
        'Short or poor-quality sleep affects mood, energy, stress and desire. Loud snoring with daytime sleepiness can be a sign of sleep apnoea, which is worth checking.',
    category: ArticleCategory.lifestyle,
    keywords: ['sleep', 'insomnia', 'tired', 'sleep apnoea', 'sleep apnea', 'snoring', 'rest'],
    related: ['fatigue-and-energy', 'libido-contributors', 'morning-erections'],
    sections: [
      ArticleSection(
        heading: 'Habits that support sleep',
        bullets: [
          'Keep similar sleep and wake times, including weekends.',
          'Keep the bedroom dark, quiet and cool.',
          'Wind down without screens for a while before bed.',
          'Limit caffeine later in the day and avoid heavy alcohol before bed.',
          'Get daylight and activity during the day.',
        ],
      ),
      ArticleSection(
        heading: 'Possible sleep apnoea',
        paragraphs: [
          'Signs include loud snoring, pauses in breathing noticed by a partner, waking with a choking sensation, and feeling very sleepy during the day. Sleep apnoea is treatable and worth discussing with a clinician.',
        ],
      ),
      ArticleSection(
        heading: 'Tiredness does not mean low testosterone',
        paragraphs: ['Feeling tired has many causes. It is not, on its own, a sign of low testosterone.'],
      ),
    ],
    evidenceSupports: [
      'Poor sleep is linked with low mood, stress and reduced libido; sleep apnoea is associated with ED.',
    ],
    uncertain: ['How much improving sleep improves sexual function differs from person to person.'],
    nextSteps: ['Set a consistent wind-down habit with an optional reminder.'],
    seeClinician: ['If you snore loudly, stop breathing during sleep, or feel very sleepy in the day.'],
    sources: [Src.nhsSleep, Src.nhsSleepApnoea, Src.nhsTired],
  ),
  Article(
    id: 'alcohol-smoking-substances',
    title: 'Alcohol, smoking and other substances',
    summary:
        'Smoking damages blood vessels, heavy drinking can impair erections short and long term, and some recreational drugs affect sexual function. Cutting down helps your whole body.',
    category: ArticleCategory.lifestyle,
    keywords: ['alcohol', 'drinking', 'smoking', 'vaping', 'drugs', 'cannabis', 'quit'],
    related: ['ed-causes', 'exercise-for-sexual-health'],
    sections: [
      ArticleSection(
        heading: 'How they affect sexual function',
        bullets: [
          'Smoking damages blood vessels and is a recognised risk factor for ED.',
          'Alcohol can make erections harder to get or keep in the moment; heavy long-term use can affect nerves, hormones and desire.',
          'Some recreational drugs can impair erections, desire or ejaculation, and some interact dangerously with ED medicines.',
        ],
      ),
      ArticleSection(
        heading: 'Non-judgmental ways to cut down',
        bullets: [
          'Track how much you actually drink for a week.',
          'Have alcohol-free days each week.',
          'Swap to smaller or lower-strength drinks.',
          'Use free stop-smoking services; combining support with nicotine replacement improves your chances.',
        ],
      ),
      ArticleSection(
        heading: 'Not a confidence tool',
        paragraphs: [
          'Using alcohol or drugs to manage nerves around sex can backfire, reducing sensitivity and making erections less reliable.',
        ],
      ),
    ],
    evidenceSupports: ['NIDDK lists smoking and heavy alcohol or drug use among causes of ED.'],
    uncertain: ['How quickly erectile function improves after quitting smoking varies.'],
    nextSteps: ['Choose one small change and add it as a habit.'],
    seeClinician: ['If you find it hard to cut down, local services and your clinician can help without judgment.'],
    sources: [Src.niddkEdCauses, Src.nhsQuitSmoking, Src.nhsAlcohol],
  ),
  Article(
    id: 'healthy-weight',
    title: 'Weight, metabolism and erections',
    summary:
        'Blood pressure, blood sugar and cholesterol all affect the blood vessels erections depend on. Small, sustainable changes beat restrictive diets.',
    category: ArticleCategory.lifestyle,
    keywords: ['weight', 'diabetes', 'blood sugar', 'metabolic', 'blood pressure', 'cholesterol'],
    related: ['eating-for-vascular-health', 'exercise-for-sexual-health', 'understanding-ed'],
    sections: [
      ArticleSection(
        heading: 'The connection',
        paragraphs: [
          'Diabetes, high blood pressure and high cholesterol can damage blood vessels and nerves over time. Managing them supports erectile health along with your heart, kidneys and eyes.',
          'This is about health, not appearance. Bodies come in many shapes, and shame does not help anyone change.',
        ],
      ),
      ArticleSection(
        heading: 'Steps that help',
        bullets: [
          'Know your numbers: ask for blood pressure, blood sugar and cholesterol checks.',
          'Build regular activity and balanced meals gradually.',
          'Take prescribed medicines for these conditions as directed.',
        ],
      ),
    ],
    evidenceSupports: ['Diabetes, high blood pressure and high cholesterol are established ED risk factors.'],
    uncertain: ['The effect of weight change on erectile function varies between individuals.'],
    nextSteps: ['Ask for a routine health check if you have not had one recently.'],
    seeClinician: ['For support with weight, blood sugar or blood pressure management.'],
    sources: [Src.nhsHealthyWeight, Src.niddkEdCauses],
  ),
  Article(
    id: 'pelvic-floor',
    title: 'Pelvic floor health: benefits and limits',
    summary:
        'Pelvic floor training may help some men with erection or ejaculation concerns, but it is not right for everyone. Some people need to learn to relax these muscles instead.',
    category: ArticleCategory.lifestyle,
    keywords: ['kegel', 'pelvic floor', 'PC muscle', 'pelvic pain', 'physiotherapy'],
    related: ['pe-techniques', 'exercise-for-sexual-health'],
    sections: [
      ArticleSection(
        heading: 'What the pelvic floor does',
        paragraphs: [
          'The pelvic floor is a group of muscles at the base of the pelvis. They support bladder and bowel control and are involved in erection rigidity and ejaculation.',
        ],
      ),
      ArticleSection(
        heading: 'Possible benefits',
        paragraphs: [
          'Some studies suggest that supervised pelvic floor training can help some men with ED or PE. Evidence is limited and studies are small.',
        ],
      ),
      ArticleSection(
        heading: 'Why more is not always better',
        paragraphs: [
          'Some people have pelvic floor muscles that are already too tense (overactive). For them, strengthening exercises can worsen pain or urinary symptoms, and relaxation training is more helpful. A pelvic health physiotherapist can assess which approach suits you.',
        ],
      ),
    ],
    evidenceSupports: [
      'Pelvic floor exercises are listed among PE management options by ISSM, and small trials suggest benefit for some men with ED.',
    ],
    uncertain: ['Optimal training programmes and long-term effects are not well established.'],
    nextSteps: ['If you try pelvic floor exercises, keep them gentle and stop if they cause pain.'],
    seeClinician: [
      'If you have pelvic, genital or perineal pain, urinary symptoms, or pain with ejaculation — see a clinician or pelvic health physiotherapist.',
    ],
    sources: [Src.issmPe, Src.eauSexual],
  ),
  Article(
    id: 'performance-anxiety',
    title: 'Performance anxiety and the monitoring trap',
    summary:
        'Worrying about how you are "performing" pulls attention away from sensation and triggers stress responses that work against arousal. It is common and very workable.',
    category: ArticleCategory.stressSleep,
    keywords: ['anxiety', 'performance anxiety', 'nerves', 'pressure', 'worry', 'spectatoring', 'confidence'],
    related: ['erection-variability', 'pe-techniques', 'foreplay-and-arousal', 'fatigue-and-energy'],
    sections: [
      ArticleSection(
        heading: 'The loop',
        paragraphs: [
          'Anxiety activates the body\'s stress response. Adrenaline narrows blood vessels and speeds things up — the opposite of the calm state that supports erections and control. Watching yourself from the outside ("Is it working?") keeps the loop going.',
        ],
      ),
      ArticleSection(
        heading: 'Ways to step out of it',
        bullets: [
          'Slow breathing to calm the stress response.',
          'Bring attention back to touch, warmth and your partner when you notice monitoring.',
          'Agree with your partner to take penetration off the table for a while and focus on other intimacy.',
          'Talk openly; secrecy usually adds pressure.',
          'Treat difficult moments as information, not failure.',
        ],
      ),
    ],
    evidenceSupports: [
      'Anxiety is a recognised contributor to ED and PE, and psychosexual therapy is included in guideline-recommended care.',
    ],
    uncertain: ['Anxiety often coexists with physical factors, so reducing anxiety may not resolve every concern.'],
    nextSteps: ['Try the guided breathing exercise.', 'Read the conversation guide.'],
    seeClinician: ['If anxiety is persistent, affects daily life, or you also have physical symptoms.'],
    sources: [Src.nhsAnxiety, Src.niddkEdTreatment, Src.eauSexual],
  ),
  Article(
    id: 'fatigue-and-energy',
    title: 'Fatigue, low energy and reduced interest in sex',
    summary:
        'Tiredness and low interest in sex have many possible causes, from sleep and stress to depression, anaemia, thyroid problems and medicines. Persistent fatigue deserves a check-up.',
    category: ArticleCategory.stressSleep,
    keywords: ['fatigue', 'tired', 'exhausted', 'burnout', 'low energy', 'stress', 'thyroid', 'anaemia'],
    related: ['sleep-and-sexual-wellbeing', 'libido-contributors', 'performance-anxiety'],
    sections: [
      ArticleSection(
        heading: 'Common causes of tiredness',
        bullets: [
          'Not enough sleep, or poor-quality sleep.',
          'Stress, overwork and burnout.',
          'Depression and anxiety.',
          'Anaemia, thyroid problems, diabetes and other conditions.',
          'Medicine side effects, alcohol and caffeine patterns.',
        ],
      ),
      ArticleSection(
        heading: 'Recovery basics',
        bullets: [
          'Plan short breaks during the day.',
          'Protect your sleep window.',
          'Gentle activity often improves energy over time.',
          'Notice what drains and restores you with brief check-ins.',
        ],
      ),
    ],
    evidenceSupports: ['The NHS lists psychological, physical and lifestyle causes of persistent tiredness.'],
    uncertain: [],
    nextSteps: ['Log energy and stress for two weeks to spot patterns.'],
    seeClinician: [
      'If tiredness is persistent, unexplained or severe, or comes with weight loss, low mood, or other new symptoms.',
    ],
    sources: [Src.nhsTired, Src.nhsStress, Src.nhsDepression],
  ),
];
