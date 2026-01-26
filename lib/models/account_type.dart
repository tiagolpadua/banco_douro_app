import 'dart:convert';

class AccountType {
  String id;
  String description;

  AccountType({required this.id, required this.description});

  factory AccountType.fromMap(Map<String, dynamic> map) {
    return AccountType(
      id: map['id'].toString(),
      description: map['description'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'description': description};
  }

  String toJson() => json.encode(toMap());

  factory AccountType.fromJson(String source) =>
      AccountType.fromMap(json.decode(source) as Map<String, dynamic>);
}
