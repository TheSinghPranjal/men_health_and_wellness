import '../../domain/article.dart';
import 'sources.dart';

/// Intimacy, communication, pornography, age and hormones.
const relationshipArticles = <Article>[
  Article(
    id: 'foreplay-and-arousal',
    title: 'Foreplay is not a countdown',
    summary:
        'Arousal and readiness vary between people and situations. Taking time, staying curious and checking in usually matter more than any technique.',
    category: ArticleCategory.intimacy,
    keywords: ['foreplay', 'arousal', 'intimacy', 'touch', 'pace', 'slow down', 'stimulation'],
    related: ['talking-with-partner', 'consent-and-comfort', 'performance-anxiety'],
    sections: [
      ArticleSection(
        heading: 'Rethinking foreplay',
        paragraphs: [
          'Foreplay is often treated as a warm-up before the "main event". In practice, kissing, touching, talking and closeness can be the main event. Penetration is optional, and it is not the only way to share intimacy or pleasure.',
          'There is no universal ideal length of time. Some days it takes longer to feel aroused, especially when tired or stressed.',
        ],
      ),
      ArticleSection(
        heading: 'Practical ideas',
        bullets: [
          'Start without a goal: let things build without deciding in advance how they should end.',
          'Ask what feels good, and share what feels good to you.',
          'Explore different kinds of touch and pace, and notice what helps you both relax.',
          'Take breaks; slowing down is not failing.',
          'If one of you is tired or stressed, closeness without sex is still connection.',
        ],
      ),
      ArticleSection(
        heading: 'Body signals are not consent',
        paragraphs: [
          'Physical signs of arousal, such as an erection or lubrication, can happen without desire and do not mean someone has agreed to anything. Consent is an ongoing, freely given yes that can change at any point.',
        ],
      ),
    ],
    evidenceSupports: ['Communication and relationship satisfaction are consistently linked with sexual satisfaction.'],
    uncertain: ['What feels good is highly individual, so general advice can only be a starting point.'],
    nextSteps: ['Pick one conversation starter from the communication guide to try this week.'],
    seeClinician: [
      'If sex is painful for either partner, or arousal difficulties persist and cause distress, a clinician or psychosexual therapist can help.',
    ],
    sources: [Src.nhsSexualHealth, Src.issmQa],
  ),
  Article(
    id: 'talking-with-partner',
    title: 'Talking about sex without blame',
    summary:
        'Conversations about erections, timing or desire feel risky but usually bring partners closer. Choose a calm moment, speak for yourself and stay curious.',
    category: ArticleCategory.intimacy,
    keywords: ['communication', 'partner', 'talk', 'conversation', 'relationship', 'couple'],
    related: ['consent-and-comfort', 'foreplay-and-arousal', 'libido-variation'],
    sections: [
      ArticleSection(
        heading: 'Setting up the conversation',
        bullets: [
          'Pick a relaxed, private time — not right after a difficult moment in bed.',
          'Use "I" statements: "I\'ve been feeling anxious about…" rather than "You make me…".',
          'Be specific about what you want to try or change.',
          'Listen to understand, not to defend.',
        ],
      ),
      ArticleSection(
        heading: 'Conversation starters',
        bullets: [
          '"What helps you feel comfortable and connected?"',
          '"Would you like to slow down or try something different?"',
          '"How can we make intimacy feel less pressured?"',
          '"Would you like us to explore this together or speak with a professional?"',
          '"I\'ve noticed my erections changing sometimes. It\'s not about you — can we talk about it?"',
        ],
      ),
      ArticleSection(
        heading: 'How a partner can help',
        paragraphs: [
          'Partners can support sexual wellbeing through open communication, patience and reassurance without making promises. They are not responsible for treating ED, PE or low desire, and solving it is not their job — but facing it together often reduces the pressure for both of you.',
        ],
      ),
    ],
    evidenceSupports: [
      'Counselling that includes partners is recommended in guidelines for some sexual concerns, and NIDDK notes counsellors may invite partners to sessions.',
    ],
    uncertain: ['Every relationship is different; there is no single right script.'],
    nextSteps: ['Write down what you want your partner to understand before you talk.'],
    seeClinician: ['If conversations repeatedly end in conflict, a relationship or psychosexual therapist can help.'],
    sources: [Src.niddkEdTreatment, Src.eauSexual, Src.nhsSexualHealth],
  ),
  Article(
    id: 'consent-and-comfort',
    title: 'Consent, comfort and mutual satisfaction',
    summary:
        'Good sex is built on enthusiastic agreement, emotional safety and respect for boundaries. These are not extras; they are the foundation.',
    category: ArticleCategory.intimacy,
    keywords: ['consent', 'boundaries', 'comfort', 'respect', 'stop', 'safety'],
    related: ['talking-with-partner', 'foreplay-and-arousal'],
    sections: [
      ArticleSection(
        heading: 'What consent looks like',
        bullets: [
          'It is freely given, without pressure, guilt or obligation.',
          'It can be withdrawn at any time, and stopping when asked is non-negotiable.',
          'Agreeing to one thing is not agreeing to everything.',
          'Someone who is very drunk, asleep or otherwise unable to decide cannot consent.',
        ],
      ),
      ArticleSection(
        heading: 'Noticing discomfort',
        paragraphs: [
          'Watch and listen for hesitation, tension or silence. Checking in — "Is this good?" or "Do you want to keep going?" — is caring, not awkward. If something hurts or feels wrong, pause and talk.',
        ],
      ),
    ],
    evidenceSupports: [
      'Respect, safety and communication are central to sexual health as described by public health bodies.',
    ],
    uncertain: [],
    nextSteps: ['Agree on simple words or signals for "slow down" and "stop".'],
    seeClinician: [
      'If sex is painful, or if you or a partner have experienced coercion or abuse, seek professional support.',
    ],
    sources: [Src.nhsSexualHealth],
  ),
  Article(
    id: 'porn-and-expectations',
    title: 'Pornography, arousal and expectations',
    summary:
        'Research on pornography and sexual function is mixed and mostly observational. For some people, patterns of use may affect expectations or arousal with a partner; for many, they do not.',
    category: ArticleCategory.porn,
    keywords: ['porn', 'pornography', 'PIED', 'expectations', 'addiction', 'compulsive', 'masturbation'],
    related: ['performance-anxiety', 'foreplay-and-arousal', 'delayed-ejaculation'],
    sections: [
      ArticleSection(
        heading: 'What the research can and cannot say',
        paragraphs: [
          'Most studies take a snapshot of people at one point in time. They can show associations but cannot show that pornography causes erection problems or low desire. Results across studies are inconsistent.',
          'Pornography use, on its own, does not establish a disorder, and how often someone watches is not enough to call it an addiction.',
        ],
      ),
      ArticleSection(
        heading: 'Patterns some people notice',
        bullets: [
          'Expectations shaped by performances that are edited, scripted and unrealistic.',
          'A mismatch between the type or intensity of stimulation used alone and what happens with a partner.',
          'Using it to cope with stress, boredom or low mood, and finding it hard to cut back despite wanting to.',
          'Use taking time away from sleep, work or relationships.',
        ],
      ),
      ArticleSection(
        heading: 'A personal, voluntary experiment',
        paragraphs: [
          'If you are curious whether changing your habits affects how you feel, you can set your own goal and observe your experience privately for a few weeks. This is optional, there are no streaks to lose, and you can stop at any time.',
        ],
      ),
    ],
    evidenceSupports: [
      'Evidence linking pornography use to ED is mixed and largely observational.',
      'Difficulty controlling a behaviour despite negative consequences and distress is a reason to seek support, whatever the behaviour.',
    ],
    uncertain: [
      'Whether and how pornography use affects partnered sexual function in some individuals remains debated.',
    ],
    nextSteps: [
      'Use the optional private reflection to explore your own patterns.',
      'Try a self-directed experiment if it interests you.',
    ],
    seeClinician: [
      'If you feel unable to control use and it causes significant distress or affects work, relationships or sleep — a psychologist or sex therapist can help without judgment.',
    ],
    sources: [Src.eauSexual, Src.issmQa],
  ),
  Article(
    id: 'age-and-sexual-health',
    title: 'Age and sexual health',
    summary:
        'Some changes with age are normal — erections may take longer and recovery may be slower — but general health matters more than the number of birthdays.',
    category: ArticleCategory.ageHormones,
    keywords: ['age', 'older', 'ageing', 'aging', 'over 50', 'refractory period', 'recovery time'],
    related: ['testosterone-facts', 'understanding-ed', 'exercise-for-sexual-health'],
    sections: [
      ArticleSection(
        heading: 'Common changes',
        bullets: [
          'Erections may need more direct stimulation and take longer.',
          'Erections may be less firm at times.',
          'The recovery time between ejaculations often lengthens.',
          'Ejaculation may feel less forceful.',
        ],
      ),
      ArticleSection(
        heading: 'What is not "just age"',
        paragraphs: [
          'ED becomes more common with age largely because conditions like high blood pressure, diabetes and heart disease become more common. Many older men have satisfying sex lives, and treatable causes should not be dismissed as ageing.',
        ],
      ),
    ],
    evidenceSupports: ['ED prevalence rises with age, closely linked to cardiovascular and metabolic conditions.'],
    uncertain: [
      'How much of age-related change is due to ageing itself versus accumulated health conditions is hard to separate.',
    ],
    nextSteps: ['Keep up regular health checks, including blood pressure and blood sugar.'],
    seeClinician: ['If changes are sudden, distressing or accompanied by other symptoms.'],
    sources: [Src.niddkEdCauses, Src.eauSexual],
  ),
  Article(
    id: 'testosterone-facts',
    title: 'Testosterone: what it does and does not do',
    summary:
        'Testosterone supports desire, energy and muscle, but symptoms alone cannot confirm a deficiency. Treatment is for confirmed deficiency and can reduce fertility.',
    category: ArticleCategory.ageHormones,
    keywords: ['testosterone', 'low T', 'TRT', 'hormones', 'hypogonadism', 'fertility', 'sperm'],
    related: ['libido-contributors', 'fatigue-and-energy', 'supplements-guide'],
    sections: [
      ArticleSection(
        heading: 'How deficiency is diagnosed',
        paragraphs: [
          'The American Urological Association recommends diagnosing testosterone deficiency only when a man has compatible symptoms and low total testosterone on two separate early-morning blood tests. It uses a cut-off of 300 ng/dL as a reasonable threshold.',
          'Symptoms like tiredness and low desire are common and have many causes, so they cannot confirm low testosterone on their own.',
        ],
      ),
      ArticleSection(
        heading: 'Important cautions about treatment',
        bullets: [
          'Testosterone treatment can suppress sperm production and is not appropriate for men who want to conceive.',
          'Treatment requires monitoring, including blood tests.',
          'It is not a general sexual-performance enhancer and is not recommended for men with normal levels.',
          'Products sold online or in gyms may be unregulated.',
        ],
      ),
    ],
    evidenceSupports: [
      'AUA guidance requires symptoms plus repeated low morning levels for diagnosis, and warns that exogenous testosterone impairs fertility.',
    ],
    uncertain: ['Long-term risks and benefits of testosterone therapy in some groups remain under study.'],
    nextSteps: [
      'If you think hormones may be involved, discuss symptoms with a clinician rather than buying products.',
    ],
    seeClinician: [
      'If you have persistent low desire with fatigue, reduced body or facial hair, loss of muscle, or breast tenderness.',
      'Before starting any hormonal product, especially if you may want children.',
    ],
    safetyWarnings: ['Testosterone may impair fertility. Do not use hormonal products without medical supervision.'],
    sources: [Src.auaTestosterone, Src.eauSexual],
  ),
];
