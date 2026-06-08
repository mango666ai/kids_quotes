import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/baby_profile.dart';
import '../models/role.dart';
import '../utils/age_calculator.dart';
import '../widgets/new_role_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = DatabaseHelper.instance;
  final _nameCtrl = TextEditingController();
  DateTime? _birthday;
  String _emoji = '👶🏻';
  List<Role> _roles = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _db.getBabyProfile();
    final roles = await _db.getAllRoles();
    if (mounted) {
      setState(() {
        if (profile != null) {
          _nameCtrl.text = profile.name;
          _birthday = profile.birthday;
          _emoji = profile.emoji;
        }
        _roles = roles;
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _birthday == null) return;
    await _db.saveBabyProfile(BabyProfile(
      name: name,
      birthday: _birthday!,
      emoji: _emoji,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
    }
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2022),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthday = picked);
      _autoSave();
    }
  }

  void _autoSave() {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty && _birthday != null) {
      _db.saveBabyProfile(BabyProfile(
        name: name,
        birthday: _birthday!,
        emoji: _emoji,
      ));
    }
  }

  Future<void> _pickEmoji() async {
    const emojis = [
      '👶🏻', '👧🏻', '👦🏻', '🧒🏻', '👩🏻', '👨🏻', '👵🏻', '👴🏻', '🐻', '🐼', '🦁', '🌟'
    ];
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择头像'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: emojis
              .map((e) => GestureDetector(
                    onTap: () => Navigator.pop(ctx, e),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: e == _emoji
                            ? Border.all(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child:
                          Text(e, style: const TextStyle(fontSize: 28)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null) {
      setState(() => _emoji = picked);
      _autoSave();
    }
  }

  Future<void> _addRole() async {
    final role = await showNewRoleDialog(context);
    if (role == null) return;
    await _db.upsertRole(role);
    final roles = await _db.getAllRoles();
    setState(() => _roles = roles);
  }

  Future<void> _deleteRole(Role role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除角色'),
        content: Text('删除「${role.emoji} ${role.name}」？历史记录中的姓名不受影响。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true && role.id != null) {
      await _db.deleteRole(role.id!);
      final roles = await _db.getAllRoles();
      setState(() => _roles = roles);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ageText = (_birthday != null)
        ? calcAge(_birthday!, DateTime.now())
        : null;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        title: const Text('设置'),
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: _loaded
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Baby profile card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '宝宝档案',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Emoji picker
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickEmoji,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(_emoji,
                                  style: const TextStyle(fontSize: 36)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: '宝宝姓名',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (_) => _autoSave(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Birthday
                      InkWell(
                        onTap: _pickBirthday,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: cs.outline.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cake_outlined,
                                  size: 18, color: cs.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                _birthday != null
                                    ? '生日：${DateFormat('yyyy年M月d日').format(_birthday!)}'
                                    : '点击选择宝宝生日',
                                style: TextStyle(
                                  color: _birthday != null
                                      ? cs.onSurface
                                      : cs.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14, color: cs.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                      if (ageText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '当前年龄：$ageText',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Roles section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '对话角色',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _addRole,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('新增'),
                            style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_roles.isEmpty)
                        Text(
                          '还没有角色，去记录页新增吧',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 13),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _roles
                              .map((r) => GestureDetector(
                                    onLongPress: () => _deleteRole(r),
                                    child: Chip(
                                      avatar: Text(r.emoji,
                                          style:
                                              const TextStyle(fontSize: 16)),
                                      label: Text(r.name),
                                      deleteIcon: const Icon(
                                          Icons.close,
                                          size: 14),
                                      onDeleted: () => _deleteRole(r),
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  '提示：长按角色可删除，历史记录中的对话不受影响',
                  style:
                      TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
