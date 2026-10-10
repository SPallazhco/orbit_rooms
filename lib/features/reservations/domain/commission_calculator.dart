/// Comisión que se cobra a una casa administrada (no propia) por cada
/// huésped enviado (PRD 9, ver docs/DECISIONS.md) — tabla fija, negociada
/// con la administradora, sin fórmula proporcional: cada tramo de tarifa
/// por persona tiene su propia comisión por persona, y en dos tramos
/// ($12 y $15) esa comisión depende de si hay más de un huésped.
int commissionPerPersonCents(int effectiveRatePerPersonCents, int guestsCount) {
  if (effectiveRatePerPersonCents < 1200) return 250;
  if (effectiveRatePerPersonCents < 1300) return guestsCount > 1 ? 300 : 250;
  if (effectiveRatePerPersonCents < 1500) return 300;
  if (effectiveRatePerPersonCents < 1800) return guestsCount > 1 ? 350 : 300;
  if (effectiveRatePerPersonCents < 2000) return 400;
  return 500;
}

/// El garaje es gratis en la casa propia, pero en una casa administrada se
/// resta del ingreso de esa noche antes de calcular la comisión (a
/// conveniencia de la administradora, sin fórmula fija — ver
/// docs/DECISIONS.md). `garageFeeCents` ya viene en 0 cuando no hay auto.
int commissionCentsForNight({
  required int ratePerPersonCents,
  required int guestsCount,
  required int garageFeeCents,
}) {
  final netCents = ratePerPersonCents * guestsCount - garageFeeCents;
  final clampedNetCents = netCents < 0 ? 0 : netCents;
  final effectiveRatePerPersonCents = clampedNetCents ~/ guestsCount;
  return commissionPerPersonCents(effectiveRatePerPersonCents, guestsCount) *
      guestsCount;
}
