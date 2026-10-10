import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orbit_rooms/features/reports/presentation/widgets/commission_report_card.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mismo patrón que `QuoteSharePreviewPage`/`GarageReportPreviewPage`: la
/// tarjeta se renderiza en pantalla (no oculta) porque
/// `RepaintBoundary.toImage()` necesita que la subrama ya haya pasado por
/// paint.
class CommissionReportPreviewPage extends StatefulWidget {
  const CommissionReportPreviewPage({
    super.key,
    required this.propertyName,
    required this.start,
    required this.end,
    required this.entries,
    required this.currency,
  });

  final String propertyName;
  final DateTime start;
  final DateTime end;
  final List<CommissionEntry> entries;
  final String currency;

  @override
  State<CommissionReportPreviewPage> createState() =>
      _CommissionReportPreviewPageState();
}

class _CommissionReportPreviewPageState
    extends State<CommissionReportPreviewPage> {
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
      final file = File('${tempDir.path}/comision.png');
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
      appBar: AppBar(title: const Text('Reporte de comisión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(
          key: _boundaryKey,
          child: CommissionReportCard(
            propertyName: widget.propertyName,
            start: widget.start,
            end: widget.end,
            entries: widget.entries,
            currency: widget.currency,
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
