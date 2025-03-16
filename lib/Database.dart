import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Expense.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();
  Database? _database;

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ExpenseDB.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE Expense (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            date TEXT,
            category TEXT
          )
        """);
      },
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    var result = await db.query("Expense", orderBy: "date DESC");
    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<Expense> insert(Expense expense) async {
    final db = await database;
    int id = await db.insert("Expense", expense.toMap());
    return Expense(id, expense.amount, expense.date, expense.category);
  }

  Future<void> update(Expense expense) async {
    final db = await database;
    await db.update("Expense", expense.toMap(), where: "id = ?", whereArgs: [expense.id]);
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete("Expense", where: "id = ?", whereArgs: [id]);
  }
}
