import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';


class SelectAuthorPublishing extends StatelessWidget {
  const SelectAuthorPublishing({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddProductController>(
        builder: (context, resProvider, child){
        return const Column(
          children: [

          ],
        );
      }
    );
  }
}
