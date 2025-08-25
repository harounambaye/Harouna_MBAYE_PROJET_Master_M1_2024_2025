import 'api_service.dart';

class TodoApi {
  final ApiService _api;
  TodoApi(this._api);

  Future<List<Map<String, dynamic>>> fetchTodos(int accountId) async {
    final data = await _api.post('todos', {"account_id": accountId.toString()});
    if (data['todos'] is List) return List<Map<String, dynamic>>.from(data['todos']);
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<Map<String, dynamic>> insertTodo({
    required int accountId,
    required String date,
    required String text,
    required bool done,
  }) async => await _api.post('inserttodo', {
    "account_id": accountId.toString(),
    "date": date,
    "todo": text,
    "done": done
  });

  Future<Map<String, dynamic>> updateTodo({
    required int todoId,
    required String date,
    required String text,
    required bool done,
  }) async => await _api.post('updatetodo', {
    "todo_id": todoId.toString(),
    "date": date,
    "todo": text,
    "done": done
  });

  Future<Map<String, dynamic>> deleteTodo(int todoId) async =>
      await _api.post('deletetodo', {
        "todo_id": todoId.toString()
      });
}
