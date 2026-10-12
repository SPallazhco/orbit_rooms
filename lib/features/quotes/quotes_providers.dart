import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';

import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_list_order.dart';

import 'data/quote_repository.dart';
import 'domain/quote_pricing.dart';

final quoteRepositoryProvider = Provider<QuoteRepository>(
  (ref) => QuoteRepository(ref.watch(appDatabaseProvider)),
);

/// Estado reactivo, mismo patrón que `activePropertiesProvider`.
final quotesProvider =
    StreamProvider<
      List<
        ({Quote quote, String propertyName, String? ownerName, String roomName})
      >
    >((ref) => ref.watch(quoteRepositoryProvider).watchAll());

final quoteDayLinesProvider = StreamProvider.family<List<QuoteDayLine>, String>(
  (ref, quoteId) => ref.watch(quoteRepositoryProvider).watchDayLines(quoteId),
);

final quoteChildGroupsProvider =
    StreamProvider.family<List<QuoteChildGroup>, String>(
      (ref, quoteId) =>
          ref.watch(quoteRepositoryProvider).watchChildGroups(quoteId),
    );

final quoteChildRatesProvider =
    StreamProvider.family<List<QuoteChildRate>, String>(
      (ref, quoteId) =>
          ref.watch(quoteRepositoryProvider).watchChildRates(quoteId),
    );

/// Mismo patrón de provider derivado que `dashboardDataProvider`: combina
/// los tres streams de la cotización en un desglose ya calculado, sin
/// consulta nueva.
final quoteBreakdownProvider =
    Provider.family<
      AsyncValue<QuoteBreakdown>,
      ({String quoteId, int adultsCount})
    >((ref, key) {
      final dayLinesAsync = ref.watch(quoteDayLinesProvider(key.quoteId));
      final groupsAsync = ref.watch(quoteChildGroupsProvider(key.quoteId));
      final ratesAsync = ref.watch(quoteChildRatesProvider(key.quoteId));

      if (dayLinesAsync.isLoading ||
          groupsAsync.isLoading ||
          ratesAsync.isLoading) {
        return const AsyncValue.loading();
      }
      final error =
          dayLinesAsync.error ?? groupsAsync.error ?? ratesAsync.error;
      if (error != null) {
        return AsyncValue.error(error, StackTrace.current);
      }

      return AsyncValue.data(
        buildQuoteBreakdown(
          adultsCount: key.adultsCount,
          dayLines: dayLinesAsync.value!,
          groups: groupsAsync.value!,
          rates: ratesAsync.value!,
        ),
      );
    });

typedef QuoteSummary = ({int totalCents, int childrenCount});

final _allDayLinesProvider = StreamProvider<List<QuoteDayLine>>(
  (ref) => ref.watch(quoteRepositoryProvider).watchAllDayLines(),
);

final _allChildGroupsProvider = StreamProvider<List<QuoteChildGroup>>(
  (ref) => ref.watch(quoteRepositoryProvider).watchAllChildGroups(),
);

final _allChildRatesProvider = StreamProvider<List<QuoteChildRate>>(
  (ref) => ref.watch(quoteRepositoryProvider).watchAllChildRates(),
);

/// Total y cantidad de niños por cotización, para la lista. Mismo patrón de
/// provider derivado que `quoteBreakdownProvider`, pero de todas las
/// cotizaciones a la vez en vez de una sola.
final quoteSummariesProvider = Provider<AsyncValue<Map<String, QuoteSummary>>>((
  ref,
) {
  final quotesAsync = ref.watch(quotesProvider);
  final dayLinesAsync = ref.watch(_allDayLinesProvider);
  final groupsAsync = ref.watch(_allChildGroupsProvider);
  final ratesAsync = ref.watch(_allChildRatesProvider);

  if (quotesAsync.isLoading ||
      dayLinesAsync.isLoading ||
      groupsAsync.isLoading ||
      ratesAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final error =
      quotesAsync.error ??
      dayLinesAsync.error ??
      groupsAsync.error ??
      ratesAsync.error;
  if (error != null) {
    return AsyncValue.error(error, StackTrace.current);
  }

  final dayLines = dayLinesAsync.value!;
  final groups = groupsAsync.value!;
  final rates = ratesAsync.value!;
  final groupIdsByQuote = <String, Set<String>>{};
  for (final g in groups) {
    groupIdsByQuote.putIfAbsent(g.quoteId, () => {}).add(g.id);
  }

  return AsyncValue.data({
    for (final entry in quotesAsync.value!)
      entry.quote.id: () {
        final breakdown = buildQuoteBreakdown(
          adultsCount: entry.quote.adultsCount,
          dayLines: dayLines.where((l) => l.quoteId == entry.quote.id).toList(),
          groups: groups.where((g) => g.quoteId == entry.quote.id).toList(),
          rates: rates
              .where(
                (r) =>
                    groupIdsByQuote[entry.quote.id]?.contains(r.groupId) ??
                    false,
              )
              .toList(),
        );
        return (
          totalCents: breakdown.totalCents,
          childrenCount: breakdown.childrenCount,
        );
      }(),
  });
});

typedef QuoteReminder = ({
  Quote quote,
  String propertyName,
  String roomName,
  int daysLeft,
  QuoteSummary summary,
});

typedef ReminderInbox = ({
  List<QuoteReminder> toRemind,
  List<QuoteReminder> reminded,
});

/// La campana de avisos: cotizaciones **pendientes** cuyo check-in está a
/// `quoteReminderDays` días o menos (incluido el mismo día), separadas entre
/// las que todavía hay que recordar y las que ya se recordaron. No guarda
/// nada: se calcula sola, así desaparece cuando la cotización se reserva o
/// se rechaza, y cuando pasa el día del check-in.
final reminderInboxProvider = Provider<AsyncValue<ReminderInbox>>((ref) {
  final quotesAsync = ref.watch(quotesProvider);
  final summariesAsync = ref.watch(quoteSummariesProvider);
  final daysAsync = ref.watch(quoteReminderDaysProvider);

  if (quotesAsync.isLoading ||
      summariesAsync.isLoading ||
      daysAsync.isLoading) {
    return const AsyncValue.loading();
  }
  final error = quotesAsync.error ?? summariesAsync.error ?? daysAsync.error;
  if (error != null) return AsyncValue.error(error, StackTrace.current);

  final now = DateTime.now();
  final window = daysAsync.value!;
  final summaries = summariesAsync.value!;

  final due = <QuoteReminder>[];
  for (final entry in quotesAsync.value!) {
    if (entry.quote.status != QuoteStatus.pending) continue;
    final daysLeft = daysUntil(entry.quote.checkInDate, now);
    if (daysLeft < 0 || daysLeft > window) continue;
    due.add((
      quote: entry.quote,
      propertyName: entry.propertyName,
      roomName: entry.roomName,
      daysLeft: daysLeft,
      summary: summaries[entry.quote.id] ?? (totalCents: 0, childrenCount: 0),
    ));
  }

  final toRemind = due.where((r) => r.quote.reminderSentAt == null).toList()
    ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  final reminded = due.where((r) => r.quote.reminderSentAt != null).toList()
    ..sort(
      (a, b) => b.quote.reminderSentAt!.compareTo(a.quote.reminderSentAt!),
    );

  return AsyncValue.data((toRemind: toRemind, reminded: reminded));
});
