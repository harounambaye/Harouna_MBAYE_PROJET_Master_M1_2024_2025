import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../models/todo.dart';
import '../services/todo_api.dart';

enum TodoViewMode { all, history } 

class TodoProvider extends ChangeNotifier {
  final TodoApi api;
  final int accountId;

  List<TodoItem> _all = [];
  bool loading = false;
  String _search = '';
  TodoViewMode _mode = TodoViewMode.all;

  TodoProvider({required this.api, required this.accountId});

  List<TodoItem> get items {
  Iterable<TodoItem> it = _all.where((e) => e.pendingOp != 'delete'); 
  if (_mode == TodoViewMode.history) {
    it = it.where((e) => e.done);
  }
  if (_search.isNotEmpty) {
    final q = _search.toLowerCase();
    it = it.where((e) => e.text.toLowerCase().contains(q));
  }
  return it.toList();
}

  TodoViewMode get mode => _mode;
  String get search => _search;

  void setMode(TodoViewMode m){ _mode = m; notifyListeners(); }
  void setSearch(String q){ _search = q; notifyListeners(); }

  Future<void> load() async {
    loading = true; notifyListeners();
    await _loadLocal();
    loading = false; notifyListeners();

    await refreshFromServerAndMerge();
    await replayPending(); 
  }

  Future<void> _loadLocal() async {
    final db = await AppDb.get();
    final rows = await db.query('todos_local',
        where: 'account_id=?', whereArgs: [accountId],
        orderBy: "date DESC");
    _all = rows.map((r) => TodoItem(
      serverId: r['server_id'] as int?,
      localId: r['local_id'] as String,
      accountId: r['account_id'] as int,
      date: DateTime.parse(r['date'] as String),
      text: r['text'] as String,
      done: (r['done'] as int) == 1,
      dirty: (r['dirty'] as int) == 1,
      pendingOp: (r['pending_op'] as String),
    )).toList();
  }

