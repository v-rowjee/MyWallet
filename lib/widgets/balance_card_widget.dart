import 'package:flutter/material.dart';
import 'package:mywallet/models/transaction.dart';

class BalanceCardWidget extends StatelessWidget {
  const BalanceCardWidget({Key? key, required this.list}) : super(key: key);
  final List<Transaction> list;

  String getBalance() {
    int sum = 0;
    for (var transaction in list) {
      sum += transaction.amount;
    }
    if (sum < 0) {
      return '- Rs ' + sum.abs().toString();
    } else {
      return 'Rs ' + sum.toString();
    }
  }

  String getIncome() {
    int sum = 0;
    for (var transaction in list) {
      if (!transaction.isExpense) {
        sum += transaction.amount;
      }
    }
    return sum.toString();
  }

  String getExpense() {
    int sum = 0;
    for (var transaction in list) {
      if (transaction.isExpense) {
        sum += transaction.amount;
      }
    }
    return sum.abs().toString();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      child: Card(
        margin: const EdgeInsets.all(25),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("BALANCE",
                  style: TextStyle(color: Colors.white54, letterSpacing: 5)),
              const SizedBox(height: 5),
              Text(getBalance(), style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.arrow_circle_up),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Income",
                              style: TextStyle(color: Colors.white54)),
                          Text("Rs " + getIncome())
                        ])
                  ]),
                  Row(children: [
                    const Icon(Icons.arrow_circle_down),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Expense",
                              style: TextStyle(color: Colors.white54)),
                          Text("Rs " + getExpense())
                        ])
                  ]),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
