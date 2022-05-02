import 'package:chips_choice/chips_choice.dart';
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

  int tag = 0;
  List<String> expense = [
    'Food',
    'Entertainment',
    'Transport',
    'Fees',
    'Mobile',
    'Education',
    'Clothes',
    'Others'
  ];
  List<String> income = [
    'Monthly Income',
    'Pocket Money',
    'Gift',
    'Found',
    'Others'
  ];

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
                              t.isExpense
                                  ? '- Rs ' + t.amount.abs().toString()
                                  : '+ Rs ' + t.amount.abs().toString(),
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
          onPressed: () async => showModalBottomSheet<void>(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              isScrollControlled: true,
              builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    Padding(
                      padding: const EdgeInsets.all(50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Income',
                                  style: TextStyle(
                                    fontSize: 20,
                                      color: isExpense
                                          ? Colors.white30
                                          : Colors.white)),
                              Switch(
                                value: isExpense,
                                onChanged: (value) {
                                  setState(() {
                                    isExpense = value;
                                  });
                                },
                                activeColor: Colors.white70,
                              ),
                              Text('Expense',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: isExpense
                                          ? Colors.white
                                          : Colors.white30))
                            ],
                          ),
                          const SizedBox(height: 30),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: amountController,
                              textInputAction: TextInputAction.go,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'This field cannot be empty';
                                } else if (int.parse(value) <= 0) {
                                  return 'Enter a positive value only';
                                } else {
                                  return null;
                                }
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: false),
                              decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ChipsChoice<int>.single(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            wrapped: true,
                            choiceStyle: const C2ChoiceStyle(
                              showCheckmark: false,
                            ),
                            padding: EdgeInsets.zero,
                            value: tag,
                            onChanged: (val) => setState(() => tag = val),
                            choiceItems: C2Choice.listFrom<int, String>(
                              source: isExpense ? expense : income,
                              value: (i, v) => i,
                              label: (i, v) => v,
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: ElevatedButton(
                              child: const Text('Confirm'),
                              onPressed: () {
                                addTransaction();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void addTransaction() {
    final int amount = int.parse(amountController.text);
    final newTrans = Transaction(
        detail: isExpense ? expense[tag] : income[tag],
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
