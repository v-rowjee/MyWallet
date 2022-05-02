import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/widgets/balance_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  bool isExpense = true;
  bool isLoading = false;

  @override
  void initState() {
    refreshApp();
    super.initState();
  }

  Future refreshApp() async {
    setState(() => isLoading = true);
    await loadData();
    detailController.clear();
    amountController.clear();
    setState(() => isLoading = false);
    print("refreshed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: clearData,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  BalanceCardWidget(list: transactions),
                  ListView.builder(
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      itemBuilder: (_, index) {
                        Transaction t = transactions[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(t.detail),
                            subtitle: Text(
                                DateFormat('dd/MM/yy').format(t.datetime) +
                                    ' at ' +
                                    DateFormat('kk:mm').format(t.datetime)),
                            trailing: Text(
                              t.isExpense ? '- Rs ' + t.amount.abs().toString() : '+ Rs ' + t.amount.abs().toString(),
                              style: TextStyle(
                                  color: t.isExpense
                                      ? Colors.redAccent
                                      : Colors.greenAccent),
                            ),
                          ),
                        );
                      }),
                  const SizedBox(height: 50)
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async => _displayDialog(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text('NEW TRANSACTION')),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => SizedBox(
                height: 220,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Income',style: TextStyle(color: isExpense ? Colors.white54 : Colors.white)),
                          Switch(
                            value: isExpense,
                            onChanged: (value) {
                              setState(() {
                                isExpense = value;
                              });
                            },
                            activeColor: Colors.white70,
                          ),
                          Text('Expense',style: TextStyle(color: isExpense ? Colors.white : Colors.white54))
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: detailController,
                        validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            labelText: 'Detail', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: amountController,
                        textInputAction: TextInputAction.go,
                        validator: (value){
                          if(value!.isEmpty) {
                            return 'This field cannot be empty';
                          } else if (int.parse(value) <= 0) {
                            return 'Enter a positive value only';
                          } else {
                            return null;
                          }
                        },
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: false),
                        decoration: const InputDecoration(
                            labelText: 'Amount', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.all(16),
            actions: <Widget>[
              ElevatedButton(
                child: const Center(child: Text('Submit')),
                onPressed: () async {
                  addTransaction();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void addTransaction() {
    final int amount = int.parse(amountController.text);
    final newTrans = Transaction(
        detail: detailController.text,
        amount: isExpense ? -amount : amount,
        isExpense: isExpense,
        datetime: DateTime.now());
    transactions.add(newTrans);

    saveData();
  }

  Future saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String encodedData = Transaction.encode(transactions);
    await prefs.setString('transactions', encodedData);

    refreshApp();
  }

  Future loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? decodedData = prefs.getString('transactions');
    transactions = Transaction.decode(decodedData!);
  }

  Future clearData() async {
    transactions.clear();
    saveData();
  }
}
