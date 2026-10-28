import '../../domain/article.dart';

/// Source register. Every URL here was checked to resolve when the content
/// was authored (2026-10-28). See docs/CONTENT_REVIEW.md.
abstract final class Src {
  static const niddkEd = Source(
    id: 'niddk-ed',
    title: 'Erectile Dysfunction (ED)',
    publisher: 'NIDDK, U.S. National Institutes of Health',
    url: 'https://www.niddk.nih.gov/health-information/urologic-diseases/erectile-dysfunction',
  );
  static const niddkEdCauses = Source(
    id: 'niddk-ed-causes',
    title: 'Symptoms & Causes of Erectile Dysfunction',
    publisher: 'NIDDK, U.S. National Institutes of Health',
    url: 'https://www.niddk.nih.gov/health-information/urologic-diseases/erectile-dysfunction/symptoms-causes',
  );
  static const niddkEdTreatment = Source(
    id: 'niddk-ed-treatment',
    title: 'Treatment for Erectile Dysfunction',
    publisher: 'NIDDK, U.S. National Institutes of Health',
    url: 'https://www.niddk.nih.gov/health-information/urologic-diseases/erectile-dysfunction/treatment',
  );
  static const niddkEdDiet = Source(
    id: 'niddk-ed-diet',
    title: 'Eating, Diet, & Nutrition for Erectile Dysfunction',
    publisher: 'NIDDK, U.S. National Institutes of Health',
    url: 'https://www.niddk.nih.gov/health-information/urologic-diseases/erectile-dysfunction/eating-diet-nutrition',
  );
  static const nhsEd = Source(
    id: 'nhs-ed',
    title: 'Erectile dysfunction (impotence)',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/conditions/erection-problems-erectile-dysfunction/',
  );
  static const nhsEjaculation = Source(
    id: 'nhs-ejaculation',
    title: 'Ejaculation problems',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/conditions/ejaculation-problems/',
  );
  static const nhsLibido = Source(
    id: 'nhs-libido',
    title: 'Loss of libido (reduced sex drive)',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/conditions/loss-of-libido/',
  );
  static const nhsPriapism = Source(
    id: 'nhs-priapism',
    title: 'Priapism (painful erections)',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/conditions/priapism/',
  );
  static const nhsPeyronies = Source(
    id: 'nhs-peyronies',
    title: "Peyronie's disease",
    publisher: 'NHS',
    url: 'https://www.nhs.uk/conditions/peyronies-disease/',
  );
  static const nhsActivity = Source(
    id: 'nhs-activity',
    title: 'Physical activity guidelines for adults aged 19 to 64',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/live-well/exercise/physical-activity-guidelines-for-adults-aged-19-to-64/',
  );
  static const nhsSleep = Source(
    id: 'nhs-sleep',
    title: 'How to get to sleep',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/live-well/sleep-and-tiredness/how-to-get-to-sleep/',
  );
  static const nhsSleepApnoea = Source(
    id: 'nhs-sleep-apnoea',
    title: 'Sleep apnoea',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/conditions/sleep-apnoea/',
  );
  static const nhsTired = Source(
    id: 'nhs-tired',
    title: 'Why am I tired all the time?',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/live-well/sleep-and-tiredness/why-am-i-tired-all-the-time/',
  );
  static const nhsBreathing = Source(
    id: 'nhs-breathing',
    title: 'Breathing exercises for stress',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/breathing-exercises-for-stress/',
  );
  static const nhsStress = Source(
    id: 'nhs-stress',
    title: 'Tips to reduce stress',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/tips-to-reduce-stress/',
  );
  static const nhsAnxiety = Source(
    id: 'nhs-anxiety',
    title: 'Anxiety',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/mental-health/conditions/anxiety/',
  );
  static const nhsDepression = Source(
    id: 'nhs-depression',
    title: 'Clinical depression',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/conditions/clinical-depression/',
  );
  static const nhsEatWell = Source(
    id: 'nhs-eat-well',
    title: 'Eat well',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/live-well/eat-well/',
  );
  static const nhsHealthyWeight = Source(
    id: 'nhs-healthy-weight',
    title: 'Healthy weight',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/live-well/healthy-weight/',
  );
  static const nhsQuitSmoking = Source(
    id: 'nhs-quit-smoking',
    title: 'Quit smoking',
    publisher: 'NHS Better Health',
    url: 'https://www.nhs.uk/better-health/quit-smoking/',
  );
  static const nhsAlcohol = Source(
    id: 'nhs-alcohol',
    title: 'Tips on cutting down alcohol',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/live-well/alcohol-advice/tips-on-cutting-down-alcohol/',
  );
  static const nhsSexualHealth = Source(
    id: 'nhs-sexual-health',
    title: 'Sexual health',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/live-well/sexual-health/',
  );
  static const nhsTadalafil = Source(
    id: 'nhs-tadalafil',
    title: 'Tadalafil',
    publisher: 'NHS',
    url: 'https://www.nhs.uk/medicines/tadalafil/',
  );
  static const auaEd = Source(
    id: 'aua-ed',
    title: 'Erectile Dysfunction (ED) Guideline',
    publisher: 'American Urological Association',
    url: 'https://www.auanet.org/guidelines-and-quality/guidelines/erectile-dysfunction-(ed)-guideline',
  );
  static const auaEjaculation = Source(
    id: 'aua-ejaculation',
    title: 'Disorders of Ejaculation Guideline',
    publisher: 'American Urological Association',
    url: 'https://www.auanet.org/guidelines-and-quality/guidelines/disorders-of-ejaculation',
  );
  static const auaTestosterone = Source(
    id: 'aua-testosterone',
    title: 'Testosterone Deficiency Guideline',
    publisher: 'American Urological Association',
    url: 'https://www.auanet.org/guidelines-and-quality/guidelines/testosterone-deficiency-guideline',
  );
  static const eauSexual = Source(
    id: 'eau-sexual',
    title: 'Guidelines on Sexual and Reproductive Health',
    publisher: 'European Association of Urology',
    url: 'https://uroweb.org/guidelines/sexual-and-reproductive-health',
  );
  static const issmQa = Source(
    id: 'issm-qa',
    title: 'Sexual Health Q&A',
    publisher: 'International Society for Sexual Medicine',
    url: 'https://www.issm.info/sexual-health-qa',
  );
  static const issmPe = Source(
    id: 'issm-pe',
    title: 'What is premature ejaculation?',
    publisher: 'International Society for Sexual Medicine',
    url: 'https://www.issm.info/sexual-health-qa/what-is-premature-ejaculation',
  );
  static const smsnaDe = Source(
    id: 'smsna-de',
    title: 'Delayed Ejaculation',
    publisher: 'Sexual Medicine Society of North America',
    url: 'https://smsna.org/patients/conditions/delayed-ejaculation',
  );

  static const fdaTainted = Source(
    id: 'fda-tainted',
    title: 'Sexual Enhancement and Energy Product Notifications',
    publisher: 'U.S. Food and Drug Administration',
    url:
        'https://www.fda.gov/drugs/medication-health-fraud-notifications/sexual-enhancement-and-energy-product-notifications',
  );

  static const all = [
    niddkEd,
    niddkEdCauses,
    niddkEdTreatment,
    niddkEdDiet,
    nhsEd,
    nhsEjaculation,
    nhsLibido,
    nhsPriapism,
    nhsPeyronies,
    nhsActivity,
    nhsSleep,
    nhsSleepApnoea,
    nhsTired,
    nhsBreathing,
    nhsStress,
    nhsAnxiety,
    nhsDepression,
    nhsEatWell,
    nhsHealthyWeight,
    nhsQuitSmoking,
    nhsAlcohol,
    nhsSexualHealth,
    nhsTadalafil,
    auaEd,
    auaEjaculation,
    auaTestosterone,
    eauSexual,
    issmQa,
    issmPe,
    smsnaDe,
    fdaTainted,
  ];
}
