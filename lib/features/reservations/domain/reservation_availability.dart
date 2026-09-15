/// Dos estadías con rango `[checkIn, checkOut)` se solapan si una empieza
/// antes de que la otra termine, en ambos sentidos. El rango es
/// medio-abierto: el día de checkout de una puede coincidir con el check-in
/// de la otra sin que cuente como solapamiento — así se permite la rotación
/// el mismo día (PRD 5.10). Función pura: no toca la base de datos.
bool dateRangesOverlap({
  required DateTime aCheckIn,
  required DateTime aCheckOut,
  required DateTime bCheckIn,
  required DateTime bCheckOut,
}) {
  return aCheckIn.isBefore(bCheckOut) && aCheckOut.isAfter(bCheckIn);
}
