import 'package:flutter/material.dart';

import '../../../../app/theme/clay_tokens.dart';
import '../../domain/article.dart';
import 'sources.dart';

/// Sexual physiology and erectile health.
const foundationArticles = <Article>[
  Article(
    id: 'desire-vs-arousal',
    title: 'Desire and arousal are not the same thing',
    summary:
        'Wanting sex (desire) and the body getting ready for sex (arousal) are related but separate processes. Knowing the difference takes a lot of pressure off.',
    category: ArticleCategory.physiology,
    keywords: ['libido', 'sex drive', 'wanting', 'turned on', 'arousal', 'mind body'],
    related: ['how-erections-work', 'libido-variation', 'erection-ejaculation-orgasm'],
    sections: [
      ArticleSection(
        heading: 'Two systems that usually work together',
        comparison: [
          ConceptCard(
            title: 'Desire',
            subtitle: 'Mental interest',
            body:
                'Desire is the mental interest in sex: thoughts, fantasies, emotional connection or wanting closeness.',
            icon: Icons.psychology_rounded,
            tone: ClayTone.rose,
            examples: ['Sexual thoughts or fantasies', 'Wanting intimacy or closeness', 'Feeling interested in sex'],
          ),
          ConceptCard(
            title: 'Arousal',
            subtitle: 'Physical response',
            body:
                'Arousal is the physical response: faster breathing, increased blood flow to the genitals, and an erection.',
            icon: Icons.monitor_heart_rounded,
            tone: ClayTone.blue,
            examples: [
              'Faster heart rate and breathing',
              'Blood flow to the genitals',
              'Erection or genital sensitivity',
            ],
          ),
        ],
        note:
            'They often happen together, but not always. It is common to feel interested without a strong physical response, or to notice a physical response without much interest. Neither situation means something is wrong.',
      ),
      ArticleSection(
        heading: 'Why the difference matters',
        bullets: [
          'An erection is not a measure of how much you desire someone.',
          'Low desire and erection difficulties have different common causes, so they are approached differently.',
          'Stress, tiredness and distraction can dampen arousal even when desire is present.',
          'For many people desire builds after intimacy starts rather than before (responsive desire).',
        ],
      ),
    ],
    evidenceSupports: [
      'Sexual medicine guidelines treat disorders of desire, erection and ejaculation as distinct conditions with different evaluations.',
      'Psychological state, relationship context and physical health all influence both desire and arousal.',
    ],
    uncertain: [
      'How desire and arousal interact varies widely between individuals, and models of desire are still debated by researchers.',
    ],
    nextSteps: [
      'Notice whether a concern is mostly about interest, physical response, or both.',
      'Read about spontaneous and responsive desire.',
    ],
    seeClinician: ['If loss of desire or arousal is persistent, distressing, or started suddenly.'],
    sources: [Src.eauSexual, Src.nhsLibido, Src.issmQa],
  ),
  Article(
    id: 'how-erections-work',
    title: 'How erections work',
    summary:
        'An erection depends on the brain, nerves, blood vessels, hormones and smooth muscle working together. A problem in any part of the chain can affect it.',
    category: ArticleCategory.physiology,
    keywords: ['erection', 'blood flow', 'nitric oxide', 'cGMP', 'smooth muscle', 'PDE5', 'physiology'],
    related: ['erection-variability', 'understanding-ed', 'ed-treatments'],
    sections: [
      ArticleSection(
        heading: 'The chain of events',
        bullets: [
          'Brain: sexual thoughts or touch trigger signals that travel down the spinal cord.',
          'Nerves: nerve endings in the penis release a chemical messenger called nitric oxide.',
          'Chemistry: nitric oxide raises levels of a molecule called cGMP inside smooth muscle cells.',
          'Smooth muscle: cGMP relaxes the muscle in the arteries and spongy tissue of the penis.',
          'Blood flow: relaxed tissue fills with blood, and the expanding tissue presses on veins so blood stays in.',
        ],
      ),
      ArticleSection(
        heading: 'How it ends',
        paragraphs: [
          'An enzyme called PDE5 breaks down cGMP, the smooth muscle tightens again and blood drains out. This normally happens after ejaculation or when arousal fades.',
          'PDE5 inhibitor medicines work by slowing this breakdown. They do not create desire or cause an erection on their own; sexual stimulation is still needed.',
        ],
      ),
      ArticleSection(
        heading: 'What can interrupt the chain',
        bullets: [
          'Blood vessel health (for example high blood pressure, diabetes, smoking, high cholesterol).',
          'Nerve function (for example diabetes, surgery or spinal conditions).',
          'Hormones (testosterone plays a supporting role, mostly in desire).',
          'The brain: stress, anxiety and adrenaline work against the relaxation an erection needs.',
          'Some medicines and substances.',
        ],
      ),
    ],
    evidenceSupports: [
      'The nitric oxide–cGMP pathway is the established mechanism of erection and the target of PDE5 inhibitor medicines.',
      'Vascular, neurological, hormonal and psychological factors can each contribute to erection difficulties.',
    ],
    uncertain: [
      'In an individual, it is often a mix of factors, and it is not always possible to identify a single cause.',
    ],
    nextSteps: [
      'Consider which parts of the chain your general health may be affecting.',
      'Look at sleep, stress, activity, alcohol and smoking, which affect several links at once.',
    ],
    seeClinician: [
      'If erection difficulties are persistent or recurrent, a clinician can check blood pressure, blood sugar, cholesterol and medicines.',
    ],
    sources: [Src.niddkEd, Src.niddkEdCauses, Src.eauSexual],
  ),
  Article(
    id: 'erection-ejaculation-orgasm',
    title: 'Erection, ejaculation and orgasm are different',
    summary:
        'These three events are controlled by different processes. You can have one without the others, which explains many common experiences.',
    category: ArticleCategory.physiology,
    keywords: ['orgasm', 'ejaculation', 'climax', 'erection', 'timing'],
    related: ['understanding-pe', 'delayed-ejaculation', 'how-erections-work'],
    sections: [
      ArticleSection(
        heading: 'Three separate events',
        bullets: [
          'Erection: a blood-flow event controlled mostly by the relaxing branch of the nervous system.',
          'Ejaculation: a reflex involving muscles of the pelvis and the release of semen.',
          'Orgasm: the feeling of pleasure and release, experienced in the brain.',
        ],
        paragraphs: [
          'Because they are separate, it is possible to ejaculate without a full erection, to have an orgasm with little or no ejaculate, or to lose an erection before orgasm.',
        ],
      ),
      ArticleSection(
        heading: 'Why this matters for your expectations',
        paragraphs: [
          'Erection firmness, how long before ejaculation, and how much you desire sex are not interchangeable measures of sexual health. Improving one does not automatically change the others, and satisfaction depends on much more than any single number.',
        ],
      ),
    ],
    evidenceSupports: [
      'Guidelines classify erectile dysfunction, ejaculatory disorders and orgasmic disorders separately.',
    ],
    uncertain: ['The subjective experience of orgasm varies greatly and is hard to study objectively.'],
    nextSteps: [
      'Describe concerns precisely (erection, timing, or sensation) when reading further or talking to a clinician.',
    ],
    seeClinician: ['If you notice no ejaculate, blood in semen, pain on ejaculation, or a sudden change in orgasm.'],
    sources: [Src.eauSexual, Src.nhsEjaculation, Src.auaEjaculation],
  ),
  Article(
    id: 'erection-variability',
    title: 'Why erections vary, even when you are healthy',
    summary:
        'An occasional erection that fades or does not happen is common and usually not a sign of a medical problem. Patterns over time matter more than single moments.',
    category: ArticleCategory.erectile,
    keywords: ['lost erection', 'soft', 'one time', 'nerves', 'variability', 'normal'],
    related: ['understanding-ed', 'performance-anxiety', 'morning-erections'],
    sections: [
      ArticleSection(
        heading: 'Common, ordinary reasons',
        bullets: [
          'Tiredness or poor sleep.',
          'Alcohol, especially larger amounts.',
          'Stress, distraction or worry about performance.',
          'A new partner or an unfamiliar situation.',
          'Feeling disconnected or not in the mood.',
          'Illness or recovery from illness.',
        ],
      ),
      ArticleSection(
        heading: 'The worry loop',
        paragraphs: [
          'One difficult experience can lead to worry next time. Worry triggers adrenaline, which works against the relaxation an erection needs, which makes another difficult experience more likely. Recognising this loop is often the first step in breaking it.',
        ],
      ),
    ],
    evidenceSupports: [
      'The NHS notes that occasional erection problems are common and often linked to stress, tiredness, anxiety or alcohol.',
    ],
    uncertain: [
      'There is no exact frequency that separates "normal variation" from a condition; persistence and distress matter.',
    ],
    nextSteps: [
      'Avoid judging yourself on one experience.',
      'Try a breathing exercise to practise shifting out of "monitoring mode".',
      'Notice patterns over weeks rather than single events.',
    ],
    seeClinician: [
      'If difficulties happen most of the time, keep happening over several weeks, or cause you distress.',
    ],
    sources: [Src.nhsEd, Src.niddkEdCauses],
  ),
  Article(
    id: 'understanding-ed',
    title: 'Understanding erectile dysfunction (ED)',
    summary:
        'ED means persistent or recurring trouble getting or keeping an erection firm enough for satisfying sex. It is common, has many possible causes, and is often treatable.',
    category: ArticleCategory.erectile,
    keywords: ['ED', 'impotence', 'erectile dysfunction', 'erection problems', 'cannot get hard'],
    related: ['ed-causes', 'ed-treatments', 'when-to-see-clinician', 'erection-variability'],
    sections: [
      ArticleSection(
        heading: 'What ED is',
        paragraphs: [
          'Health services describe ED as being unable to get or keep an erection firm enough for sex. It can range from sometimes being able to get an erection but not every time, to getting one that does not last long enough, to being unable to get one at all.',
          'Occasional difficulty is not ED. The term is used when difficulty is persistent or recurrent.',
        ],
      ),
      ArticleSection(
        heading: 'ED is not "just in your head" — or "just age"',
        paragraphs: [
          'ED often has physical contributors such as reduced blood flow, nerve problems, hormone changes or medicine side effects. Psychological factors such as stress and anxiety also play a real role, and physical and psychological causes frequently overlap.',
          'ED becomes more common with age, but it is not an inevitable part of getting older. General health tends to matter more than age alone.',
        ],
      ),
      ArticleSection(
        heading: 'A signal worth listening to',
        paragraphs: [
          'Erection problems share risk factors with heart and blood vessel disease, such as high blood pressure, diabetes, high cholesterol and smoking. Guidelines recommend that men with ED have their cardiovascular risk assessed. That is a reason to check in with a clinician, not a reason to panic.',
        ],
      ),
    ],
    evidenceSupports: [
      'ED is associated with cardiovascular risk factors, and guidelines recommend cardiovascular risk assessment for men presenting with ED.',
      'A range of effective treatments exist, chosen according to cause, health and personal preference.',
    ],
    uncertain: [
      'For any one person, it can be difficult to separate physical and psychological contributions precisely.',
    ],
    nextSteps: [
      'Use the optional erection health reflection to organise your thoughts.',
      'Prepare for an appointment with the clinician checklist.',
      'Review lifestyle areas that support vascular health.',
    ],
    seeClinician: [
      'If difficulties are persistent or recurrent.',
      'If ED began suddenly, or alongside other symptoms such as chest pain, breathlessness or numbness.',
      'If you have diabetes, high blood pressure or heart disease and notice changes.',
    ],
    safetyWarnings: [
      'Do not buy ED medicines from unverified online sellers. Products can be counterfeit or contain undeclared ingredients.',
    ],
    sources: [Src.niddkEd, Src.nhsEd, Src.auaEd, Src.eauSexual],
  ),
  Article(
    id: 'ed-causes',
    title: 'What contributes to erection difficulties',
    summary:
        'Physical health, medicines, substances, mental health and relationships can all contribute. Most people have more than one factor at play.',
    category: ArticleCategory.erectile,
    keywords: [
      'causes',
      'risk factors',
      'diabetes',
      'blood pressure',
      'medication side effects',
      'cholesterol',
      'smoking',
    ],
    related: ['understanding-ed', 'alcohol-smoking-substances', 'exercise-for-sexual-health', 'performance-anxiety'],
    sections: [
      ArticleSection(
        heading: 'Physical contributors',
        bullets: [
          'Conditions affecting blood vessels: high blood pressure, high cholesterol, heart disease.',
          'Type 2 diabetes and metabolic health.',
          'Nerve damage, for example from diabetes, spinal injury or pelvic surgery and prostate cancer treatment.',
          'Hormonal problems, including low testosterone.',
          'Penile conditions such as Peyronie\'s disease.',
        ],
      ),
      ArticleSection(
        heading: 'Medicines and substances',
        paragraphs: [
          'Some medicines can affect erections, including certain blood pressure medicines, antidepressants and others. Smoking, heavy drinking and some recreational drugs are also linked to ED.',
          'Never stop a prescribed medicine because of a sexual side effect without speaking to the prescriber. There are often alternatives or adjustments.',
        ],
      ),
      ArticleSection(
        heading: 'Psychological and relationship contributors',
        bullets: [
          'Stress, anxiety and performance pressure.',
          'Depression and low mood.',
          'Relationship conflict or communication difficulties.',
          'Fatigue and poor sleep.',
        ],
      ),
    ],
    evidenceSupports: [
      'NIDDK lists vascular disease, diabetes, nerve damage, certain medicines, smoking, and emotional factors among causes of ED.',
    ],
    uncertain: ['Which factor matters most differs between people; a clinician can help weigh them.'],
    nextSteps: [
      'List your current medicines and supplements before any appointment.',
      'Pick one modifiable factor (sleep, activity, alcohol, smoking) to work on.',
    ],
    seeClinician: [
      'To review medicines that might be contributing.',
      'To check blood pressure, blood sugar and cholesterol if they have not been checked recently.',
    ],
    sources: [Src.niddkEdCauses, Src.nhsEd, Src.eauSexual],
  ),
  Article(
    id: 'morning-erections',
    title: 'Morning and spontaneous erections: useful context, not a test',
    summary:
        'Erections during sleep and on waking are normal. Their presence or absence can be a useful detail to mention to a clinician, but they cannot diagnose or rule out anything.',
    category: ArticleCategory.erectile,
    keywords: ['morning wood', 'nocturnal erections', 'night', 'sleep erections', 'spontaneous'],
    related: ['understanding-ed', 'sleep-and-sexual-wellbeing', 'erection-variability'],
    sections: [
      ArticleSection(
        heading: 'What they are',
        paragraphs: [
          'Erections happen several times a night during REM sleep, and you sometimes wake with one. They are not linked to sexual thoughts.',
        ],
      ),
      ArticleSection(
        heading: 'Why they are only context',
        bullets: [
          'Their frequency varies with sleep quality, alcohol, age and other factors.',
          'Having them does not prove that every physical factor is fine.',
          'Not noticing them does not prove a physical problem.',
          'Clinicians may still ask about them because they can add to the overall picture.',
        ],
      ),
    ],
    evidenceSupports: ['Sleep-related erections are a normal part of REM sleep.'],
    uncertain: ['Self-observation of morning erections is unreliable and is not a substitute for clinical evaluation.'],
    nextSteps: [
      'If you plan to see a clinician, you can mention whether you notice them, without trying to "test" yourself.',
    ],
    seeClinician: ['If you notice a sudden, lasting change together with other erection difficulties.'],
    sources: [Src.eauSexual, Src.auaEd],
  ),
];
