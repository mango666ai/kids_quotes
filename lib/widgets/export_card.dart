import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/baby_profile.dart';
import '../models/conversation.dart';
import '../theme/card_themes.dart';

// ---------------------------------------------------------------------------
// Pagination helper — call this to split conv.turns into per-page groups.
// Rules: max 8 turns per page AND max 350 total chars per page.
// Short conversations (≤ 8 turns, ≤ 350 chars) stay on a single page.
// ---------------------------------------------------------------------------
List<List<DialogueTurn>> paginateTurns(List<DialogueTurn> turns) {
  const maxTurns = 8;
  const maxChars = 350;

  final total = turns.fold<int>(0, (s, t) => s + t.content.length);
  if (turns.length <= maxTurns && total <= maxChars) return [turns];

  final pages = <List<DialogueTurn>>[];
  var current = <DialogueTurn>[];
  var charCount = 0;

  for (final t in turns) {
    if (current.isNotEmpty &&
        (current.length >= maxTurns ||
            charCount + t.content.length > maxChars)) {
      pages.add(List.from(current));
      current.clear();
      charCount = 0;
    }
    current.add(t);
    charCount += t.content.length;
  }
  if (current.isNotEmpty) pages.add(current);
  return pages;
}

// ---------------------------------------------------------------------------
// ExportCard — fixed 3:4 image (360×480 total incl. white outer padding)
// ---------------------------------------------------------------------------
class ExportCard extends StatelessWidget {
  final GlobalKey boundaryKey;
  final Conversation conv;
  final List<DialogueTurn> pageTurns; // turns for THIS page only
  final int pageIndex;                // 0-based
  final int totalPages;
  final BabyProfile? profile;
  final ExportCardTheme theme;
  final bool showDate;
  final bool showBackground;

  const ExportCard({
    super.key,
    required this.boundaryKey,
    required this.conv,
    required this.pageTurns,
    required this.pageIndex,
    required this.totalPages,
    required this.profile,
    required this.theme,
    this.showDate = true,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    // Outer white container = 360×480 → 3:4 exported image
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: 360,
        height: 480,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.gradient.last.withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 20),
              child: _CardContent(
                conv: conv,
                pageTurns: pageTurns,
                pageIndex: pageIndex,
                totalPages: totalPages,
                profile: profile,
                theme: theme,
                showDate: showDate,
                showBackground: showBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Adaptive font size based on turns on this page
// ---------------------------------------------------------------------------
double _fontSize(List<DialogueTurn> turns) {
  final n = turns.length;
  final chars = turns.fold<int>(0, (s, t) => s + t.content.length);
  if (n <= 3 && chars <= 80) return 15.0;
  if (n <= 5 && chars <= 180) return 13.0;
  return 12.0;
}

class _CardContent extends StatelessWidget {
  final Conversation conv;
  final List<DialogueTurn> pageTurns;
  final int pageIndex;
  final int totalPages;
  final BabyProfile? profile;
  final ExportCardTheme theme;
  final bool showDate;
  final bool showBackground;

  const _CardContent({
    required this.conv,
    required this.pageTurns,
    required this.pageIndex,
    required this.totalPages,
    required this.profile,
    required this.theme,
    required this.showDate,
    required this.showBackground,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('yyyy.MM.dd').format(conv.occurredAt);
    final fs = _fontSize(pageTurns);
    final isFirstPage = pageIndex == 0;
    final isLastPage = pageIndex == totalPages - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Center(
          child: Text(
            theme.header,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (profile != null) ...[
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${profile!.emoji} ${profile!.name}・${conv.babyAgeSnapshot}',
              style: TextStyle(color: theme.subtleColor, fontSize: 11),
            ),
          ),
        ],
        if (isFirstPage &&
            showBackground &&
            conv.background != null &&
            conv.background!.isNotEmpty) ...[
          const SizedBox(height: 3),
          Center(
            child: Text(
              '📍 ${conv.background}',
              style: TextStyle(
                color: theme.subtleColor,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        // Page indicator (only when multi-page)
        if (totalPages > 1) ...[
          const SizedBox(height: 3),
          Center(
            child: Text(
              '${'─' * 4}  ${pageIndex + 1} / $totalPages  ${'─' * 4}',
              style: TextStyle(
                color: theme.subtleColor.withOpacity(0.6),
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Divider(
            color: theme.subtleColor.withOpacity(0.3), thickness: 0.7),
        const SizedBox(height: 10),

        // ── Dialogue ────────────────────────────────────────────────────
        ...pageTurns.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${t.emoji} ${t.role}',
                        style: TextStyle(
                          color: theme.subtleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (t.isInnerThought) ...[
                        const SizedBox(width: 3),
                        Text(
                          '· 心里想',
                          style: TextStyle(
                              color: theme.subtleColor.withOpacity(0.65),
                              fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      t.isInnerThought
                          ? '（${t.content}）'
                          : t.content,
                      style: TextStyle(
                        color: theme.textColor
                            .withOpacity(t.isInnerThought ? 0.72 : 1.0),
                        fontSize: fs,
                        height: 1.45,
                        fontStyle: t.isInnerThought
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            )),

        // ── Footer ──────────────────────────────────────────────────────
        const Spacer(),
        Divider(
            color: theme.subtleColor.withOpacity(0.3), thickness: 0.7),
        if (isLastPage && showDate) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              dateText,
              style: TextStyle(color: theme.subtleColor, fontSize: 11),
            ),
          ),
        ],
      ],
    );
  }
}
