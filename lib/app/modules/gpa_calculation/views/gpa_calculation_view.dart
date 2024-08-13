import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/gpa_calculation_controller.dart';

class GpaCalculationView extends GetView<GpaCalculationController> {
  const GpaCalculationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GpaCalculationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'GpaCalculationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
