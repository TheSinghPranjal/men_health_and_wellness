import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/dates.dart';
import '../../data/article_repository.dart';
import '../../data/library_repository.dart';
import '../../domain/article.dart';
import '../../domain/library_state.dart';

class LibraryController extends Notifier<LibraryState> {
  @override
  LibraryState build() => ref.watch(libraryRepositoryProvider).load();

  Future<void> toggleBookmark(String id) => _save(state.toggleBookmark(id));

  Future<void> markViewed(String id) {
    final today = Dates.key(ref.read(clockProvider)());
    return _save(state.markViewed(id, today));
  }

  Future<void> clearHistory() async {
    await ref.read(libraryRepositoryProvider).clearHistory();
    state = ref.read(libraryRepositoryProvider).load();
  }

  void reload() => state = ref.read(libraryRepositoryProvider).load();

  Future<void> _save(LibraryState next) async {
    await ref.read(libraryRepositoryProvider).save(next);
    state = next;
  }
}

final libraryProvider = NotifierProvider<LibraryController, LibraryState>(LibraryController.new);

final bookmarkedArticlesProvider = Provider<List<Article>>((ref) {
  final repo = ref.watch(articleRepositoryProvider);
  final ids = ref.watch(libraryProvider.select((s) => s.bookmarks));
  return [for (final id in ids) ?repo.byId(id)];
});

final recentArticlesProvider = Provider<List<Article>>((ref) {
  final repo = ref.watch(articleRepositoryProvider);
  final ids = ref.watch(libraryProvider.select((s) => s.recent));
  return [for (final id in ids) ?repo.byId(id)];
});

/// Search text is held only in memory and never persisted.
class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final searchQueryProvider = NotifierProvider.autoDispose<SearchQueryController, String>(SearchQueryController.new);

final searchResultsProvider = Provider.autoDispose<List<Article>>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(articleRepositoryProvider).search(query);
});
