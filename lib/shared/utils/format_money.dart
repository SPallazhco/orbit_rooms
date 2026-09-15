/// Formatea centavos como monto legible con el código de moneda (PRD 5.9).
/// Sin símbolos por moneda ni conversión — la app maneja una sola moneda
/// global, tal cual la configuró la administradora.
String formatCents(int cents, String currency) =>
    '${(cents / 100).toStringAsFixed(2)} $currency';
