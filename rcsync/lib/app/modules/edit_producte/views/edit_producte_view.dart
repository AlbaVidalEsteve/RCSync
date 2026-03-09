// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_notes/app/data/models/productes_model.dart';
import 'package:supabase_notes/app/modules/home/controllers/home_controller.dart';

import '../controllers/edit_producte_controller.dart';

class EditProducteView extends GetView<EditProducteController> {
  Producte producte = Get.arguments;
  HomeController homeC = Get.find();

  EditProducteView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.titleC.text = producte.producte!;
    controller.descC.text = producte.quantitat!;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller.titleC,
              decoration: const InputDecoration(
                labelText: "Producte",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            TextField(
              controller: controller.descC,
              decoration: const InputDecoration(
                labelText: "Quantitat",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(() => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    bool res = await controller.editProducte(producte.id!);
                    if (res == true) {
                      await homeC.getAllSupermarquets();
                      Get.back();
                    }
                    controller.isLoading.value = false;
                  }
                },
                child: Text(
                    controller.isLoading.isFalse ? "Edit" : "Loading...")))
          ],
        ));
  }
}
