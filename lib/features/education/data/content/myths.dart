import '../../domain/article.dart';
import 'sources.dart';

const myths = <Myth>[
  Myth(
    id: 'ed-psychological',
    myth: 'ED is always psychological.',
    evidence:
        'ED often has physical contributors, such as blood vessel disease, diabetes, nerve problems, hormones or medicines. Psychological factors are real too, and the two frequently overlap.',
    sources: [Src.niddkEdCauses, Src.nhsEd],
    relatedArticle: 'ed-causes',
  ),
  Myth(
    id: 'ed-inevitable',
    myth: 'ED is inevitable with age.',
    evidence:
        'ED becomes more common with age, largely because health conditions that affect blood vessels become more common. It is not inevitable, and treatable causes should not be dismissed as ageing.',
    sources: [Src.niddkEdCauses, Src.eauSexual],
    relatedArticle: 'age-and-sexual-health',
  ),
  Myth(
    id: 'libido-testosterone',
    myth: 'Low libido always means low testosterone.',
    evidence:
        'Stress, sleep, mood, relationships, medicines and alcohol commonly affect desire. Diagnosing low testosterone needs compatible symptoms plus repeated morning blood tests.',
    sources: [Src.nhsLibido, Src.auaTestosterone],
    relatedArticle: 'libido-contributors',
  ),
  Myth(
    id: 'magic-food',
    myth: 'A particular food guarantees stronger erections.',
    evidence:
        'No single food is a proven treatment. Overall eating patterns that support heart and metabolic health are linked to lower ED risk.',
    sources: [Src.niddkEdDiet],
    relatedArticle: 'eating-for-vascular-health',
  ),
  Myth(
    id: 'everyone-quit-porn',
    myth: 'Everyone must stop watching pornography.',
    evidence:
        'Research is mixed and mostly observational. Some people notice effects on expectations or arousal; many do not. Changing habits is a personal choice, and distress or loss of control is the signal to seek support.',
    sources: [Src.eauSexual],
    relatedArticle: 'porn-and-expectations',
  ),
  Myth(
    id: 'longer-better',
    myth: 'Longer sex is always better.',
    evidence:
        'Satisfaction depends on connection, communication and pleasure, not a stopwatch. PE is defined by lack of control and distress, not a universal time target.',
    sources: [Src.issmPe, Src.nhsEjaculation],
    relatedArticle: 'understanding-pe',
  ),
  Myth(
    id: 'always-ready',
    myth: 'A man must always be ready for sex.',
    evidence:
        'Desire and arousal naturally vary with stress, tiredness, mood and context. Not being in the mood is normal and does not reflect masculinity.',
    sources: [Src.nhsLibido],
    relatedArticle: 'libido-variation',
  ),
  Myth(
    id: 'natural-safe',
    myth: 'Natural supplements are always safe.',
    evidence:
        'The FDA has found hidden prescription drug ingredients in many sexual enhancement products. These can interact dangerously with other medicines, including nitrates.',
    sources: [Src.fdaTainted],
    relatedArticle: 'supplements-guide',
  ),
  Myth(
    id: 'firmness-masculinity',
    myth: 'Erection firmness measures masculinity.',
    evidence:
        'Erections reflect blood flow, nerves, hormones and mental state on a given day. They say nothing about worth or masculinity, and variation is normal.',
    sources: [Src.niddkEd],
    relatedArticle: 'erection-variability',
  ),
];
