import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_availability.dart';

void main() {
  group('dateRangesOverlap', () {
    test('dos rangos que no se tocan no se solapan', () {
      final overlap = dateRangesOverlap(
        aCheckIn: DateTime(2026, 6, 1),
        aCheckOut: DateTime(2026, 6, 3),
        bCheckIn: DateTime(2026, 6, 10),
        bCheckOut: DateTime(2026, 6, 12),
      );

      expect(overlap, isFalse);
    });

    test('un rango completamente dentro de otro sí se solapa', () {
      final overlap = dateRangesOverlap(
        aCheckIn: DateTime(2026, 6, 1),
        aCheckOut: DateTime(2026, 6, 10),
        bCheckIn: DateTime(2026, 6, 4),
        bCheckOut: DateTime(2026, 6, 6),
      );

      expect(overlap, isTrue);
    });

    test('el checkout de uno igual al check-in del otro NO cuenta como '
        'solapamiento (rotación el mismo día, PRD 5.10)', () {
      final overlap = dateRangesOverlap(
        aCheckIn: DateTime(2026, 6, 1),
        aCheckOut: DateTime(2026, 6, 5),
        bCheckIn: DateTime(2026, 6, 5),
        bCheckOut: DateTime(2026, 6, 8),
      );

      expect(overlap, isFalse);
    });

    test('el orden de los rangos no cambia el resultado', () {
      final overlapAB = dateRangesOverlap(
        aCheckIn: DateTime(2026, 6, 3),
        aCheckOut: DateTime(2026, 6, 8),
        bCheckIn: DateTime(2026, 6, 1),
        bCheckOut: DateTime(2026, 6, 5),
      );
      final overlapBA = dateRangesOverlap(
        aCheckIn: DateTime(2026, 6, 1),
        aCheckOut: DateTime(2026, 6, 5),
        bCheckIn: DateTime(2026, 6, 3),
        bCheckOut: DateTime(2026, 6, 8),
      );

      expect(overlapAB, isTrue);
      expect(overlapBA, isTrue);
    });
  });
}
