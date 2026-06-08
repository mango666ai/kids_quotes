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
          // Card preview (scrollable in case it's tall)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: Center(
                child: ExportCard(
                  boundaryKey: _boundaryKey,
                  conv: widget.conv,
                  profile: widget.profile,
                  theme: theme,
                ),
              ),
            ),
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

class _ThemePicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ThemePicker({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withOpacity(0.4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(themes.kCardThemes.length, (i) {
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
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.5,
                          )
                        : Border.all(color: Colors.transparent, width: 2.5),
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
                const SizedBox(height: 6),
                Text(
                  t.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
