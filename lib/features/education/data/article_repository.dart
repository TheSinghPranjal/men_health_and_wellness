import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/article.dart';
import '../domain/article_search.dart';
import 'content/content_library.dart';
import 'content/myths.dart' as content;

/// Read-only access to bundled educational content.
class ArticleRepository {
  ArticleRepository(this._articles) : _byId = {for (final a in _articles) a.id: a};

  final List<Article> _articles;
  final Map<String, Article> _byId;
  late final ArticleSearch _search = ArticleSearch(_articles);

  List<Article> all() => _articles;
  Article? byId(String id) => _byId[id];
  List<Article> byCategory(ArticleCategory c) => _articles.where((a) => a.category == c).toList();
  List<Article> search(String query) => _search.search(query);
  List<Myth> myths() => content.myths;

  List<Article> related(Article article) => [for (final id in article.related) ?_byId[id]];
}

final articleRepositoryProvider = Provider<ArticleRepository>((ref) => ArticleRepository(bundledArticles));
