import 'package:flutter_test/flutter_test.dart';
import 'package:banco_douro_app/models/transaction.dart';

void main() {
  final fixedDate = DateTime(2024, 6, 15, 10, 30);

  Transaction makeTransaction({
    String id = 'tx-001',
    String sender = 'acc-1',
    String receiver = 'acc-2',
    double amount = 1000.0,
    double taxes = 0.0,
    DateTime? date,
  }) {
    return Transaction(
      id: id,
      senderAccountId: sender,
      receiverAccountId: receiver,
      date: date ?? fixedDate,
      amount: amount,
      taxes: taxes,
    );
  }

  group('Transaction.toMap / fromMap', () {
    test('deve serializar e desserializar corretamente', () {
      final original = makeTransaction();
      final map = original.toMap();
      final restored = Transaction.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.senderAccountId, original.senderAccountId);
      expect(restored.receiverAccountId, original.receiverAccountId);
      expect(restored.amount, original.amount);
      expect(restored.taxes, original.taxes);
    });

    test('deve converter date para millisecondsSinceEpoch e de volta', () {
      final original = makeTransaction(date: fixedDate);
      final map = original.toMap();

      expect(map['date'], fixedDate.millisecondsSinceEpoch);

      final restored = Transaction.fromMap(map);
      expect(restored.date.millisecondsSinceEpoch, fixedDate.millisecondsSinceEpoch);
    });
  });

  group('Transaction.toJson / fromJson', () {
    test('deve serializar para JSON e desserializar corretamente', () {
      final original = makeTransaction();
      final json = original.toJson();
      final restored = Transaction.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
    });
  });

  group('Transaction.copyWith', () {
    test('deve alterar apenas os campos especificados', () {
      final original = makeTransaction(amount: 1000.0, taxes: 0.0);
      final copia = original.copyWith(amount: 5000.0, taxes: 12.5);

      expect(copia.id, original.id);
      expect(copia.senderAccountId, original.senderAccountId);
      expect(copia.amount, 5000.0);
      expect(copia.taxes, 12.5);
    });

    test('não deve alterar o objeto original', () {
      final original = makeTransaction(amount: 1000.0);
      original.copyWith(amount: 9999.0);

      expect(original.amount, 1000.0);
    });
  });

  group('Transaction equality', () {
    test('transações com mesmos dados devem ser iguais', () {
      final t1 = makeTransaction();
      final t2 = makeTransaction();

      expect(t1, equals(t2));
    });

    test('transações com id diferente não devem ser iguais', () {
      final t1 = makeTransaction(id: 'tx-001');
      final t2 = makeTransaction(id: 'tx-002');

      expect(t1, isNot(equals(t2)));
    });
  });
}
