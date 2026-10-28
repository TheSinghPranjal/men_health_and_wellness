import 'package:flutter_test/flutter_test.dart';
import 'package:men_health_and_wellness/features/reflections/domain/reflection.dart';
import 'package:men_health_and_wellness/features/reflections/domain/reflection_catalog.dart';
import 'package:men_health_and_wellness/features/reflections/domain/reflection_rules.dart';

void main() {
  const rules = ReflectionRules();
  ReflectionOutcome eval(Reflection r, Map<String, Set<String>> a) => rules.evaluate(r, a);

  String allText(ReflectionOutcome o) =>
      [...o.reflectionPoints, ...o.careReasons, o.careLevel.title, o.careLevel.explanation].join(' ').toLowerCase();

  group('erectile reflection', () {
    test('occasional difficulty suggests self-care and never a diagnosis', () {
      final o = eval(ReflectionCatalog.erectile, {
        'duration': {'lt1m'},
        'frequency': {'rarely'},
        'distress': {'none'},
      });
      expect(o.careLevel, CareLevel.selfCare);
      expect(o.careLevel.explanation, contains('not the same as ruling out'));
      expect(o.articleIds, contains('erection-variability'));
    });

    test('persistent, frequent difficulty recommends an appointment and heart-health check', () {
      final o = eval(ReflectionCatalog.erectile, {
        'duration': {'gt6m'},
        'frequency': {'mostly'},
      });
      expect(o.careLevel, CareLevel.appointment);
      expect(o.reflectionPoints.join(), contains('blood pressure'));
      expect(o.articleIds, contains('when-to-see-clinician'));
    });

    test('chest pain escalates to prompt care with emergency link', () {
      final o = eval(ReflectionCatalog.erectile, {
        'frequency': {'rarely'},
        'symptoms': {'chest'},
      });
      expect(o.careLevel, CareLevel.prompt);
      expect(o.articleIds, contains('emergency-signs'));
    });

    test('medication change advises talking to prescriber, not stopping', () {
      final o = eval(ReflectionCatalog.erectile, {
        'changes': {'medication'},
      });
      expect(o.careReasons.join(), contains('do not stop it'));
    });

    test('never uses diagnostic labels', () {
      final o = eval(ReflectionCatalog.erectile, {
        'duration': {'gt6m'},
        'frequency': {'mostly'},
        'context': {'all'},
        'distress': {'alot'},
      });
      final text = allText(o);
      for (final banned in ['you have', 'diagnos', 'severe ed', 'moderate ed', 'normal erectile']) {
        expect(text.contains(banned), isFalse, reason: banned);
      }
    });
  });

  group('ejaculation reflection', () {
    test('blood in semen recommends appointment', () {
      final o = eval(ReflectionCatalog.ejaculation, {
        'alsoPresent': {'blood'},
      });
      expect(o.careLevel, CareLevel.appointment);
    });

    test('coexisting erection difficulty points to ED-and-PE article', () {
      final o = eval(ReflectionCatalog.ejaculation, {
        'concern': {'early'},
        'alsoPresent': {'erection'},
      });
      expect(o.articleIds, containsAll(['understanding-pe', 'ed-and-pe', 'pe-techniques']));
    });

    test('delayed concern links delayed ejaculation article', () {
      final o = eval(ReflectionCatalog.ejaculation, {
        'concern': {'delayed'},
      });
      expect(o.articleIds, contains('delayed-ejaculation'));
      expect(o.articleIds, isNot(contains('understanding-pe')));
    });
  });

  group('desire reflection', () {
    test('low mood shows mental-health support', () {
      final o = eval(ReflectionCatalog.desire, {
        'symptoms': {'mood'},
      });
      expect(o.showMentalHealthSupport, isTrue);
      expect(o.careLevel, CareLevel.appointment);
    });

    test('always states low desire does not mean low testosterone', () {
      final o = eval(ReflectionCatalog.desire, {});
      expect(o.reflectionPoints, contains('Low desire alone does not mean low testosterone.'));
    });
  });

  group('porn reflection', () {
    test('never labels the user as addicted', () {
      final o = eval(ReflectionCatalog.porn, {
        'control': {'often'},
        'time': {'often'},
        'distress': {'alot'},
      });
      expect(o.careLevel, CareLevel.appointment);
      expect(allText(o).contains('you are addicted'), isFalse);
      expect(o.reflectionPoints.join(), contains('does not make you addicted'));
    });

    test('experiment interest surfaces the experiment', () {
      final o = eval(ReflectionCatalog.porn, {
        'experiment': {'yes'},
      });
      expect(o.showExperiment, isTrue);
    });
  });

  test('answer summary lists chosen labels in question order', () {
    final o = eval(ReflectionCatalog.energy, {
      'sleepHours': {'lt6'},
      'symptoms': {'snoring', 'sleepy'},
    });
    expect(o.answerSummary.first.$2, 'Less than 6 hours');
    expect(o.answerSummary.last.$2, contains('Loud snoring'));
    expect(o.careLevel, CareLevel.appointment);
  });

  test('session serialization round-trips and rejects corrupt input', () {
    final s = ReflectionSession(
      id: 'a',
      reflectionId: 'erectile',
      completedAt: DateTime(2026, 1, 2),
      answers: {
        'frequency': {'often'},
      },
    );
    final back = ReflectionSession.fromJson(s.toJson())!;
    expect(back.answers['frequency'], {'often'});
    expect(ReflectionSession.fromJson({'id': 1}), isNull);
  });
}
