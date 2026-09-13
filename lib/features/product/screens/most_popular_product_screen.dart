import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product/screens/top_selling_product_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/title_row_widget.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_view_screen.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/top_most_product_card_widget.dart';

class MostPopularProductScreen extends StatelessWidget {
  final bool isMain;
  const MostPopularProductScreen({super.key, this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        Provider.of<ProductController>(context,listen: false).getMostPopularProductList(1, context, 'en');
      },
      child: Consumer<ProductController>(
        builder: (context, productController, child) {
          List<Product>? productList;
          productList = productController.mostPopularProductList;
          return Column(mainAxisSize: MainAxisSize.min, children: [

            isMain ?
            productList != null ?
            Padding(padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault, 0,),
              child: Row(children: [
                Expanded(child: TitleRowWidget(
                  title: '${getTranslated('most_popular_products', context)}',

                  onTap: (productList.length > 4)
                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen(isPopular: true, title: 'most_popular_products')))
                    : null,
                )),
              ]),
            ) : TopSellingProductSectionShimmer(isMain: isMain, isDarkMode : Provider.of<ThemeController>(context).darkTheme) :
            const SizedBox(),

            productList != null ? productList.isNotEmpty ?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 5,
                  childAspectRatio: MediaQuery.of(context).size.width < 400? 1/1.35 :MediaQuery.of(context).size.width < 415? 1/1.23: 1/1.23,
                ),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: isMain && productList.length > 4 ? 4 : productList.length,
                itemBuilder: (context, index) {
                  return TopMostProductWidget(productModel: productList![index], isPopular: true, totalSold: productList[index].totalQtySold.toString());
                },
              ),
            ) : Padding(padding: EdgeInsets.only(top: isMain ? 0.0 : MediaQuery.of(context).size.height / 3),
              child: const NoDataScreen(title: 'no_product_found', color: Colors.white),
            ) : const SizedBox.shrink(),

            productController.isLoading ? Center(child: Padding(
              padding: const EdgeInsets.all(Dimensions.iconSizeExtraSmall),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
            )) : const SizedBox.shrink(),

          ]);
        },
      ),
    );
  }
}
