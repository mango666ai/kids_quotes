import 'package:flutter/material.dart';

import '../models/role.dart';

const List<({String label, List<String> emojis})> kEmojiCategories = [
  (
    label: '宝宝',
    emojis: ['👶', '🧒', '👦', '👧', '🧑', '👼', '🍼', '🎠'],
  ),
  (
    label: '家人',
    emojis: ['👩', '👨', '👵', '👴', '🤱', '🫂', '💑', '👨‍👩‍👦'],
  ),
  (
    label: '动物',
    emojis: ['🐶', '🐱', '🐰', '🐼', '🦊', '🦁', '🐨', '🐸'],
  ),
  (
    label: '可爱',
    emojis: ['🌟', '⭐', '🌈', '🎀', '🍀', '🌸', '🎈', '💫'],
  ),
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
  late final TextEditingController _customEmoji;
  late String _emoji;

  @override
  void initState() {
    super.initState();
    _emoji = widget.editing?.emoji ?? kEmojiCategories.first.emojis.first;
    _name = TextEditingController(text: widget.editing?.name ?? '');
    _customEmoji = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _customEmoji.dispose();
    super.dispose();
  }

  void _selectEmoji(String e) {
    setState(() {
      _emoji = e;
      _customEmoji.clear();
    });
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
                labelText: '角色名（如：宝宝、妈妈）',
                border: OutlineInputBorder(),
              ),
              maxLength: 12,
            ),
            const SizedBox(height: 12),
            Text(
              '当前头像：$_emoji',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            // Categories
            ...kEmojiCategories.map((cat) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: cat.emojis.map((e) {
                        final selected = e == _emoji;
                        return GestureDetector(
                          onTap: () => _selectEmoji(e),
                          child: Container(
                            width: 40,
                            height: 40,
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
                            child: Text(e,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                )),
            // Custom emoji input
            Row(
              children: [
                Text(
                  '自定义：',
                  style: TextStyle(
                      fontSize: 13, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _customEmoji,
                    decoration: InputDecoration(
                      hintText: '输入emoji',
                      hintStyle: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 20),
                    onChanged: (v) {
                      if (v.isNotEmpty) setState(() => _emoji = v.trim());
                    },
                  ),
                ),
              ],
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
