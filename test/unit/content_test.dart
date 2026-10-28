import 'package:flutter_test/flutter_test.dart';
import 'package:men_health_and_wellness/features/education/data/article_repository.dart';
import 'package:men_health_and_wellness/features/education/data/content/content_library.dart';
import 'package:men_health_and_wellness/features/education/data/content/sources.dart';
import 'package:men_health_and_wellness/features/education/domain/article.dart';
import 'package:men_health_and_wellness/features/health_hub/domain/health_topic.dart';
import 'package:men_health_and_wellness/features/home/domain/daily_plan.dart';
import 'package:men_health_and_wellness/features/reflections/domain/reflection_catalog.dart';
import 'package:men_health_and_wellness/features/reflections/domain/reflection_rules.dart';
import 'package:men_health_and_wellness/shared/models/enums.dart';

void main() {
  final repo = ArticleRepository(bundledArticles);

  group('content integrity', () {
    test('ids are unique', () {
      final ids = bundledArticles.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every article is complete and sourced from the register', () {
      for (final a in bundledArticles) {
        expect(a.sources, isNotEmpty, reason: a.id);
        expect(a.sections, isNotEmpty, reason: a.id);
        expect(a.evidenceSupports, isNotEmpty, reason: a.id);
        expect(a.nextSteps, isNotEmpty, reason: a.id);
        expect(a.seeClinician, isNotEmpty, reason: a.id);
        expect(DateTime.tryParse(a.authoredOn), isNotNull);
        expect(DateTime.parse(a.nextReviewOn).isAfter(DateTime.parse(a.authoredOn)), isTrue);
        for (final s in a.sources) {
          expect(Src.all, contains(s), reason: '${a.id} cites unregistered ${s.id}');
          expect(s.url, startsWith('https://'));
        }
      }
    });

    test('every category has content', () {
      for (final c in ArticleCategory.values) {
        expect(repo.byCategory(c), isNotEmpty, reason: c.name);
      }
    });

    test('all cross references resolve', () {
      for (final a in bundledArticles) {
        for (final r in a.related) {
          expect(repo.byId(r), isNotNull, reason: '${a.id} -> $r');
        }
      }
      for (final m in repo.myths()) {
        expect(repo.byId(m.relatedArticle!), isNotNull, reason: m.id);
      }
      for (final g in WellnessGoal.values) {
        for (final (_, id) in DailyPlan.recommendedArticles({g})) {
          expect(repo.byId(id), isNotNull, reason: id);
        }
      }
    });

    test('reflection rules only suggest existing articles', () {
      const rules = ReflectionRules();
      for (final r in ReflectionCatalog.all) {
        final everything = {for (final q in r.questions) q.id: q.options.map((o) => o.id).toSet()};
        final outcome = rules.evaluate(r, everything);
        for (final id in outcome.articleIds) {
          expect(repo.byId(id), isNotNull, reason: '${r.id} -> $id');
        }
      }
    });

    test('topics reference real reflections', () {
      for (final t in HealthTopics.all) {
        if (t.reflectionId != null) expect(ReflectionCatalog.byId(t.reflectionId!), isNotNull);
      }
    });

    test('nitrate warning is present on ED treatment content', () {
      final a = repo.byId('ed-treatments')!;
      expect(a.safetyWarnings.join(), contains('nitrate'));
    });

    test('content makes no guarantee or cure claims', () {
      final pattern = RegExp(r'\b(guarantees?|cures?)\b', caseSensitive: false);
      for (final a in bundledArticles) {
        final text = [
          a.title,
          a.summary,
          for (final s in a.sections) ...[...s.paragraphs, ...s.bullets],
        ].join(' ');
        for (final m in pattern.allMatches(text)) {
          final window = text.substring((m.start - 40).clamp(0, text.length), m.start).toLowerCase();
          expect(
            window.contains('no ') || window.contains('not ') || window.contains("n't"),
            isTrue,
            reason: '${a.id}: "...$window${m.group(0)}"',
          );
        }
      }
    });
  });

  group('search', () {
    test('empty query returns nothing', () => expect(repo.search('  '), isEmpty));

    test('synonyms map lay terms to content', () {
      expect(repo.search('viagra').map((a) => a.id), contains('ed-treatments'));
      expect(repo.search('last longer').first.category, ArticleCategory.ejaculation);
      expect(repo.search('low t').map((a) => a.id), contains('testosterone-facts'));
    });

    test('title matches rank first', () {
      expect(repo.search('sleep').first.id, 'sleep-and-sexual-wellbeing');
    });
  });

  group('daily plan', () {
    test('is transparent and limited', () {
      final plan = DailyPlan.forDay({WellnessGoal.anxiety}, DateTime(2026, 10, 28));
      expect(plan.length, 3);
      expect(plan.every((p) => p.reason != null), isTrue);
    });

    test('works with no goals', () {
      expect(DailyPlan.forDay({}, DateTime(2026, 1, 1)), hasLength(3));
    });
  });
}
