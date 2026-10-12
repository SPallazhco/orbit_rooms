import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/reminders_bell.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_timeline.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/create_reservation_page.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:orbit_rooms/features/reservations/presentation/widgets/reservation_card.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

enum _Filter { active, past, cancelled, all }

class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage> {
  /// Arranca en "Activas" (en casa + próximas): es lo que hay que atender.
  _Filter _filter = _Filter.active;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreate() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const CreateReservationPage()));

  void _showAll() {
    _searchController.clear();
    setState(() {
      _filter = _Filter.all;
      _query = '';
    });
  }

  bool _inFilter(ReservationListItem item, _Filter filter) => switch (filter) {
    _Filter.active =>
      item.phase == ReservationPhase.inHouse ||
          item.phase == ReservationPhase.upcoming,
    _Filter.past => item.phase == ReservationPhase.past,
    _Filter.cancelled => item.phase == ReservationPhase.cancelled,
    _Filter.all => true,
  };

  bool _matches(ReservationListItem item, String query) {
    final q = query.toLowerCase();
    return item.guestName.toLowerCase().contains(q) ||
        item.roomNames.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(reservationListProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';
    final hasAny = listAsync.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        actions: const [RemindersBell()],
      ),
      drawer: const AppDrawer(),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) {
          if (items.isEmpty) return _EmptyState(onCreate: _openCreate);
          return _buildList(items, currency);
        },
      ),
      floatingActionButton: hasAny
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text('Nueva reserva'),
            )
          : null,
    );
  }

  Widget _buildList(List<ReservationListItem> items, String currency) {
    final scheme = Theme.of(context).colorScheme;
    int countOf(_Filter f) => items.where((i) => _inFilter(i, f)).length;

    final visible = items
        .where((i) => _inFilter(i, _filter))
        .where((i) => _query.isEmpty || _matches(i, _query))
        .toList();

    int byDate(
      ReservationListItem a,
      ReservationListItem b,
      DateTime Function(ReservationListItem) key,
    ) => key(a).compareTo(key(b));

    final inHouse =
        visible.where((i) => i.phase == ReservationPhase.inHouse).toList()
          ..sort((a, b) => byDate(a, b, (i) => i.reservation.checkOutDate));
    final upcoming =
        visible.where((i) => i.phase == ReservationPhase.upcoming).toList()
          ..sort((a, b) => byDate(a, b, (i) => i.reservation.checkInDate));
    final past = visible.where((i) => i.phase == ReservationPhase.past).toList()
      ..sort((a, b) => byDate(b, a, (i) => i.reservation.checkInDate));
    final cancelled =
        visible.where((i) => i.phase == ReservationPhase.cancelled).toList()
          ..sort((a, b) => byDate(b, a, (i) => i.reservation.checkInDate));

    final sections = <(String, List<ReservationListItem>)>[
      ('En casa', inHouse),
      ('Próximas', upcoming),
      ('Pasadas', past),
      ('Canceladas', cancelled),
    ].where((s) => s.$2.isNotEmpty).toList();
    // Con un solo tipo de reservas el encabezado no aporta: el filtro ya lo
    // dice.
    final showHeaders = sections.length > 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por huésped o habitación',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              _chip('Activas', _Filter.active, countOf(_Filter.active)),
              _chip('Pasadas', _Filter.past, countOf(_Filter.past)),
              _chip(
                'Canceladas',
                _Filter.cancelled,
                countOf(_Filter.cancelled),
              ),
              _chip('Todas', _Filter.all, items.length),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? _NoResults(
                  query: _query,
                  filter: _filter,
                  onShowAll: _showAll,
                  onCreate: _openCreate,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  children: [
                    for (final section in sections) ...[
                      if (showHeaders)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          child: Text(
                            '${section.$1} · ${section.$2.length}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      for (final item in section.$2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ReservationCard(
                            item: item,
                            currency: currency,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReservationDetailPage(
                                  reservationId: item.reservation.id,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, _Filter filter, int count) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text('$label · $count'),
      selected: _filter == filter,
      onSelected: (_) => setState(() => _filter = filter),
    ),
  );
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
                Icons.event_available_outlined,
                size: 36,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Todavía no tienes reservas',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea la primera para ver aquí quién llega, quién está en casa '
              'y cuánto falta por cobrar.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear reserva'),
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
    required this.onCreate,
  });

  final String query;
  final _Filter filter;
  final VoidCallback onShowAll;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = query.isNotEmpty
        ? 'Sin resultados para "$query"'
        : switch (filter) {
            _Filter.active => 'No tienes reservas activas ni próximas',
            _Filter.past => 'No hay reservas pasadas',
            _Filter.cancelled => 'No hay reservas canceladas',
            _Filter.all => 'No hay reservas',
          };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            if (filter != _Filter.all || query.isNotEmpty)
              TextButton(onPressed: onShowAll, child: const Text('Ver todas')),
            if (filter == _Filter.active && query.isEmpty)
              FilledButton.tonalIcon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Nueva reserva'),
              ),
          ],
        ),
      ),
    );
  }
}
