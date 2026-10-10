import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orbit_rooms/features/reports/presentation/widgets/garage_report_card.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mismo patrón que `QuoteSharePreviewPage`: la tarjeta se renderiza en
/// pantalla (no oculta) porque `RepaintBoundary.toImage()` necesita que la
/// subrama ya haya pasado por paint.
class GarageReportPreviewPage extends StatefulWidget {
  const GarageReportPreviewPage({
    super.key,
    required this.day,
    required this.entries,
  });

  final DateTime day;
  final List<GarageEntry> entries;

  @override
  State<GarageReportPreviewPage> createState() =>
      _GarageReportPreviewPageState();
}

class _GarageReportPreviewPageState extends State<GarageReportPreviewPage> {
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
      final file = File('${tempDir.path}/garaje.png');
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
      appBar: AppBar(title: const Text('Reporte de garaje')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(
          key: _boundaryKey,
          child: GarageReportCard(day: widget.day, entries: widget.entries),
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
