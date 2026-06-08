import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/baby_profile.dart';
import '../models/conversation.dart';
import '../models/role.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'kids_quotes.db'),
      version: 1,
      onCreate: _onCreate,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE baby_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        birthday INTEGER NOT NULL,
        emoji TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        occurred_at INTEGER NOT NULL,
        background TEXT,
        baby_age_snapshot TEXT
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_conv_occurred ON conversations(occurred_at)');
    await db.execute('''
      CREATE TABLE turns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER NOT NULL,
        role_name TEXT NOT NULL,
        role_emoji TEXT,
        content TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY(conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        emoji TEXT NOT NULL
      )
    ''');
  }

  // ===== BabyProfile =====
  Future<BabyProfile?> getBabyProfile() async {
    final db = await database;
    final rows = await db.query('baby_profile', where: 'id = 1');
    if (rows.isEmpty) return null;
    return BabyProfile.fromMap(rows.first);
  }

  Future<void> saveBabyProfile(BabyProfile profile) async {
    final db = await database;
    await db.insert('baby_profile', profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ===== Roles =====
  Future<List<Role>> getAllRoles() async {
    final db = await database;
    final rows = await db.query('roles', orderBy: 'id ASC');
    return rows.map(Role.fromMap).toList();
  }

  Future<void> upsertRole(Role role) async {
    final db = await database;
    final existing = await db.query('roles',
        where: 'name = ?', whereArgs: [role.name], limit: 1);
    if (existing.isEmpty) {
      await db.insert('roles', role.toMap());
    } else {
      await db.update('roles', {'emoji': role.emoji},
          where: 'name = ?', whereArgs: [role.name]);
    }
  }

  Future<void> deleteRole(int id) async {
    final db = await database;
    await db.delete('roles', where: 'id = ?', whereArgs: [id]);
  }

  // ===== Conversations =====
  Future<int> insertConversation(Conversation conv) async {
    final db = await database;
    return await db.transaction((tx) async {
      final id = await tx.insert('conversations', conv.toConvMap());
      for (var i = 0; i < conv.turns.length; i++) {
        await tx.insert('turns', conv.turns[i].toMap(id, i));
      }
      return id;
    });
  }

  Future<void> updateConversation(Conversation conv) async {
    final db = await database;
    await db.transaction((tx) async {
      await tx.update('conversations', conv.toConvMap(),
          where: 'id = ?', whereArgs: [conv.id]);
      await tx.delete('turns',
          where: 'conversation_id = ?', whereArgs: [conv.id]);
      for (var i = 0; i < conv.turns.length; i++) {
        await tx.insert('turns', conv.turns[i].toMap(conv.id!, i));
      }
    });
  }

  Future<void> deleteConversation(int id) async {
    final db = await database;
    await db.transaction((tx) async {
      await tx.delete('turns',
          where: 'conversation_id = ?', whereArgs: [id]);
      await tx.delete('conversations', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Conversation>> getConversations({
    int? year,
    int? month,
  }) async {
    final db = await database;
    String? where;
    List<Object?>? args;
    if (year != null && month != null) {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 1);
      where = 'occurred_at >= ? AND occurred_at < ?';
      args = [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch];
    }
    final convRows = await db.query(
      'conversations',
      where: where,
      whereArgs: args,
      orderBy: 'occurred_at DESC, id DESC',
    );
    final result = <Conversation>[];
    for (final row in convRows) {
      final turnRows = await db.query(
        'turns',
        where: 'conversation_id = ?',
        whereArgs: [row['id']],
        orderBy: 'order_index ASC',
      );
      final turns = turnRows.map(DialogueTurn.fromMap).toList();
      result.add(Conversation.fromMap(row, turns));
    }
    return result;
  }

  Future<List<({int year, int month})>> getAvailableMonths() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT strftime('%Y', datetime(occurred_at/1000, 'unixepoch', 'localtime')) AS y,
                      strftime('%m', datetime(occurred_at/1000, 'unixepoch', 'localtime')) AS m
      FROM conversations
      ORDER BY y DESC, m DESC
    ''');
    return rows
        .map((r) => (
              year: int.parse(r['y'] as String),
              month: int.parse(r['m'] as String),
            ))
        .toList();
  }
}
