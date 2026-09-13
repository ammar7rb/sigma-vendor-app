
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class BottomSheetTopBarWidget extends StatelessWidget {
  const BottomSheetTopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return           Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),

        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
            color: Theme.of(context).textTheme.headlineLarge?.color?.withAlpha(20),
          ),
        ),

        GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Container(
            height: 20,
            width: 20,
            padding: EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
            decoration: BoxDecoration(
                color: Theme.of(context).textTheme.headlineLarge?.color?.withAlpha(100),
                shape: BoxShape.circle
            ),
            child: Icon(Icons.close, size: 15, color: Theme.of(context).cardColor ),

          ),
        ),
      ],
    );
  }
}
