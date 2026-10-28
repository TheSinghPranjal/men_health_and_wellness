import '../../domain/article.dart';
import 'sources.dart';

/// Treatments, supplements, clinician care and safety.
const careArticles = <Article>[
  Article(
    id: 'ed-treatments',
    title: 'Erectile dysfunction treatments explained',
    summary:
        'Treatment depends on the cause, your health and your preferences. Options range from lifestyle and counselling to tablets, devices, injections and surgery.',
    category: ArticleCategory.treatments,
    keywords: [
      'viagra',
      'sildenafil',
      'tadalafil',
      'cialis',
      'PDE5',
      'pump',
      'vacuum device',
      'injection',
      'implant',
      'treatment',
    ],
    related: ['how-erections-work', 'understanding-ed', 'supplements-guide', 'when-to-see-clinician'],
    safetyWarnings: [
      'PDE5 inhibitors (such as sildenafil and tadalafil) must not be combined with nitrate medicines, because the combination can cause a dangerous drop in blood pressure.',
      'Seek urgent care for an erection lasting 4 hours or more, or sudden vision or hearing loss after taking an ED medicine.',
    ],
    sections: [
      ArticleSection(
        heading: 'Treatment categories',
        bullets: [
          'Lifestyle and risk-factor management: activity, nutrition, sleep, stopping smoking, and managing blood pressure, blood sugar and cholesterol.',
          'Psychosexual or relationship counselling, alone or alongside other treatments.',
          'PDE5 inhibitor tablets such as sildenafil and tadalafil, which improve blood flow and require sexual stimulation to work.',
          'Vacuum erection devices, which draw blood into the penis and use a ring to maintain the erection.',
          'Medicines given by injection into the penis or as a urethral pellet, taught by a clinician.',
          'Penile prosthesis surgery, usually considered when other options have not worked.',
        ],
      ),
      ArticleSection(
        heading: 'Talking to a clinician about tablets',
        paragraphs: [
          'Before prescribing, a clinician will ask about heart conditions, blood pressure, other medicines (especially nitrates and some alpha-blockers), and recreational drug use. Tell them about all medicines and supplements you take.',
          'This app does not provide prescriptions or doses. Only obtain medicines through a licensed prescriber or pharmacist.',
        ],
      ),
    ],
    evidenceSupports: [
      'PDE5 inhibitors are an established first-line medical treatment for many men with ED.',
      'Guidelines support shared decision-making across a range of treatment options.',
    ],
    uncertain: ['Which treatment works best for an individual often requires trying options under clinical guidance.'],
    nextSteps: ['Prepare for an appointment using the clinician checklist.'],
    seeClinician: ['To find out whether a treatment is safe and suitable for you.'],
    sources: [Src.niddkEdTreatment, Src.auaEd, Src.nhsTadalafil, Src.eauSexual],
  ),
  Article(
    id: 'pe-treatments',
    title: 'Medical options for premature ejaculation',
    summary:
        'A clinician may discuss topical anaesthetics, certain medicines, treating coexisting ED, and psychosexual therapy. Each has benefits, side effects and regional differences.',
    category: ArticleCategory.treatments,
    keywords: ['dapoxetine', 'SSRI', 'clomipramine', 'numbing spray', 'lidocaine', 'topical', 'PE treatment'],
    related: ['understanding-pe', 'pe-techniques', 'ed-and-pe'],
    safetyWarnings: [
      'Topical anaesthetics can reduce sensation for you and a partner. Follow product-specific instructions to reduce transfer.',
      'Do not self-prescribe antidepressants for PE. They need clinical assessment and have side effects and interactions.',
    ],
    sections: [
      ArticleSection(
        heading: 'Topical anaesthetics',
        paragraphs: [
          'Creams or sprays reduce sensitivity of the penis. Evidence supports benefit for some men. Side effects include numbness and reduced pleasure, and transfer to a partner can occur unless the product\'s instructions (such as washing off or using a condom) are followed.',
        ],
      ),
      ArticleSection(
        heading: 'Oral medicines',
        bullets: [
          'Dapoxetine: a short-acting medicine taken before sex, approved for PE in a number of countries but not in all (for example, not in the United States). Possible side effects include nausea, dizziness and headache.',
          'Certain daily SSRI antidepressants or clomipramine may be used off-label by a clinician. They can cause side effects such as nausea, tiredness and reduced libido, and should not be stopped abruptly.',
          'If ED is also present, treating it may help.',
        ],
      ),
      ArticleSection(
        heading: 'Psychological approaches',
        paragraphs: [
          'Psychosexual therapy, sometimes with a partner, can address anxiety and relationship factors. Combining therapy with medical treatment is often more effective than either alone.',
        ],
      ),
    ],
    evidenceSupports: [
      'Topical anaesthetics, dapoxetine, off-label SSRIs and behavioural therapy are included in guideline recommendations.',
    ],
    uncertain: ['Availability and approval differ by country.', 'Long-term outcomes after stopping treatment vary.'],
    nextSteps: ['Write down what you have already tried and how it went, to share with a clinician.'],
    seeClinician: [
      'To discuss whether any medical option is suitable, including interactions with your other medicines.',
    ],
    sources: [Src.auaEjaculation, Src.eauSexual, Src.issmPe, Src.nhsEjaculation],
  ),
  Article(
    id: 'supplements-guide',
    title: 'A critical guide to "male enhancement" supplements',
    summary:
        '"Natural" does not mean safe. Many products sold for sexual enhancement have been found to contain hidden prescription drug ingredients.',
    category: ArticleCategory.treatments,
    keywords: [
      'supplements',
      'herbal',
      'natural',
      'enhancement pills',
      'boosters',
      'ginseng',
      'L-arginine',
      'testosterone booster',
    ],
    related: ['ed-treatments', 'testosterone-facts', 'eating-for-vascular-health'],
    safetyWarnings: [
      'Products marketed for sexual enhancement may contain undeclared drugs that can interact with nitrates and cause dangerously low blood pressure.',
      'Do not combine supplements with prescription ED medicines without professional advice.',
    ],
    sections: [
      ArticleSection(
        heading: 'What regulators have found',
        paragraphs: [
          'The U.S. Food and Drug Administration warns that many products sold for sexual enhancement are likely to contain hidden ingredients, including the active ingredients of prescription ED medicines, that are not listed on the label.',
          'Labels such as "herbal" or "all natural" are not evidence of safety or effectiveness.',
        ],
      ),
      ArticleSection(
        heading: 'Evidence and quality',
        bullets: [
          'Evidence for most supplements is limited, inconsistent or based on small studies.',
          'Product content and quality vary, even between batches.',
          'Supplements can interact with medicines.',
        ],
      ),
    ],
    evidenceSupports: ['FDA testing has repeatedly found undeclared drug ingredients in sexual enhancement products.'],
    uncertain: ['Some individual ingredients are being studied, but evidence is not strong enough to recommend them.'],
    nextSteps: ['Bring any supplements you take to your next appointment or pharmacy visit.'],
    seeClinician: [
      'Before taking any supplement, especially if you have heart disease or take prescription medicines.',
    ],
    sources: [Src.fdaTainted, Src.niddkEdTreatment],
  ),
  Article(
    id: 'when-to-see-clinician',
    title: 'When to see a clinician',
    summary:
        'Sexual concerns are a normal reason to see a doctor. Some symptoms deserve prompt evaluation, and a few need emergency care.',
    category: ArticleCategory.safety,
    keywords: ['doctor', 'GP', 'appointment', 'urologist', 'clinician', 'help', 'when'],
    related: ['emergency-signs', 'understanding-ed', 'testosterone-facts'],
    sections: [
      ArticleSection(
        heading: 'Make an appointment for',
        bullets: [
          'Persistent or recurrent erection difficulties.',
          'Sudden, unexplained changes in sexual function.',
          'Persistent low desire, especially with fatigue or low mood.',
          'Painful sex, penile pain, or curvature that is new or getting worse.',
          'Blood in semen or urine.',
          'Persistent ejaculation difficulties.',
          'Significant distress or relationship impact.',
        ],
      ),
      ArticleSection(
        heading: 'Who can help',
        bullets: [
          'Primary care doctors (GPs) can assess, test and treat many concerns, and refer on.',
          'Urologists specialise in the urinary and reproductive system.',
          'Psychosexual and relationship therapists help with anxiety, desire and communication.',
          'Pelvic health physiotherapists help with pelvic floor problems.',
          'Pharmacists can advise on medicines and interactions.',
        ],
      ),
    ],
    evidenceSupports: ['Health services encourage men to seek help for erection, ejaculation and libido concerns.'],
    uncertain: [],
    nextSteps: ['Use the clinician preparation checklist to make the most of your appointment.'],
    seeClinician: ['When in doubt, ask. Clinicians discuss these topics routinely.'],
    sources: [Src.nhsEd, Src.nhsEjaculation, Src.nhsLibido, Src.nhsPeyronies],
  ),
  Article(
    id: 'emergency-signs',
    title: 'Emergency warning signs',
    summary: 'A few situations need urgent medical help. Do not wait, and do not finish anything in this app first.',
    category: ArticleCategory.safety,
    keywords: ['emergency', 'priapism', 'chest pain', 'testicular pain', 'injury', 'urgent', '4 hours'],
    related: ['when-to-see-clinician', 'ed-treatments'],
    safetyWarnings: [
      'If you have chest pain during sex, stop and get emergency help. If you have taken an ED medicine, tell the emergency team, and do not take nitrate medicine unless urgently directed by a clinician.',
    ],
    sections: [
      ArticleSection(
        heading: 'Seek emergency care for',
        bullets: [
          'An erection lasting 4 hours or longer, especially if painful (priapism).',
          'Chest pain, fainting or severe breathlessness during sexual activity.',
          'Sudden, severe pain in the testicles.',
          'A serious injury to the genitals, including a sudden "snap" with pain, swelling or bruising during sex.',
          'Signs of a severe allergic reaction, such as swelling of the face or throat or difficulty breathing.',
          'Sudden loss of vision or hearing after taking an ED medicine.',
        ],
      ),
    ],
    evidenceSupports: ['Priapism and testicular pain are recognised medical emergencies.'],
    uncertain: [],
    nextSteps: ['Call your local emergency number or go to the nearest emergency department.'],
    seeClinician: ['Immediately for any of the situations above.'],
    sources: [Src.nhsPriapism, Src.niddkEdTreatment, Src.nhsTadalafil],
  ),
];
