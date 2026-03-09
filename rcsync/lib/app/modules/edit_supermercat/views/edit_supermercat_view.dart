// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_notes/app/data/models/supermercats_model.dart';
import 'package:supabase_notes/app/modules/home/controllers/home_controller.dart';

import '../controllers/edit_supermercat_controller.dart';

class EditSupermercatView extends GetView<EditSupermercatController> {
  Supermercat supermercat = Get.arguments;
  HomeController homeC = Get.find();

  EditSupermercatView({super.key});
  @override
  Widget build(BuildContext context) {

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
                labelText: "Supermercat",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            TextField(
              controller: controller.descC,
              decoration: const InputDecoration(
                labelText: "Descripció",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(() => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    bool res = await controller.editSupermercat(supermercat.id!);
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
