import '../../domain/article.dart';
import 'sources.dart';

/// Libido, premature ejaculation and delayed ejaculation.
const desireEjaculationArticles = <Article>[
  Article(
    id: 'libido-variation',
    title: 'Sex drive naturally varies',
    summary:
        'There is no "correct" level of sexual desire. It changes over a lifetime, across relationships and with circumstances. A change is worth exploring only if it bothers you.',
    category: ArticleCategory.desire,
    keywords: ['libido', 'sex drive', 'low desire', 'spontaneous desire', 'responsive desire', 'mismatch'],
    related: ['libido-contributors', 'desire-vs-arousal', 'talking-with-partner'],
    sections: [
      ArticleSection(
        heading: 'Spontaneous and responsive desire',
        paragraphs: [
          'Spontaneous desire seems to appear out of nowhere. Responsive desire builds once closeness, touch or intimacy begins. Both are normal, and many people experience more responsive desire in long-term relationships or busy periods of life.',
          'If you only count spontaneous desire, you may underestimate your interest in sex.',
        ],
      ),
      ArticleSection(
        heading: 'Desire in relationships',
        paragraphs: [
          'Partners often have different levels of desire. A difference is not a disorder, and neither person is "wrong". Feeling emotionally connected, respected and unpressured tends to support desire; conflict, resentment and pressure tend to dampen it.',
        ],
      ),
    ],
    evidenceSupports: [
      'The NHS notes that libido varies between people and that relationship problems, stress, tiredness and medicines are common reasons for reduced sex drive.',
    ],
    uncertain: ['Measures of "normal" desire are imprecise because desire is subjective.'],
    nextSteps: [
      'Try the optional desire journal for a few weeks to spot patterns with sleep, stress and mood.',
      'Read the conversation guides if desire differences are causing tension.',
    ],
    seeClinician: [
      'If a drop in desire is persistent and distressing, or comes with other symptoms such as fatigue or low mood.',
    ],
    sources: [Src.nhsLibido, Src.eauSexual],
  ),
  Article(
    id: 'libido-contributors',
    title: 'What can lower desire',
    summary:
        'Stress, sleep, mood, relationship factors, medicines, alcohol and medical conditions can all affect desire. Low libido does not automatically mean low testosterone.',
    category: ArticleCategory.desire,
    keywords: ['low libido', 'testosterone', 'depression', 'tired', 'medication', 'antidepressants', 'no sex drive'],
    related: ['libido-variation', 'testosterone-facts', 'fatigue-and-energy', 'sleep-and-sexual-wellbeing'],
    sections: [
      ArticleSection(
        heading: 'Common contributors',
        bullets: [
          'Stress, workload and worry.',
          'Tiredness and poor or short sleep.',
          'Depression and anxiety.',
          'Relationship problems or feeling disconnected.',
          'Some medicines, including certain antidepressants.',
          'Alcohol and recreational drug use.',
          'Medical conditions, including hormonal conditions.',
          'Major life changes, for example a new baby, bereavement or job loss.',
        ],
      ),
      ArticleSection(
        heading: 'About testosterone',
        paragraphs: [
          'Testosterone supports desire, but many men with low desire have normal testosterone, and many causes above are more common. A diagnosis of testosterone deficiency requires both compatible symptoms and repeated, properly timed blood tests interpreted by a clinician.',
          'Testosterone products are not a general libido booster, and using them without a confirmed deficiency can cause harm, including reduced fertility.',
        ],
      ),
    ],
    evidenceSupports: [
      'Guidelines require symptoms plus repeated low morning testosterone levels for a diagnosis of testosterone deficiency.',
      'Psychological and relationship factors are well recognised contributors to low desire.',
    ],
    uncertain: ['The relationship between testosterone level and desire varies between individuals.'],
    nextSteps: [
      'Look at sleep and stress first; they are common and modifiable.',
      'If you take a medicine you suspect is affecting desire, note when it started and ask your prescriber.',
    ],
    seeClinician: [
      'If low desire is persistent, distressing, or comes with fatigue, low mood, reduced body hair, or breast tenderness.',
      'If you are considering any hormonal product.',
    ],
    safetyWarnings: ['Do not stop prescribed medicines without talking to the prescriber.'],
    sources: [Src.nhsLibido, Src.auaTestosterone, Src.nhsDepression],
  ),
  Article(
    id: 'understanding-pe',
    title: 'Understanding premature ejaculation (PE)',
    summary:
        'PE is about ejaculating sooner than you want with little sense of control, in a way that causes distress. There is no universal stopwatch target for satisfying sex.',
    category: ArticleCategory.ejaculation,
    keywords: [
      'PE',
      'PME',
      'premature ejaculation',
      'early ejaculation',
      'finish too fast',
      'control',
      'lasting longer',
    ],
    related: ['pe-techniques', 'ed-and-pe', 'pe-treatments', 'performance-anxiety'],
    sections: [
      ArticleSection(
        heading: 'How PE is described',
        paragraphs: [
          'The International Society for Sexual Medicine describes PE as ejaculation that always or almost always happens before or within about one minute of penetration (for lifelong PE), with an inability to delay ejaculation and personal distress.',
          'These research definitions were developed in specific study settings. They help clinicians, but they are not a standard everyone must meet, and they do not define what good sex is.',
        ],
      ),
      ArticleSection(
        heading: 'Types you may read about',
        bullets: [
          'Lifelong: present since early sexual experiences.',
          'Acquired: develops later, sometimes alongside erection difficulties, anxiety, prostate problems or relationship changes.',
          'Variable: early ejaculation happens irregularly; often a normal variation.',
          'Subjective: worry about ejaculating early when timing is within a typical range.',
        ],
      ),
      ArticleSection(
        heading: 'Timing is not the same as satisfaction',
        paragraphs: [
          'Partners frequently report that connection, communication and the whole experience matter more than duration. Penetration is also only one part of sex. Many couples find that taking the focus off timing reduces anxiety and improves control.',
        ],
      ),
    ],
    evidenceSupports: [
      'PE is common and recognised in clinical guidelines; behavioural, psychological and medical treatments have evidence of benefit for some people.',
      'Control and distress are central to the definition, not timing alone.',
    ],
    uncertain: [
      'Causes of lifelong PE are not fully understood.',
      'Most timing research comes from heterosexual penetrative sex, so it does not reflect everyone.',
    ],
    nextSteps: [
      'Try the optional ejaculation reflection.',
      'Read about behavioural techniques and the anxiety–arousal loop.',
    ],
    seeClinician: [
      'If PE is persistent and distressing, affecting your relationship, or appeared suddenly.',
      'If you also have erection difficulties, pain, or urinary symptoms.',
    ],
    sources: [Src.issmPe, Src.nhsEjaculation, Src.auaEjaculation, Src.eauSexual],
  ),
  Article(
    id: 'pe-techniques',
    title: 'Behavioural techniques for ejaculatory control',
    summary:
        'Learning to recognise rising arousal, slow down, breathe and communicate can help some people feel more in control. Results vary, and no technique is guaranteed.',
    category: ArticleCategory.ejaculation,
    keywords: ['start stop', 'squeeze', 'edging', 'last longer', 'control techniques', 'mindfulness', 'breathing'],
    related: ['understanding-pe', 'pe-treatments', 'performance-anxiety', 'pelvic-floor'],
    sections: [
      ArticleSection(
        heading: 'Recognising your arousal levels',
        paragraphs: [
          'Many techniques start with noticing arousal as a scale rather than an on/off switch. Practising during solo time, without pressure, helps you notice the point where ejaculation starts to feel inevitable and act a little before it.',
        ],
      ),
      ArticleSection(
        heading: 'Techniques commonly taught',
        bullets: [
          'Start–stop: pause stimulation as arousal climbs, let it settle, then resume. Repeat a few times before allowing ejaculation.',
          'Squeeze: gently pressing where the head meets the shaft for a few seconds during a pause, as taught by a clinician or therapist.',
          'Relaxed breathing: slow, low breaths help counter the tension that speeds ejaculation.',
          'Changing pace, rhythm or type of stimulation, and taking breaks.',
          'Reducing self-monitoring: focusing on sensations and your partner rather than the clock.',
          'Communicating with your partner so pausing feels like part of intimacy rather than a failure.',
        ],
      ),
      ArticleSection(
        heading: 'Realistic expectations',
        paragraphs: [
          'Behavioural approaches can take several weeks of practice. Guidelines note that combining them with psychosexual therapy or medical treatment is often more effective than either alone, and that benefits may fade without continued practice.',
        ],
      ),
    ],
    evidenceSupports: ['Behavioural and psychological therapies are included in guideline-recommended PE management.'],
    uncertain: [
      'Studies of behavioural techniques are often small, and long-term benefit is less certain than short-term benefit.',
    ],
    nextSteps: [
      'Practise relaxed breathing daily for a week.',
      'Talk with your partner about trying a slower pace together.',
    ],
    seeClinician: [
      'If techniques are not helping after consistent practice, or distress is high. A psychosexual therapist can tailor an approach.',
    ],
    sources: [Src.nhsEjaculation, Src.auaEjaculation, Src.eauSexual, Src.issmPe],
  ),
  Article(
    id: 'ed-and-pe',
    title: 'When erection difficulties and PE happen together',
    summary:
        'ED and PE can coexist and feed each other. Rushing to finish before an erection fades can train faster ejaculation. Treating ED first is often recommended.',
    category: ArticleCategory.ejaculation,
    keywords: ['ED and PE', 'both', 'rush', 'lose erection'],
    related: ['understanding-pe', 'understanding-ed', 'performance-anxiety'],
    sections: [
      ArticleSection(
        heading: 'How they interact',
        paragraphs: [
          'If you worry about losing your erection, you may hurry, which can make ejaculation come sooner. Over time, the worry itself can raise arousal and anxiety at the same time, a loop that affects both concerns.',
          'Guidelines advise that when both are present, erection difficulties are usually addressed first.',
        ],
      ),
    ],
    evidenceSupports: ['Guidelines recommend assessing for and treating coexisting ED in men presenting with PE.'],
    uncertain: ['How often each one causes the other is not well established.'],
    nextSteps: ['Mention both concerns to a clinician, even if one feels more important.'],
    seeClinician: ['If you have both concerns, a clinician can help decide which to address first.'],
    sources: [Src.auaEjaculation, Src.eauSexual],
  ),
  Article(
    id: 'delayed-ejaculation',
    title: 'Delayed ejaculation and difficulty reaching orgasm',
    summary:
        'Taking much longer than you want to ejaculate, or not being able to, is less discussed but not rare. Medicines, health conditions and psychological factors can contribute.',
    category: ArticleCategory.ejaculation,
    keywords: ['delayed ejaculation', 'cannot finish', 'cannot orgasm', 'anorgasmia', 'no ejaculation', 'SSRI'],
    related: ['erection-ejaculation-orgasm', 'libido-contributors', 'when-to-see-clinician'],
    sections: [
      ArticleSection(
        heading: 'Related but different experiences',
        bullets: [
          'Delayed ejaculation: ejaculation takes much longer than desired, or happens only with certain kinds of stimulation.',
          'Absent ejaculation: no ejaculation even with orgasm.',
          'Difficulty with orgasm: trouble reaching climax, with or without ejaculation.',
        ],
      ),
      ArticleSection(
        heading: 'Possible contributors',
        bullets: [
          'Medicines, especially some antidepressants (SSRIs).',
          'Diabetes and conditions affecting nerves.',
          'Pelvic or prostate surgery.',
          'Hormonal conditions.',
          'Alcohol and some recreational drugs.',
          'Anxiety, relationship factors, or a mismatch between preferred and partnered stimulation.',
        ],
      ),
      ArticleSection(
        heading: 'An important caution',
        paragraphs: [
          'If you suspect a prescribed medicine, do not stop it on your own. Stopping some medicines suddenly can be unsafe. A prescriber may be able to adjust the dose or switch to an alternative.',
        ],
      ),
    ],
    evidenceSupports: ['Antidepressants of the SSRI type are a well recognised cause of delayed ejaculation.'],
    uncertain: ['Treatment evidence for delayed ejaculation is more limited than for PE or ED.'],
    nextSteps: ['Note any recent medicine changes and when the change began.'],
    seeClinician: [
      'If the change is persistent or distressing, started after a new medicine, or there is no ejaculate.',
      'If there is pain or blood with ejaculation.',
    ],
    safetyWarnings: ['Do not stop prescribed medicines without talking to the prescriber.'],
    sources: [Src.smsnaDe, Src.nhsEjaculation, Src.auaEjaculation],
  ),
];
