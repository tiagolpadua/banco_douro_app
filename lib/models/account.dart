import 'dart:convert';

class Account {
  String id;
  String name;
  String lastName;
  double balance;
  String? accountTypeId;

  Account({
    required this.id,
    required this.name,
    required this.lastName,
    required this.balance,
    this.accountTypeId,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'].toString(),
      name: map['name'] as String,
      lastName: map['lastName'] as String,
      balance: (map['balance'] is int)
          ? (map['balance'] as int).toDouble()
          : map['balance'] as double,
      accountTypeId: (map['accountTypeId'] != null)
          ? map['accountTypeId'].toString()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'lastName': lastName,
      'balance': balance,
      'accountTypeId': accountTypeId,
    };
  }

  Account copyWith({
    String? id,
    String? name,
    String? lastName,
    double? balance,
    String? accountTypeId,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      balance: balance ?? this.balance,
      accountTypeId: accountTypeId ?? this.accountTypeId,
    );
  }

  String toJson() => json.encode(toMap());

  factory Account.fromJson(String source) =>
      Account.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '\nConta $id\n$name $lastName\nSaldo: $balance\n';
  }

  @override
  bool operator ==(covariant Account other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.lastName == lastName &&
        other.balance == balance &&
        other.accountTypeId == accountTypeId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        lastName.hashCode ^
        balance.hashCode ^
        accountTypeId.hashCode;
  }
}
