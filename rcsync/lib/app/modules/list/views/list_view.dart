import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_notes/app/data/models/productes_model.dart';
import 'package:supabase_notes/app/routes/app_pages.dart';
import '../controllers/list_controller.dart';

class ListProductesView extends GetView<ListController> {
  const ListProductesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.currentSupermercat?.title ?? 'PRODUCTOS'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.PROFILE),
            icon: const Icon(Icons.person),
          )
        ],
      ),
      body: FutureBuilder(
        future: controller.getAllProductes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Obx(() => controller.allProductes.isEmpty
              ? const Center(child: Text("No hay productos en este supermercado"))
              : ListView.builder(
            itemCount: controller.allProductes.length,
            itemBuilder: (context, index) {
              Producte producte = controller.allProductes[index];
              return ListTile(
                onTap: () => Get.toNamed(
                  Routes.EDIT_PRODUCTE,
                  arguments: producte,
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.shopping_basket_outlined),
                ),
                title: Text("${producte.producte}"),
                subtitle: Text("Cantidad: ${producte.quantitat}"),
                trailing: IconButton(
                  onPressed: () async => await controller.deleteProduct(producte.id!),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              );
            },
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.currentSupermercat != null) {
            Get.toNamed(
              Routes.ADD_PRODUCTE,
              arguments: controller.currentSupermercat,
            );
          } else {
            Get.snackbar("Error", "No se pudo identificar el supermercado");
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}