import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoTile extends StatelessWidget {
  final TodoItem item;
  final ValueChanged<bool?> onChanged;
  const TodoTile({super.key, required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: item.done, onChanged: onChanged),
      title: Text(item.text, style: TextStyle(
        decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
      )),
      subtitle: Text(item.date.toIso8601String().substring(0,10)),
      trailing: item.dirty ? const Icon(Icons.sync_problem) : null,
    );
  }
}
