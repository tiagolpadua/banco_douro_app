import 'dart:convert';

/// AccountType - Tipo de Conta
///
/// Representa os tipos de conta disponiveis no sistema.
/// Cada conta possui uma referencia (accountTypeId) para um AccountType.
class AccountType {
  String id;
  String description;

  AccountType({
    required this.id,
    required this.description,
  });

  factory AccountType.fromMap(Map<String, dynamic> map) {
    return AccountType(
      id: map['id'].toString(),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'description': description,
    };
  }

  AccountType copyWith({
    String? id,
    String? description,
  }) {
    return AccountType(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountType.fromJson(String source) =>
      AccountType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AccountType(id: $id, description: $description)';
  }

  @override
  bool operator ==(covariant AccountType other) {
    if (identical(this, other)) return true;
    return other.id == id && other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode;
}
