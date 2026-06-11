import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Export one or more RepaintBoundary keys as PNG images and share them.
Future<void> exportAndShare(List<GlobalKey> boundaryKeys) async {
  // Collect all RenderRepaintBoundary references BEFORE any async gap
  // to avoid using BuildContext across await.
  final boundaries = boundaryKeys
      .map((k) =>
          k.currentContext?.findRenderObject() as RenderRepaintBoundary?)
      .whereType<RenderRepaintBoundary>()
      .toList();

  if (boundaries.isEmpty) return;

  final tempDir = await getTemporaryDirectory();
  final files = <XFile>[];

  for (int i = 0; i < boundaries.length; i++) {
    final image = await boundaries[i].toImage(pixelRatio: 3.0);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) continue;
    final bytes = byteData.buffer.asUint8List();
    final filePath = p.join(
      tempDir.path,
      'quote_p${i + 1}of${boundaries.length}_'
      '${DateTime.now().millisecondsSinceEpoch}.png',
    );
    final file = await File(filePath).writeAsBytes(bytes);
    files.add(XFile(file.path));
  }

  if (files.isNotEmpty) {
    await Share.shareXFiles(files, text: '童言童语');
  }
}
