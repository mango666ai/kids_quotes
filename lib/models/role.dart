class Role {
  final int? id;
  final String name;
  final String emoji;

  const Role({this.id, required this.name, this.emoji = '👤'});

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'emoji': emoji,
      };

  factory Role.fromMap(Map<String, dynamic> m) => Role(
        id: m['id'] as int?,
        name: m['name'] as String,
        emoji: (m['emoji'] as String?) ?? '👤',
      );
}
