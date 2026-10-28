import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_value_store.dart';

/// Overridden in `bootstrap.dart` (and in tests) with an opened storage.
final appStorageProvider = Provider<AppStorage>(
  (ref) => throw UnimplementedError('appStorageProvider must be overridden'),
);

/// Clock seam so date logic is testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
