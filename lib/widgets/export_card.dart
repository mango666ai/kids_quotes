import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/baby_profile.dart';
import '../models/conversation.dart';
import '../theme/card_themes.dart';

class ExportCard extends StatelessWidget {
  final GlobalKey boundaryKey;
  final Conversation conv;
  final BabyProfile? profile;
  final ExportCardTheme theme;
  final bool showDate;
  final bool showBackground;

  const ExportCard({
    super.key,
    required this.boundaryKey,
    required this.conv,
    required this.profile,
    required this.theme,
    this.showDate = true,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    // The RepaintBoundary is wrapped in a white container so that when
    // exported to PNG the rounded corners of the card sit on a clean
    // white background — no transparent corner pixels that viewers
    // render as white patches.
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.gradient.last.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: _CardContent(
            conv: conv,
            profile: profile,
            theme: theme,
            showDate: showDate,
            showBackground: showBackground,
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Conversation conv;
  final BabyProfile? profile;
  final ExportCardTheme theme;
  final bool showDate;
  final bool showBackground;

  const _CardContent({
    required this.conv,
    required this.profile,
    required this.theme,
    required this.showDate,
    required this.showBackground,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('yyyy.MM.dd').format(conv.occurredAt);

    final totalChars =
        conv.turns.fold<int>(0, (s, t) => s + t.content.length);
    final fontSize = totalChars > 200
        ? 13.0
        : totalChars > 120
            ? 15.0
            : 17.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Center(
          child: Text(
            theme.header,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        if (profile != null) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${profile!.emoji} ${profile!.name}・${conv.babyAgeSnapshot}',
              style: TextStyle(color: theme.subtleColor, fontSize: 12),
            ),
          ),
        ],
        if (showBackground &&
            conv.background != null &&
            conv.background!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              '📍 ${conv.background}',
              style: TextStyle(
                color: theme.subtleColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Divider(
            color: theme.subtleColor.withOpacity(0.3), thickness: 0.8),
        const SizedBox(height: 16),
        // Dialogue
        ...conv.turns.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${t.emoji} ${t.role}',
                        style: TextStyle(
                          color: theme.subtleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (t.isInnerThought) ...[
                        const SizedBox(width: 4),
                        Text(
                          '· 心里想',
                          style: TextStyle(
                              color: theme.subtleColor.withOpacity(0.7),
                              fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      t.isInnerThought ? '（${t.content}）' : t.content,
                      style: TextStyle(
                        color: theme.textColor.withOpacity(
                            t.isInnerThought ? 0.75 : 1.0),
                        fontSize: fontSize,
                        height: 1.5,
                        fontStyle: t.isInnerThought
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
        Divider(
            color: theme.subtleColor.withOpacity(0.3), thickness: 0.8),
        if (showDate) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              dateText,
              style: TextStyle(color: theme.subtleColor, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
