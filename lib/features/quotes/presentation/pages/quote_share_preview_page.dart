import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/quote_share_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// La tarjeta se renderiza en pantalla (no oculta): así el
/// `RepaintBoundary` siempre tiene algo pintado para capturar, sin trucos
/// de renderizar fuera de la vista.
class QuoteSharePreviewPage extends StatefulWidget {
  const QuoteSharePreviewPage({
    super.key,
    required this.propertyName,
    required this.roomName,
    required this.guestName,
    required this.dayLines,
    required this.adultsCount,
    required this.childrenCount,
    required this.totalCents,
    required this.depositCents,
    required this.balanceCents,
    required this.currency,
    this.notes,
  });

  final String propertyName;
  final String roomName;
  final String? guestName;
  final List<QuoteDayLine> dayLines;
  final int adultsCount;
  final int childrenCount;
  final int totalCents;
  final int depositCents;
  final int balanceCents;
  final String currency;
  final String? notes;

  @override
  State<QuoteSharePreviewPage> createState() => _QuoteSharePreviewPageState();
}

class _QuoteSharePreviewPageState extends State<QuoteSharePreviewPage> {
  final _boundaryKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary =
          _boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cotizacion.png');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compartir cotización')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(
          key: _boundaryKey,
          child: QuoteShareCard(
            propertyName: widget.propertyName,
            roomName: widget.roomName,
            guestName: widget.guestName,
            dayLines: widget.dayLines,
            adultsCount: widget.adultsCount,
            childrenCount: widget.childrenCount,
            totalCents: widget.totalCents,
            depositCents: widget.depositCents,
            balanceCents: widget.balanceCents,
            currency: widget.currency,
            notes: widget.notes,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sharing ? null : _share,
        icon: _sharing
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.share),
        label: const Text('Compartir'),
      ),
    );
  }
}
