import 'package:ew_core/transaction_priority.dart';

class MoneroTransactionPriority extends TransactionPriority {
  const MoneroTransactionPriority({required String title, required int raw})
      : super(title: title, raw: raw);

  static const all = [
    MoneroTransactionPriority.slow,
    MoneroTransactionPriority.automatic,
    MoneroTransactionPriority.medium,
    MoneroTransactionPriority.fast,
    MoneroTransactionPriority.fastest,
  ];
  static const automatic = MoneroTransactionPriority(title: 'Automatic', raw: 0);
  static const slow = MoneroTransactionPriority(title: 'Slow', raw: 1);
  static const medium = MoneroTransactionPriority(title: 'Medium', raw: 2);
  static const fast = MoneroTransactionPriority(title: 'Fast', raw: 3);
  static const fastest = MoneroTransactionPriority(title: 'Fastest', raw: 4);

  static MoneroTransactionPriority deserialize({required int raw}) {
    switch (raw) {
      case 0:
        return automatic;
      case 1:
        return slow;
      case 2:
        return medium;
      case 3:
        return fast;
      case 4:
        return fastest;
      default:
        throw Exception('Unexpected token: $raw for MoneroTransactionPriority deserialize');
    }
  }

  @override
  String toString() {
    switch (this) {
      case MoneroTransactionPriority.slow:
        return 'Slow'; // S.current.transaction_priority_slow;
      case MoneroTransactionPriority.automatic:
        return 'Automatic'; // S.current.transaction_priority_regular;
      case MoneroTransactionPriority.medium:
        return 'Medium'; // S.current.transaction_priority_medium;
      case MoneroTransactionPriority.fast:
        return 'Fast'; // S.current.transaction_priority_fast;
      case MoneroTransactionPriority.fastest:
        return 'Fastest'; // S.current.transaction_priority_fastest;
      default:
        return '';
    }
  }
}
