import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_components.dart';
import '../controllers/library_controller.dart';
import '../widgets/article_widgets.dart';

/// Offline search. The query lives only in memory and is discarded when
/// the screen closes — search history is never stored.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  static const _suggestions = ['Erections', 'Sleep', 'Stress', 'Desire', 'Exercise', 'Communication', 'Testosterone'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    ref.read(searchQueryProvider.notifier).set(q);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    return ClayPage(
      title: 'Search',
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
          decoration: InputDecoration(
            hintText: 'Search the library',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => _setQuery(''),
                  ),
          ),
        ),
        const SizedBox(height: Gap.sm),
        Text('Searches stay on this device and are not saved.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: Gap.lg),
        if (query.trim().isEmpty)
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final s in _suggestions)
                ClayChoiceChip(label: s, selected: false, icon: Icons.search_rounded, onTap: () => _setQuery(s)),
            ],
          )
        else if (results.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No matching articles',
            message: 'Try a broader word such as "erection", "sleep" or "stress".',
          )
        else ...[
          Semantics(
            liveRegion: true,
            child: Text('${results.length} results', style: Theme.of(context).textTheme.labelMedium),
          ),
          const SizedBox(height: Gap.md),
          for (final a in results) ArticleCard(article: a),
        ],
      ],
    );
  }
}
