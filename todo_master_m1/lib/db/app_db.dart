import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  static Database? _db;
  static Future<Database> get() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'todo_local.db');
    _db = await openDatabase(
      path,
      version: 2,//version 2 car j'ai prévu l'évolution du schéma
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE todos_local(
            local_id TEXT PRIMARY KEY,
            server_id INTEGER,
            account_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            text TEXT NOT NULL,
            done INTEGER NOT NULL,
            dirty INTEGER NOT NULL DEFAULT 0,
            pending_op TEXT NOT NULL DEFAULT ''
          );
        ''');
               // Ici je créé Index pour accélérer les recherches
        await db.execute('CREATE INDEX idx_account ON todos_local(account_id);');
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS uq_server_id ON todos_local(server_id);');
      },
      onUpgrade: (db, oldV, newV) async {
        // Upgrade si je passe de la v1 à la v2
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS uq_server_id ON todos_local(server_id);');
      },
      onOpen: (db) async {
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS uq_server_id ON todos_local(server_id);');
      },
    );

    return _db!;
  }
}
