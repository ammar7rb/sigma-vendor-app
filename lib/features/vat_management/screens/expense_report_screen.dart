import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('------------Need Design----------', style: robotoBold.copyWith(color: Theme.of(context).colorScheme.error))),
    );
  }
}
