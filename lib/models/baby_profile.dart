class BabyProfile {
  final String name;
  final DateTime birthday;
  final String emoji;

  const BabyProfile({
    required this.name,
    required this.birthday,
    this.emoji = '👶🏻',
  });

  Map<String, dynamic> toMap() => {
        'id': 1,
        'name': name,
        'birthday': birthday.millisecondsSinceEpoch,
        'emoji': emoji,
      };

  factory BabyProfile.fromMap(Map<String, dynamic> m) => BabyProfile(
        name: m['name'] as String,
        birthday:
            DateTime.fromMillisecondsSinceEpoch(m['birthday'] as int),
        emoji: (m['emoji'] as String?) ?? '👶🏻',
      );

  BabyProfile copyWith({String? name, DateTime? birthday, String? emoji}) =>
      BabyProfile(
        name: name ?? this.name,
        birthday: birthday ?? this.birthday,
        emoji: emoji ?? this.emoji,
      );
}
