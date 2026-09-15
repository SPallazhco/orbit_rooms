import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/calendar/calendar_providers.dart';
import 'package:orbit_rooms/features/properties/properties_providers.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

const _weekdayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

const _monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

DateTime _mondayOf(DateTime date) {
  final dateOnly = DateTime(date.year, date.month, date.day);
  return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
}

RoomStay? _stayOn(RoomOccupancy occupancy, DateTime day) {
  for (final stay in occupancy.stays) {
    if (!day.isBefore(stay.checkInDate) && day.isBefore(stay.checkOutDate)) {
      return stay;
    }
  }
  return null;
}

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  String? _propertyId;
  DateTime _weekStart = _mondayOf(DateTime.now());
  DateTime _monthCursor = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(activePropertiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      drawer: const AppDrawer(),
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (properties) {
          if (properties.isEmpty) {
            return const Center(child: Text('Todavía no tienes propiedades'));
          }

          final propertyId =
              (_propertyId != null &&
                  properties.any((p) => p.id == _propertyId))
              ? _propertyId!
              : properties.first.id;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: DropdownButtonFormField<String>(
                  initialValue: propertyId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Propiedad'),
                  items: properties
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _propertyId = value),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WeekHeader(
                        weekStart: _weekStart,
                        onPrevious: () => setState(
                          () => _weekStart = _weekStart.subtract(
                            const Duration(days: 7),
                          ),
                        ),
                        onNext: () => setState(
                          () => _weekStart = _weekStart.add(
                            const Duration(days: 7),
                          ),
                        ),
                      ),
                      _OccupancyGrid(
                        propertyId: propertyId,
                        weekStart: _weekStart,
                      ),
                      const Divider(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Vista mensual'),
                      ),
                      _MonthHeader(
                        month: _monthCursor,
                        onPrevious: () => setState(
                          () => _monthCursor = DateTime(
                            _monthCursor.year,
                            _monthCursor.month - 1,
                          ),
                        ),
                        onNext: () => setState(
                          () => _monthCursor = DateTime(
                            _monthCursor.year,
                            _monthCursor.month + 1,
                          ),
                        ),
                      ),
                      _MonthCalendar(
                        propertyId: propertyId,
                        month: _monthCursor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.weekStart,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    String format(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            '${format(weekStart)} - ${format(weekEnd)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

class _OccupancyGrid extends ConsumerWidget {
  const _OccupancyGrid({required this.propertyId, required this.weekStart});

  final String propertyId;
  final DateTime weekStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyAsync = ref.watch(roomOccupancyProvider(propertyId));

    return occupancyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (rooms) {
        if (rooms.isEmpty) {
          return const Center(
            child: Text('Esta propiedad todavía no tiene habitaciones'),
          );
        }

        final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 96),
                  for (final day in days)
                    Expanded(
                      child: Center(
                        child: Text(
                          '${_weekdayLabels[day.weekday - 1]}\n${day.day}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              for (final occupancy in rooms)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(
                          occupancy.room.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      for (final day in days)
                        Expanded(
                          child: _DayCell(stay: _stayOn(occupancy, day)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            '${_monthNames[month.month - 1]} ${month.year}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

/// Vista de mes completo, debajo de la semana (PRD 5.6): mismos datos de
/// `roomOccupancyProvider`, solo que acá un día se pinta si *alguna*
/// habitación está ocupada, y tocarlo muestra cuáles.
class _MonthCalendar extends ConsumerWidget {
  const _MonthCalendar({required this.propertyId, required this.month});

  final String propertyId;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyAsync = ref.watch(roomOccupancyProvider(propertyId));

    return occupancyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (rooms) {
        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
        final leadingBlanks = DateTime(month.year, month.month, 1).weekday - 1;

        List<RoomOccupancy> occupiedRoomsOn(DateTime day) =>
            rooms.where((o) => _stayOn(o, day) != null).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final label in _weekdayLabels)
                    Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leadingBlanks + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemBuilder: (context, index) {
                  if (index < leadingBlanks) {
                    return const SizedBox.shrink();
                  }

                  final day = DateTime(
                    month.year,
                    month.month,
                    index - leadingBlanks + 1,
                  );
                  final occupiedRooms = occupiedRoomsOn(day);

                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: GestureDetector(
                      onTap: () =>
                          _showOccupiedRooms(context, day, occupiedRooms),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: occupiedRooms.isEmpty
                              ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest
                              : Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${day.day}'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOccupiedRooms(
    BuildContext context,
    DateTime day,
    List<RoomOccupancy> occupiedRooms,
  ) {
    final dayLabel =
        '${day.day.toString().padLeft(2, '0')}/'
        '${day.month.toString().padLeft(2, '0')}/${day.year}';

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(dayLabel),
        content: occupiedRooms.isEmpty
            ? const Text('Ninguna habitación ocupada este día')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final occupancy in occupiedRooms)
                    Text(occupancy.room.name),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.stay});

  final RoomStay? stay;

  @override
  Widget build(BuildContext context) {
    final stay = this.stay;
    final color = stay == null
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.primaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: stay == null
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ReservationDetailPage(reservationId: stay.reservationId),
                ),
              ),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
