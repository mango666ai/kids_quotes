import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportAndShare(GlobalKey boundaryKey) async {
  final boundary = boundaryKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;
  final bytes = byteData.buffer.asUint8List();
  final tempDir = await getTemporaryDirectory();
  final filePath = p.join(
    tempDir.path,
    'quote_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  final file = await File(filePath).writeAsBytes(bytes);
  await Share.shareXFiles([XFile(file.path)], text: '童言童语');
}
