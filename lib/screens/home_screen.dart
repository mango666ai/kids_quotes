import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/baby_profile.dart';
import '../models/conversation.dart';
import '../widgets/conversation_card.dart';
import '../widgets/home_entry_card.dart';
import '../widgets/month_filter_sheet.dart';
import 'conversation_edit_screen.dart';
import 'export_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;

  BabyProfile? _profile;
  List<Conversation> _conversations = [];
  ({int year, int month})? _filterMonth;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _db.getBabyProfile();
    final convs = await _db.getConversations(
      year: _filterMonth?.year,
      month: _filterMonth?.month,
    );
    if (mounted) {
      setState(() {
        _profile = profile;
        _conversations = convs;
        _loading = false;
      });
    }
  }

  Future<void> _openEntry() async {
    if (_profile == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      await _load();
      return;
    }
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationEditScreen(profile: _profile!),
      ),
    );
    if (created == true) await _load();
  }

  Future<void> _openExport(Conversation conv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExportScreen(conv: conv, profile: _profile),
      ),
    );
  }

  Future<void> _showLongPressMenu(Conversation conv) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (action == 'edit' && mounted) {
      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ConversationEditScreen(
            profile: _profile!,
            editing: conv,
          ),
        ),
      );
      if (updated == true) await _load();
    } else if (action == 'delete' && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('确认删除'),
          content: const Text('删除后无法恢复，确定吗？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _db.deleteConversation(conv.id!);
        await _load();
      }
    }
  }

  Future<void> _openMonthFilter() async {
    final months = await _db.getAvailableMonths();
    if (!mounted) return;
    final selected = await showMonthFilterSheet(context, months: months);
    if (selected != null) {
      setState(() => _filterMonth = selected);
      await _load();
    }
  }

  void _clearFilter() {
    setState(() => _filterMonth = null);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        title: const Text(
          '童言童语',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: '按月筛选',
            onPressed: _openMonthFilter,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: HomeEntryCard(
                        profile: _profile,
                        onTap: _openEntry,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Text(
                            '过往记忆',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_filterMonth != null)
                            InputChip(
                              label: Text(
                                  '${_filterMonth!.year}年${_filterMonth!.month}月'),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: _clearFilter,
                            ),
                          const Spacer(),
                          Text(
                            '共 ${_conversations.length} 条',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_conversations.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💬', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              _filterMonth != null ? '这个月还没有记录' : '还没有记录，快去记第一句吧～',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ConversationCard(
                              conv: _conversations[i],
                              profile: _profile,
                              onTap: () => _openExport(_conversations[i]),
                              onLongPress: () =>
                                  _showLongPressMenu(_conversations[i]),
                            ),
                          ),
                          childCount: _conversations.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
