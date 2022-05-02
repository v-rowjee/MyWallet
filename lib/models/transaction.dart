import 'dart:convert';

class Transaction{

  String detail;
  int amount;
  bool isExpense;
  DateTime datetime;

  Transaction({
    required this.detail,
    required this.amount,
    required this.isExpense,
    required this.datetime
  });

  static Map <String, dynamic> toJson(Transaction t) => {
    'detail' : t.detail,
    'amount' : t.amount,
    'isExpense' : t.isExpense ? 0 : 1,
    'datetime' : t.datetime.toIso8601String()
  };

  static Transaction fromJson(Map<String, dynamic> json) => Transaction(
    detail: json['detail'],
    amount: json['amount'],
    isExpense: json['isExpense']==0,
    datetime: DateTime.parse(json['datetime'])
  );

  static String encode(List<Transaction> trans) => json.encode(
    trans
        .map<Map<String, dynamic>>((tran) => Transaction.toJson(tran))
        .toList(),
  );

  static List<Transaction> decode(String trans) =>
      (json.decode(trans) as List<dynamic>)
          .map<Transaction>((item) => Transaction.fromJson(item))
          .toList();

}