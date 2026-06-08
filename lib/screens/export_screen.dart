import 'package:flutter/material.dart';

import '../models/baby_profile.dart';
import '../models/conversation.dart';
import '../theme/card_themes.dart' as themes;
import '../utils/image_exporter.dart';
import '../widgets/export_card.dart';

class ExportScreen extends StatefulWidget {
  final Conversation conv;
  final BabyProfile? profile;

  const ExportScreen({super.key, required this.conv, this.profile});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _boundaryKey = GlobalKey();
  int _themeIndex = 0;
  bool _sharing = false;
  bool _showDate = true;
  bool _showBackground = true;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await exportAndShare(_boundaryKey);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = themes.kCardThemes[_themeIndex];

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        title: const Text('导出分享'),
        actions: [
          if (_sharing)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: '分享',
              onPressed: _share,
            ),
        ],
      ),
      body: Column(
        children: [
          // Card preview
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ExportCard(
                  boundaryKey: _boundaryKey,
                  conv: widget.conv,
                  profile: widget.profile,
                  theme: theme,
                  showDate: _showDate,
                  showBackground: _showBackground,
                ),
              ),
            ),
          ),

          // Options row
          _OptionsBar(
            showDate: _showDate,
            showBackground: _showBackground,
            hasBackground: widget.conv.background != null &&
                widget.conv.background!.isNotEmpty,
            onToggleDate: () => setState(() => _showDate = !_showDate),
            onToggleBackground: () =>
                setState(() => _showBackground = !_showBackground),
          ),

          // Theme picker
          _ThemePicker(
            selectedIndex: _themeIndex,
            onSelect: (i) => setState(() => _themeIndex = i),
          ),

          // Share button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('保存 / 分享'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsBar extends StatelessWidget {
  final bool showDate;
  final bool showBackground;
  final bool hasBackground;
  final VoidCallback onToggleDate;
  final VoidCallback onToggleBackground;

  const _OptionsBar({
    required this.showDate,
    required this.showBackground,
    required this.hasBackground,
    required this.onToggleDate,
    required this.onToggleBackground,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '显示内容：',
            style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: '日期',
            active: showDate,
            onTap: onToggleDate,
          ),
          const SizedBox(width: 8),
          if (hasBackground)
            _ToggleChip(
              label: '场景',
              active: showBackground,
              onTap: onToggleBackground,
            ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(color: cs.primary, width: 1.2)
              : Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 14,
              color: active ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ThemePicker({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
        ),
      ),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: themes.kCardThemes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (ctx, i) {
            final t = themes.kCardThemes[i];
            final selected = i == selectedIndex;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: t.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: cs.primary, width: 2.5)
                          : Border.all(
                              color: Colors.transparent, width: 2.5),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: t.gradient.last.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selected
                          ? cs.primary
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
