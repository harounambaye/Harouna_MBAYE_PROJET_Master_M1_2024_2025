class Account {
  final int id;
  final String email;
  Account({required this.id, required this.email});

  factory Account.fromJson(Map<String, dynamic> j) =>
      Account(id: int.parse(j['account_id'].toString()), email: j['email'] ?? '');
}
