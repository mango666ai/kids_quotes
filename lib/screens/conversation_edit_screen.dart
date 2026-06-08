import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/baby_profile.dart';
import '../models/conversation.dart';
import '../models/role.dart';
import '../utils/age_calculator.dart';
import '../widgets/new_role_dialog.dart';
import '../widgets/role_picker_sheet.dart';

class ConversationEditScreen extends StatefulWidget {
  final BabyProfile profile;
  final Conversation? editing;

  const ConversationEditScreen({
    super.key,
    required this.profile,
    this.editing,
  });

  @override
  State<ConversationEditScreen> createState() => _ConversationEditScreenState();
}

class _ConversationEditScreenState extends State<ConversationEditScreen> {
  final _db = DatabaseHelper.instance;
  final _inputCtrl = TextEditingController();
  final _bgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late DateTime _occurredAt;
  List<DialogueTurn> _turns = [];
  List<Role> _roles = [];
  Role? _currentRole;
  bool _isInnerThought = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _occurredAt = widget.editing?.occurredAt ?? DateTime.now();
    if (widget.editing != null) {
      _turns = List.from(widget.editing!.turns);
      _bgCtrl.text = widget.editing!.background ?? '';
    }
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final roles = await _db.getAllRoles();
    setState(() {
      _roles = roles;
      if (_currentRole == null && roles.isNotEmpty) {
        _currentRole = roles.first;
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _bgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String get _ageLabel {
    return calcAge(widget.profile.birthday, _occurredAt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: widget.profile.birthday,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _occurredAt = picked);
  }

  Future<void> _switchRole() async {
    final picked = await showRolePickerSheet(context, roles: _roles);
    if (picked == null) return;
    if (picked.id == null) {
      await _db.upsertRole(picked);
      await _loadRoles();
      final all = await _db.getAllRoles();
      final saved = all.firstWhere((r) => r.name == picked.name);
      setState(() => _currentRole = saved);
    } else {
      setState(() => _currentRole = picked);
    }
  }

  void _sendTurn() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _currentRole == null) return;

    final turn = DialogueTurn(
      role: _currentRole!.name,
      emoji: _currentRole!.emoji,
      content: text,
      isInnerThought: _isInnerThought,
    );
    setState(() => _turns.add(turn));
    _inputCtrl.clear();

    // Auto-switch: if there are exactly 2 distinct roles, toggle
    final distinctRoles = _turns.map((t) => t.role).toSet();
    if (distinctRoles.length == 2) {
      final other =
          distinctRoles.firstWhere((r) => r != _currentRole!.name);
      final otherRole = _roles.firstWhere((r) => r.name == other,
          orElse: () => Role(name: other, emoji: '👤'));
      setState(() => _currentRole = otherRole);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addNewRoleFromChip() async {
    final newRole = await showNewRoleDialog(context);
    if (newRole == null) return;
    await _db.upsertRole(newRole);
    await _loadRoles();
    final all = await _db.getAllRoles();
    final saved = all.firstWhere((r) => r.name == newRole.name);
    setState(() => _currentRole = saved);
  }

  Future<void> _editTurn(int index) async {
    final turn = _turns[index];
    final ctrl = TextEditingController(text: turn.content);
    bool innerThought = turn.isInnerThought;

    final result = await showDialog<DialogueTurn>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('编辑 ${turn.emoji} ${turn.role}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '内容',
                ),
                maxLines: 5,
                minLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: innerThought,
                    onChanged: (v) => setS(() => innerThought = v),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    innerThought ? '💭 心里想的' : '🗣️ 说出的话',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消')),
            FilledButton(
              onPressed: () {
                final text = ctrl.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(
                  ctx,
                  DialogueTurn(
                    role: turn.role,
                    emoji: turn.emoji,
                    content: text,
                    isInnerThought: innerThought,
                  ),
                );
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (result != null) {
      setState(() => _turns[index] = result);
    }
  }

  Future<void> _save() async {
    if (_turns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('至少记录一句话哦～')),
      );
      return;
    }

    final conv = Conversation(
      id: widget.editing?.id,
      occurredAt: _occurredAt,
      background: _bgCtrl.text.trim().isEmpty ? null : _bgCtrl.text.trim(),
      babyAgeSnapshot: _ageLabel,
      turns: _turns,
    );

    if (_isEditing) {
      await _db.updateConversation(conv);
    } else {
      await _db.insertConversation(conv);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateText = DateFormat('yyyy-MM-dd').format(_occurredAt);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        title: Text(_isEditing ? '编辑童言' : '记录童言'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('完成'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date chip + background
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          '$dateText  ·  ${widget.profile.name} $_ageLabel',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down,
                            size: 16, color: cs.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bgCtrl,
                  decoration: InputDecoration(
                    hintText: '发生的场景（可选，如：晚上散步时）',
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                    prefixIcon: Icon(Icons.place_outlined,
                        size: 18, color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: cs.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 14, color: cs.onSurface),
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Role chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ..._roles.map((r) {
                  final selected = r.name == _currentRole?.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _currentRole = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primaryContainer
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: selected
                              ? Border.all(color: cs.primary, width: 1.5)
                              : null,
                        ),
                        child: Text(
                          '${r.emoji} ${r.name}',
                          style: TextStyle(
                            fontSize: 13,
                            color: selected
                                ? cs.onPrimaryContainer
                                : cs.onSurface,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: _addNewRoleFromChip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: cs.outline.withOpacity(0.5),
                          style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('新增',
                            style: TextStyle(
                                fontSize: 13, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Dialogue bubbles
          Expanded(
            child: _turns.isEmpty
                ? Center(
                    child: Text(
                      '孩子说了什么有趣的话？',
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _turns.length,
                    itemBuilder: (ctx, i) => _buildBubble(ctx, i),
                  ),
          ),

          // Bottom input bar
          _buildInputBar(cs),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext ctx, int i) {
    final turn = _turns[i];
    final cs = Theme.of(ctx).colorScheme;
    final isThought = turn.isInnerThought;

    return Dismissible(
      key: ValueKey('$i-${turn.content}-${turn.isInnerThought}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => setState(() => _turns.removeAt(i)),
      child: GestureDetector(
        onTap: () => _editTurn(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(turn.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          turn.role,
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600),
                        ),
                        if (isThought) ...[
                          const SizedBox(width: 4),
                          Text(
                            '💭 心里想的',
                            style: TextStyle(
                                fontSize: 10,
                                color: cs.onSurfaceVariant.withOpacity(0.7)),
                          ),
                        ],
                        const Spacer(),
                        Icon(Icons.edit_outlined,
                            size: 12, color: cs.onSurfaceVariant.withOpacity(0.5)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isThought
                            ? cs.tertiaryContainer.withOpacity(0.6)
                            : cs.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: isThought
                            ? Border.all(
                                color: cs.tertiary.withOpacity(0.4),
                                style: BorderStyle.solid,
                              )
                            : null,
                      ),
                      child: Text(
                        turn.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: cs.onSurface,
                          fontStyle: isThought
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(ColorScheme cs) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
              top: BorderSide(
                  color: cs.outlineVariant.withOpacity(0.5))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Inner thought toggle
            GestureDetector(
              onTap: () => setState(() => _isInnerThought = !_isInnerThought),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isInnerThought
                      ? cs.tertiaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: _isInnerThought
                      ? Border.all(
                          color: cs.tertiary.withOpacity(0.6), width: 1)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isInnerThought ? '💭 心里想的' : '🗣️ 说出的话',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isInnerThought
                            ? cs.onTertiaryContainer
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: _isInnerThought
                          ? cs.onTertiaryContainer
                          : cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Role selector button
                GestureDetector(
                  onTap: _switchRole,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentRole != null
                              ? '${_currentRole!.emoji} ${_currentRole!.name}'
                              : '+ 选角色',
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_drop_down,
                            size: 16, color: cs.onPrimaryContainer),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: InputDecoration(
                      hintText:
                          _isInnerThought ? '心里想的是…' : '说了什么…',
                      hintStyle: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _isInnerThought
                          ? cs.tertiaryContainer.withOpacity(0.4)
                          : cs.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: _isInnerThought
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendTurn(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                IconButton.filled(
                  onPressed: _sendTurn,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
