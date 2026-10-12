import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_list_order.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/create_quote_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/quote_detail_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/quote_card.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/reminders_bell.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

typedef _QuoteEntry = ({
  Quote quote,
  String propertyName,
  String? ownerName,
  String roomName,
});

class QuotesPage extends ConsumerStatefulWidget {
  const QuotesPage({super.key});

  @override
  ConsumerState<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends ConsumerState<QuotesPage> {
  /// `null` = todas. Arranca en pendientes: es lo que hay que atender.
  QuoteStatus? _filter = QuoteStatus.pending;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _openCreate() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const CreateQuotePage()));

  @override
  Widget build(BuildContext context) {
    final quotesAsync = ref.watch(quotesProvider);
    final summariesAsync = ref.watch(quoteSummariesProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';
    final isEmpty = quotesAsync.value?.isEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones'),
        actions: const [RemindersBell()],
      ),
      drawer: const AppDrawer(),
      body: quotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (quotes) {
          if (quotes.isEmpty) return _EmptyState(onCreate: _openCreate);

          return summariesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (summaries) => _buildList(quotes, summaries, currency),
          );
        },
      ),
      floatingActionButton: isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text('Nueva cotización'),
            ),
    );
  }

  Widget _buildList(
    List<_QuoteEntry> quotes,
    Map<String, QuoteSummary> summaries,
    String currency,
  ) {
    int countOf(QuoteStatus status) =>
        quotes.where((q) => q.quote.status == status).length;

    final byStatus = _filter == null
        ? quotes
        : quotes.where((q) => q.quote.status == _filter).toList();
    final visible = _query.isEmpty
        ? byStatus
        : byStatus.where((q) => _matches(q, _query)).toList();
    final split = splitUpcomingAndPast<_QuoteEntry>(
      visible,
      (q) => q.quote.checkInDate,
      DateTime.now(),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o contacto',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: _clearSearch,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              _filterChip(
                'Pendientes',
                countOf(QuoteStatus.pending),
                QuoteStatus.pending,
              ),
              _filterChip(
                'Reservadas',
                countOf(QuoteStatus.reserved),
                QuoteStatus.reserved,
              ),
              _filterChip(
                'Rechazadas',
                countOf(QuoteStatus.rejected),
                QuoteStatus.rejected,
              ),
              _filterChip('Todas', quotes.length, null),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? _NoResults(
                  query: _query,
                  filter: _filter,
                  onShowAll: () {
                    _searchController.clear();
                    setState(() {
                      _filter = null;
                      _query = '';
                    });
                  },
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  children: [
                    for (final entry in split.upcoming)
                      _card(entry, summaries, currency),
                    if (split.past.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Text(
                          'Fechas pasadas',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      for (final entry in split.past)
                        _card(entry, summaries, currency),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, int count, QuoteStatus? status) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text('$label · $count'),
      selected: _filter == status,
      onSelected: (_) => setState(() => _filter = status),
    ),
  );

  Widget _card(
    _QuoteEntry entry,
    Map<String, QuoteSummary> summaries,
    String currency,
  ) {
    final summary =
        summaries[entry.quote.id] ?? (totalCents: 0, childrenCount: 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: QuoteCard(
        quote: entry.quote,
        propertyName: entry.propertyName,
        roomName: entry.roomName,
        summary: summary,
        currency: currency,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuoteDetailPage(quoteId: entry.quote.id),
          ),
        ),
      ),
    );
  }

  bool _matches(_QuoteEntry entry, String query) {
    final q = query.toLowerCase();
    return (entry.quote.guestName?.toLowerCase().contains(q) ?? false) ||
        (entry.quote.guestContact?.toLowerCase().contains(q) ?? false) ||
        entry.roomName.toLowerCase().contains(q) ||
        entry.propertyName.toLowerCase().contains(q);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.request_quote_outlined,
                size: 36,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Todavía no tienes cotizaciones',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando alguien pregunte por una habitación, arma la '
              'cotización aquí y compártela por WhatsApp.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear cotización'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.query,
    required this.filter,
    required this.onShowAll,
  });

  final String query;
  final QuoteStatus? filter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = query.isNotEmpty
        ? 'Sin resultados para "$query"'
        : 'No hay cotizaciones ${_filterLabel(filter)}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (filter != null || query.isNotEmpty)
              TextButton(onPressed: onShowAll, child: const Text('Ver todas')),
          ],
        ),
      ),
    );
  }

  String _filterLabel(QuoteStatus? status) => switch (status) {
    QuoteStatus.pending => 'pendientes',
    QuoteStatus.reserved => 'reservadas',
    QuoteStatus.rejected => 'rechazadas',
    null => '',
  };
}