  Future<void> refreshFromServerAndMerge() async {
    try {
      final remote = await api.fetchTodos(accountId);
      final srvList = remote.map((m) => TodoItem.fromServer(m, accountId)).toList();
      final db = await AppDb.get();

      final Map<int, TodoItem> localByServerId = {
        for (final t in _all) if (t.serverId != null) t.serverId!: t
      };

      await db.transaction((txn) async {
        for (final s in srvList) {
          final existing = localByServerId[s.serverId!];
          if (existing == null) {
            await txn.insert('todos_local', {
              'local_id': s.localId,
              'server_id': s.serverId,
              'account_id': s.accountId,
              'date': s.date.toIso8601String().substring(0,10),
              'text': s.text,
              'done': s.done ? 1 : 0,
              'dirty': 0,
              'pending_op': ''
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          } else {

            if (!existing.dirty) {
              await txn.update('todos_local', {
                'date': s.date.toIso8601String().substring(0,10),
                'text': s.text,
                'done': s.done ? 1 : 0,
              }, where: 'local_id=?', whereArgs: [existing.localId]);
            }
          }
        }

      });

      await _loadLocal(); 
      notifyListeners();
    } catch (_) {
     
    }
  }

  // CRUD + Sync

  Future<void> add(String text, DateTime date) async {
    final local = TodoItem(
      serverId: null,
      localId: const Uuid().v4(),
      accountId: accountId,
      date: date,
      text: text,
      done: false,
      dirty: true,
      pendingOp: 'insert',
    );

    _all.insert(0, local); notifyListeners();

    final db = await AppDb.get();
    await db.insert('todos_local', {
      'local_id': local.localId,
      'server_id': null,
      'account_id': accountId,
      'date': date.toIso8601String().substring(0,10),
      'text': text,
      'done': 0,
      'dirty': 1,
      'pending_op': 'insert',
    });

    await _trySyncInsert(local);
  }

  Future<void> edit(TodoItem it, {String? text, DateTime? date}) async {
    if (text != null) it.text = text;
    if (date != null) it.date = date;
    it.dirty = true;
    it.pendingOp = it.serverId == null ? 'insert' : 'update';
    notifyListeners();

    final db = await AppDb.get();
    await db.update('todos_local', {
      'text': it.text,
      'date': it.date.toIso8601String().substring(0,10),
      'dirty': 1,
      'pending_op': it.pendingOp
    }, where: 'local_id=?', whereArgs: [it.localId]);

    await _trySyncUpdate(it);
  }

  Future<void> toggleDone(TodoItem it, bool done) async {
    it.done = done;
    it.dirty = true;
    it.pendingOp = it.serverId == null ? 'insert' : 'update';
    notifyListeners();

    final db = await AppDb.get();
    await db.update('todos_local', {
      'done': done ? 1 : 0, 'dirty': 1, 'pending_op': it.pendingOp
    }, where: 'local_id=?', whereArgs: [it.localId]);

    await _trySyncUpdate(it);
  }

  Future<void> delete(TodoItem it) async {
  final db = await AppDb.get();

  _all.removeWhere((e) => e.localId == it.localId);
  notifyListeners();

  if (it.serverId == null) {
    // Pas encore sur le serveur : je peut supprimer réellement en local
    await db.delete('todos_local', where: 'local_id=?', whereArgs: [it.localId]);
    return;
  }

  await db.update(
    'todos_local',
    {'dirty': 1, 'pending_op': 'delete'},
    where: 'local_id=?',
    whereArgs: [it.localId],
  );

  try {
    await api.deleteTodo(it.serverId!);
    await db.delete('todos_local', where: 'local_id=?', whereArgs: [it.localId]);
  } catch (_) {

  }
}


  Future<void> replayPending() async {
    final db = await AppDb.get();
    final rows = await db.query('todos_local',
      where: 'account_id=? AND dirty=1', whereArgs: [accountId]);
    for (final r in rows) {
      final it = TodoItem(
        serverId: r['server_id'] as int?,
        localId: r['local_id'] as String,
        accountId: r['account_id'] as int,
        date: DateTime.parse(r['date'] as String),
        text: r['text'] as String,
        done: (r['done'] as int) == 1,
        dirty: true,
        pendingOp: (r['pending_op'] as String),
      );
      if (it.pendingOp == 'insert') { await _trySyncInsert(it); }
      else if (it.pendingOp == 'update') { await _trySyncUpdate(it); }
      else if (it.pendingOp == 'delete') { await _trySyncDelete(it); }
    }
    await _loadLocal(); notifyListeners();
  }


  Future<void> _trySyncInsert(TodoItem it) async {
    try {
      final res = await api.insertTodo(
        accountId: accountId,
        date: it.date.toIso8601String().substring(0,10),
        text: it.text,
        done: it.done,
      );

  
      final data = res['data'];
      final newId = data is Map<String, dynamic>
          ? int.tryParse('${data['todo_id']}')
          : null;

      if (newId != null) {
        it.serverId = newId;
        it.dirty = false; it.pendingOp = '';
        final db = await AppDb.get();
        await db.update('todos_local', {
          'server_id': newId, 'dirty': 0, 'pending_op': ''
        }, where: 'local_id=?', whereArgs: [it.localId]);
        notifyListeners();
      }
    } catch (_) {}
  }


  Future<void> _trySyncUpdate(TodoItem it) async {
    if (it.serverId == null) { await _trySyncInsert(it); return; }
    try {
      await api.updateTodo(
        todoId: it.serverId!,
        date: it.date.toIso8601String().substring(0,10),
        text: it.text,
        done: it.done,
      );
      final db = await AppDb.get();
      it.dirty = false; it.pendingOp = '';
      await db.update('todos_local', {'dirty': 0, 'pending_op': ''},
        where: 'local_id=?', whereArgs: [it.localId]);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _trySyncDelete(TodoItem it) async {
    if (it.serverId == null) return;
    try {
      await api.deleteTodo(it.serverId!);
      final db = await AppDb.get();
      _all.removeWhere((e) => e.localId == it.localId);
      await db.delete('todos_local', where: 'local_id=?', whereArgs: [it.localId]);
      notifyListeners();
    } catch (_) {}
  }
}
