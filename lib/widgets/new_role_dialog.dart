import 'package:flutter/material.dart';

import '../models/role.dart';

// 全部使用单码点 emoji，避免肤色修饰符导致的渲染问题
const List<String> kPresetEmojis = [
  '👶🏻', '👧🏻', '👦🏻', '🧒🏻', '👩🏻', '👨🏻', '👵🏻', '👴🏻',
  '🐶', '🐱', '🦊', '🐼', '🌟', '🌈', '🍀', '🎀',
];

Future<Role?> showNewRoleDialog(BuildContext context, {Role? editing}) {
  return showDialog<Role>(
    context: context,
    builder: (ctx) => _NewRoleDialog(editing: editing),
  );
}

class _NewRoleDialog extends StatefulWidget {
  final Role? editing;
  const _NewRoleDialog({this.editing});

  @override
  State<_NewRoleDialog> createState() => _NewRoleDialogState();
}

class _NewRoleDialogState extends State<_NewRoleDialog> {
  late final TextEditingController _name;
  late String _emoji;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editing?.name ?? '');
    _emoji = widget.editing?.emoji ?? kPresetEmojis.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.editing == null ? '新增角色' : '编辑角色'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '角色名（如：tuant、妈妈）',
                border: OutlineInputBorder(),
              ),
              maxLength: 12,
            ),
            const SizedBox(height: 12),
            const Text('选择头像：'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kPresetEmojis.map((e) {
                final selected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? Border.all(color: cs.primary, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(e, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              Role(id: widget.editing?.id, name: name, emoji: _emoji),
            );
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
