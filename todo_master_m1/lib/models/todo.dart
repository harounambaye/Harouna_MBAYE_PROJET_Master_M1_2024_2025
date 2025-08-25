class TodoItem {
  int? serverId;     // L'id sur le serveur (null si pas encore sync)
  final String localId;    // id local (uuid)
  final int accountId;
  DateTime date;
  String text;
  bool done;

  // Offline flags
  bool dirty;              // à synchroniser
  String pendingOp;        // 'insert'|'update'|'delete'|''

  TodoItem({
    required this.serverId,
    required this.localId,
    required this.accountId,
    required this.date,
    required this.text,
    required this.done,
    this.dirty = false,
    this.pendingOp = '',
  });

  factory TodoItem.fromServer(Map<String, dynamic> j, int accountId) => TodoItem(
    serverId: int.tryParse(j['todo_id'].toString()),
    localId: 'srv_${j['todo_id']}',
    accountId: accountId,
    date: DateTime.parse(j['date']),
    text: j['todo'] ?? '',
    done: (j['done'] == true) || (j['done'].toString() == '1'),
    dirty: false,
    pendingOp: '',
  );
}
