import 'article.dart';

/// Offline, rule-based article search over titles, summaries, categories,
/// keywords and a small synonym table.
class ArticleSearch {
  ArticleSearch(this.articles);
  final List<Article> articles;

  /// Plain-language and slang terms mapped to terms used in content.
  static const synonyms = <String, List<String>>{
    'impotence': ['erectile dysfunction', 'ed'],
    'hard': ['erection'],
    'boner': ['erection'],
    'stamina': ['premature ejaculation', 'control'],
    'last longer': ['premature ejaculation', 'control'],
    'finish early': ['premature ejaculation'],
    'cum': ['ejaculation'],
    'climax': ['orgasm'],
    'sex drive': ['libido', 'desire'],
    'horny': ['desire', 'libido'],
    'low t': ['testosterone'],
    'viagra': ['sildenafil', 'pde5'],
    'cialis': ['tadalafil', 'pde5'],
    'kegels': ['pelvic floor'],
    'nervous': ['anxiety'],
    'tired': ['fatigue', 'sleep'],
    'doctor': ['clinician'],
    'gp': ['clinician'],
    'snoring': ['sleep apnoea'],
    'sleep apnea': ['sleep apnoea'],
  };

  List<Article> search(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final terms = <String>{query, ...query.split(RegExp(r'\s+')).where((t) => t.length > 1)};
    for (final entry in synonyms.entries) {
      if (query.contains(entry.key)) terms.addAll(entry.value);
    }

    final scored = <(Article, int)>[];
    for (final article in articles) {
      final score = _score(article, terms, query);
      if (score > 0) scored.add((article, score));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final s in scored) s.$1];
  }

  int _score(Article a, Set<String> terms, String fullQuery) {
    final title = a.title.toLowerCase();
    final summary = a.summary.toLowerCase();
    final category = a.category.label.toLowerCase();
    final keywords = a.keywords.map((k) => k.toLowerCase()).toList();
    var score = 0;
    if (title.contains(fullQuery)) score += 20;
    for (final term in terms) {
      if (title.contains(term)) score += 6;
      if (keywords.any((k) => k == term)) score += 8;
      if (keywords.any((k) => k.contains(term))) score += 4;
      if (category.contains(term)) score += 3;
      if (summary.contains(term)) score += 2;
    }
    return score;
  }
}
