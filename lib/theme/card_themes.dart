import 'package:flutter/material.dart' show Color;

class ExportCardTheme {
  final String name;
  final List<Color> gradient;
  final Color textColor;
  final Color subtleColor;
  final String header;

  const ExportCardTheme({
    required this.name,
    required this.gradient,
    required this.textColor,
    required this.subtleColor,
    required this.header,
  });
}

const List<ExportCardTheme> kCardThemes = [
  ExportCardTheme(
    name: '暖橙',
    gradient: [Color(0xFFFFE5B4), Color(0xFFFFB088)],
    textColor: Color(0xFF5C3A1E),
    subtleColor: Color(0xFF8C6F4F),
    header: '✨ 童言童语 ✨',
  ),
  ExportCardTheme(
    name: '天蓝',
    gradient: [Color(0xFFD4F1F4), Color(0xFFA8DCE7)],
    textColor: Color(0xFF1B4965),
    subtleColor: Color(0xFF4F7A92),
    header: '☁️ 小云朵小语 ☁️',
  ),
  ExportCardTheme(
    name: '薄荷',
    gradient: [Color(0xFFE8F5E9), Color(0xFFB2DFDB)],
    textColor: Color(0xFF1B5E20),
    subtleColor: Color(0xFF5C8C5F),
    header: '🌿 童言絮语 🌿',
  ),
  ExportCardTheme(
    name: '奶紫',
    gradient: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
    textColor: Color(0xFF4A148C),
    subtleColor: Color(0xFF7A5C9B),
    header: '⭐ 小星星语录 ⭐',
  ),
];
