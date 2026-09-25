import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/database/app_database.dart';

String quoteStatusLabel(QuoteStatus status) => switch (status) {
  QuoteStatus.pending => 'Pendiente',
  QuoteStatus.reserved => 'Reservada',
  QuoteStatus.rejected => 'Rechazada',
};

Color quoteStatusColor(BuildContext context, QuoteStatus status) =>
    switch (status) {
      QuoteStatus.pending => Theme.of(context).colorScheme.tertiary,
      QuoteStatus.reserved => Theme.of(context).colorScheme.primary,
      QuoteStatus.rejected => Theme.of(context).colorScheme.error,
    };
