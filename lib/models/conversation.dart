class DialogueTurn {
  final String role;
  final String emoji;
  final String content;
  final bool isInnerThought;

  const DialogueTurn({
    required this.role,
    required this.emoji,
    required this.content,
    this.isInnerThought = false,
  });

  Map<String, dynamic> toMap(int conversationId, int order) => {
        'conversation_id': conversationId,
        'role_name': role,
        'role_emoji': emoji,
        'content': content,
        'order_index': order,
        'is_inner_thought': isInnerThought ? 1 : 0,
      };

  factory DialogueTurn.fromMap(Map<String, dynamic> m) => DialogueTurn(
        role: m['role_name'] as String,
        emoji: (m['role_emoji'] as String?) ?? '👤',
        content: m['content'] as String,
        isInnerThought: (m['is_inner_thought'] as int? ?? 0) == 1,
      );
}

class Conversation {
  final int? id;
  final DateTime occurredAt;
  final String? background;
  final String babyAgeSnapshot;
  final List<DialogueTurn> turns;

  const Conversation({
    this.id,
    required this.occurredAt,
    this.background,
    required this.babyAgeSnapshot,
    required this.turns,
  });

  Map<String, dynamic> toConvMap() => {
        if (id != null) 'id': id,
        'occurred_at': occurredAt.millisecondsSinceEpoch,
        'background': background,
        'baby_age_snapshot': babyAgeSnapshot,
      };

  factory Conversation.fromMap(
    Map<String, dynamic> m,
    List<DialogueTurn> turns,
  ) =>
      Conversation(
        id: m['id'] as int,
        occurredAt:
            DateTime.fromMillisecondsSinceEpoch(m['occurred_at'] as int),
        background: m['background'] as String?,
        babyAgeSnapshot: (m['baby_age_snapshot'] as String?) ?? '',
        turns: turns,
      );

  Conversation copyWith({
    int? id,
    DateTime? occurredAt,
    String? background,
    String? babyAgeSnapshot,
    List<DialogueTurn>? turns,
  }) =>
      Conversation(
        id: id ?? this.id,
        occurredAt: occurredAt ?? this.occurredAt,
        background: background ?? this.background,
        babyAgeSnapshot: babyAgeSnapshot ?? this.babyAgeSnapshot,
        turns: turns ?? this.turns,
      );
}
