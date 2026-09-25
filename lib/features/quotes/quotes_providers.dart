import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';

import 'data/quote_repository.dart';

final quoteRepositoryProvider = Provider<QuoteRepository>(
  (ref) => QuoteRepository(ref.watch(appDatabaseProvider)),
);

/// Estado reactivo, mismo patrón que `activePropertiesProvider`.
final quotesProvider =
    StreamProvider<List<({Quote quote, String propertyName, String roomName})>>(
      (ref) => ref.watch(quoteRepositoryProvider).watchAll(),
    );

final quoteDayLinesProvider = StreamProvider.family<List<QuoteDayLine>, String>(
  (ref, quoteId) => ref.watch(quoteRepositoryProvider).watchDayLines(quoteId),
);
