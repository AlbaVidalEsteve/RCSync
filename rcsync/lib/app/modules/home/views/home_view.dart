import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_notes/app/data/models/supermercats_model.dart';
import 'package:supabase_notes/app/routes/app_pages.dart';
import 'package:supabase_notes/app/controllers/auth_controller.dart';


import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('HOME'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () async => await authC.logout(),
            icon: const Icon(Icons.logout),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                Get.toNamed(Routes.PROFILE);
              },
              icon: const Icon(Icons.person),
            )
          ],
        ),
        body: FutureBuilder(
            future: controller.getAllSupermarquets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Obx(() => controller.allSupermarkets.isEmpty
                  ? const Center(
                      child: Text("NO DATA"),
                    )
                  : ListView.builder(
                      itemCount: controller.allSupermarkets.length,
                      itemBuilder: (context, index) {
                        Supermercat supermercat = controller.allSupermarkets[index];
                        return ListTile(
                          onTap: () {
                            Get.toNamed(Routes.LIST, arguments: supermercat);
                          },
                          leading: CircleAvatar(
                            child: Icon(Icons.shopping_cart_outlined),
                          ),
                          title: Text("Supermercat: ${supermercat.title}"),
                          subtitle: Text("Descripció: ${supermercat.description}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async =>
                                    Get.toNamed(Routes.EDIT_SUPERMERCAT, arguments: supermercat),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async =>
                                await controller.deleteSupermercat(supermercat.id!),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        );
                      },
                    ));
            }),

        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(Routes.ADD_SUPERMERCAT),
          child: const Icon(Icons.add),
        ));
  }
}
