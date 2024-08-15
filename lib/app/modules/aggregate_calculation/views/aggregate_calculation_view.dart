import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/aggregate_calculation_controller.dart';

class AggregateCalculationView extends GetView<AggregateCalculationController> {
  const AggregateCalculationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AggregateCalculationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AggregateCalculationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
