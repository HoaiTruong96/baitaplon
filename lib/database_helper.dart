import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Task.dart';

class TaskDatabase {
  static final TaskDatabase _instance = TaskDatabase._internal();
  factory TaskDatabase() => _instance;
  TaskDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return openDatabase(
      path,
      version: 2,  // Tăng version để thực hiện thay đổi bảng
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,  // Thêm trường mô tả
            dueDateTime TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(''' 
            ALTER TABLE tasks ADD COLUMN description TEXT;
          ''' );
        }
      },
    );
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

