import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';

class SQL_Functions {

  static Future<sql.Database> openDb() async {
    return sql.openDatabase('mynotes', version: 1,
        onCreate: (sql.Database db, int version) async {
          await createTable(db);
        });
  }

  static Future<void> createTable(sql.Database db) async {
    await db.execute(
        'CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, ndate TEXT, nnotes TEXT)');
  }

  static Future<int> addnewnotes(String date, String notes) async {
    final db = await SQL_Functions.openDb(); //database open
    final data = {"ndate": date, "nnotes": notes};
    final id = await db.insert('nnotes', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> readNotes() async {
    final db = await SQL_Functions.openDb();
    return db.query('nnotes', orderBy: 'id');
  }

  static Future<int> updateNote(int id, String date, String notes) async {
    final db = await SQL_Functions.openDb();
    final updateddata = {'ndate': date, 'nnotes': notes};
    final updatedid =
    db.update('nnotes', updateddata, where: 'id=?', whereArgs: [id]);
    return updatedid;
  }

  static Future<void> removeNote(int id) async {
    final db = await SQL_Functions.openDb();
    try {
      await db.delete('nnotes', where: 'id=?', whereArgs: [id]);
    } catch (e) {
      print('Something went wrong $e');
      }
    }
}
