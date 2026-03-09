// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../list/controllers/list_controller.dart';
import '../controllers/add_producte_controller.dart';

class AddProducteView extends GetView<AddProducteController> {

  AddProducteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Afegir a ${controller.supermercat?.title ?? "Llista"}'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller.producteC,
              decoration: const InputDecoration(
                labelText: "Producte",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: controller.quantitatC,
              decoration: const InputDecoration(
                labelText: "Quantitat",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                onPressed: controller.isLoading.isFalse
                    ? () async {
                  bool success = await controller.addProducte();

                  if (success) {
                    Get.back();
                    if (Get.isRegistered<ListController>()) {
                      Get.find<ListController>().getAllProductes();
                    }
                  }
                }
                    : null,
                child: Text(
                    controller.isLoading.isFalse ? "Add Product" : "Loading...")))
          ],
        ));
  }
}