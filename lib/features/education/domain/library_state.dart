import 'package:flutter/foundation.dart';

/// The user's personal relationship with the library: bookmarks, recent
/// views and which articles were read (by day, for the learning metric).
@immutable
class LibraryState {
  const LibraryState({this.bookmarks = const [], this.recent = const [], this.readOn = const {}});

  static const maxRecent = 10;

  final List<String> bookmarks;
  final List<String> recent;

  /// articleId -> day key when first read.
  final Map<String, String> readOn;

  bool isBookmarked(String id) => bookmarks.contains(id);

  LibraryState toggleBookmark(String id) => LibraryState(
    bookmarks: isBookmarked(id) ? (bookmarks.where((b) => b != id).toList()) : [id, ...bookmarks],
    recent: recent,
    readOn: readOn,
  );

  LibraryState markViewed(String id, String dayKey) => LibraryState(
    bookmarks: bookmarks,
    recent: [id, ...recent.where((r) => r != id)].take(maxRecent).toList(),
    readOn: readOn.containsKey(id) ? readOn : {...readOn, id: dayKey},
  );

  Map<String, dynamic> toJson() => {'_v': 1, 'bookmarks': bookmarks, 'recent': recent, 'readOn': readOn};

  factory LibraryState.fromJson(Map<String, dynamic> json) => LibraryState(
    bookmarks: (json['bookmarks'] as List?)?.whereType<String>().toList() ?? const [],
    recent: (json['recent'] as List?)?.whereType<String>().toList() ?? const [],
    readOn: (json['readOn'] as Map?)?.map((k, v) => MapEntry(k as String, v as String)) ?? const {},
  );
}
