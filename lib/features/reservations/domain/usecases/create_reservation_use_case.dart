import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';

/// Acción real "crear una reserva de grupo" (PRD 5.4): esto es lo que la UI
/// va a llamar. El no-solapamiento y el cálculo de precio ya los hace
/// [ReservationRepository] de forma atómica; acá se valida lo que es
/// responsabilidad de la entrada del usuario, no de la persistencia.
class CreateReservationUseCase {
  CreateReservationUseCase(this._reservationRepository);

  final ReservationRepository _reservationRepository;

  Future<String> call({
    required String guestId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required List<RoomAssignmentInput> roomAssignments,
  }) {
    for (final assignment in roomAssignments) {
      if (assignment.guestsCount <= 0) {
        throw ArgumentError(
          'La cantidad de personas en la habitación ${assignment.roomId} '
          'debe ser mayor a 0',
        );
      }
    }

    return _reservationRepository.createGroupReservation(
      guestId: guestId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      roomAssignments: roomAssignments,
    );
  }
}
