import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_menu_screen.dart';
import 'package:sixvalley_vendor_app/features/clearance_sale/screens/clearance_sale_screen.dart';
import 'package:sixvalley_vendor_app/features/restock/screens/restock_list_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/business_pages_model.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/features/vat_management/screens/vat_management_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_bottom_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/coupon/screens/coupon_list_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/screens/seller_promotion_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/nav_bar_screen.dart';
import 'package:sixvalley_vendor_app/features/menu/widgets/sign_out_confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/more/screens/html_view_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/profile_view_screen.dart';
import 'package:sixvalley_vendor_app/features/settings/screens/setting_screen.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/shop_screen.dart';
import 'package:sixvalley_vendor_app/features/bank_info/screens/bank_info_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';

import '../../../main.dart';

class MenuBottomSheetWidget extends StatelessWidget {
  const MenuBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;



    return Consumer<SplashController>(
      builder: (context, splashController, _) {

        // Vendor support, delivery, earnings, and review workflows are managed by admin.
        // Keep their entry points out of the vendor navigation without removing backend support.
        List<CustomBottomSheetWidget> activateMenu = [
          CustomBottomSheetWidget(image: '${Provider.of<ProfileController>(context, listen: false).userInfoModel?.imageFullUrl?.path}',
            isProfile: true, title: getTranslated('profile', context),
            onTap: () => _handleMenuTap(context, const ProfileScreenView())
          ),

          CustomBottomSheetWidget(image: Images.myShop, title: getTranslated('my_shop', context),
            onTap: () => _handleMenuTap(context, const ShopScreen())
          ),

          CustomBottomSheetWidget(image: Images.addProduct, title: getTranslated('add_product', context),
            onTap: () => _openAddProductIfEligible(context),
          ),

          CustomBottomSheetWidget(image: Images.productIconPp, title: getTranslated('products', context),
            onTap: () => _handleMenuTap(context, const ProductListMenuScreen()),
          ),

          CustomBottomSheetWidget(image: Images.couponIcon, title: getTranslated('coupons', context),
            onTap: () => _handleMenuTap(context, const CouponListScreen()),
          ),

          CustomBottomSheetWidget(image: Images.wallet, title: getTranslated('advertising_packages', context),
            onTap: () => _handleMenuTap(context, const SellerPackageScreen()),
          ),

          // Premium visibility is granted only when the current seller package has remaining quota.
          CustomBottomSheetWidget(image: Images.productIconPp, title: getTranslated('promotions', context),
            onTap: () => _handleMenuTap(context, const SellerPromotionScreen()),
          ),

          if(configModel?.posActive == 1 && Provider.of<ProfileController>(context, listen: false).userInfoModel?.posActive == 1)
            CustomBottomSheetWidget(image: Images.pos, title: getTranslated('pos', context),
              onTap: () => _handleMenuTap(context, const NavBarScreen()),
            ),


          CustomBottomSheetWidget(image: Images.settings, title: getTranslated('settings', context),
            onTap: () => _handleMenuTap(context, const SettingsScreen()),
          ),


          CustomBottomSheetWidget(image: Images.restockIcon, title: getTranslated('restock', context),
            onTap: () => _handleMenuTap(context, const RestockListScreen()),
          ),


          CustomBottomSheetWidget(image: Images.clearanceSaleImage, title: getTranslated('clearance_sale', context),
            onTap: () => _handleMenuTap(context, const ClearanceSaleScreen()),
          ),


          CustomBottomSheetWidget(image: Images.reportIcon, title: getTranslated('vat_management', context),
            onTap: () => _handleMenuTap(context, const VatManagementScreen()),
          ),

          if (configModel?.isAuctionFeatureEnabled == true || Provider.of<ProfileController>(context, listen: false).userInfoModel?.showAuctionMenuForVendor == true)
          CustomBottomSheetWidget(image: Images.auctionMenuIcon, title: getTranslated('auctions', context),
            onTap: () => _handleMenuTap(context, const AuctionMenuScreen()),
          ),

          CustomBottomSheetWidget(image: Images.bankingInfo, title: getTranslated('bank_info', context),
            onTap: () => _handleMenuTap(context, const BankInfoScreen()),
          ),


          if(getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages) != null)
          CustomBottomSheetWidget(image: Images.termsAndCondition, title: getTranslated('terms_and_condition', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page: getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages)
            )),
          ),


          if(getPageBySlug('about-us', splashController.defaultBusinessPages) != null)
          CustomBottomSheetWidget(image: Images.aboutUs, title: getTranslated('about_us', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page: getPageBySlug('about-us', splashController.defaultBusinessPages),
            )),
          ),

          if(getPageBySlug('privacy-policy', splashController.defaultBusinessPages) != null)
          CustomBottomSheetWidget(image: Images.privacyPolicy, title: getTranslated('privacy_policy', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page: getPageBySlug('privacy-policy', splashController.defaultBusinessPages),
            )),
          ),


          if(getPageBySlug('refund-policy', splashController.defaultBusinessPages) != null)
            CustomBottomSheetWidget(image: Images.refundPolicy, title: getTranslated('refund_policy', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page:getPageBySlug('refund-policy', splashController.defaultBusinessPages),
            )),
          ),


          if(getPageBySlug('return-policy', splashController.defaultBusinessPages) != null)
            CustomBottomSheetWidget(image: Images.returnPolicy, title: getTranslated('return_policy', context),
              onTap : () => _handleMenuTap(context, HtmlViewScreen(
                page: getPageBySlug('return-policy', splashController.defaultBusinessPages),
              )),
            ),


          if(getPageBySlug('cancellation-policy', splashController.defaultBusinessPages) != null)
            CustomBottomSheetWidget(image: Images.cPolicy, title: getTranslated('cancellation_policy', context),
              onTap : () => _handleMenuTap(context, HtmlViewScreen(
                page: getPageBySlug('cancellation-policy', splashController.defaultBusinessPages),
              )),
            ),


          CustomBottomSheetWidget(image: Images.logOut, title: getTranslated('logout', context),
            onTap: () async {
              Navigator.pop(context); // Close bottom sheet
              Future.microtask(
                await showModalBottomSheet(context: context, builder: (_) => const SignOutConfirmationDialogWidget()),
              );
            }
          ),

          CustomBottomSheetWidget(image: Images.appInfo, title: 'v - ${AppConstants.appVersion}',
              onTap: (){}),

          // CustomBottomSheetWidget(
          //   image: Images.appInfo, title: 'vat',
          //   onTap: () { }
          // ),

        ];

        return Container(decoration: BoxDecoration(
            color: Provider.of<ThemeController>(context).darkTheme
                ? Theme.of(context).highlightColor : Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.only(topLeft:  Radius.circular(25), topRight: Radius.circular(25))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(onTap: ()=> Navigator.pop(context),
                child: Icon(Icons.keyboard_arrow_down_outlined,color: Theme.of(context).hintColor, size: Dimensions.iconSizeLarge,)),

              const SizedBox(height: Dimensions.paddingSizeVeryTiny),
              Consumer<ProfileController>(
                builder: (context, profileProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: activateMenu,
                    ),
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }

  void _handleMenuTap(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close bottom sheet
    Future.microtask(() => Navigator.push(
      Get.context!,
      MaterialPageRoute(builder: (_) => screen),
    ));
  }

  Future<void> _openAddProductIfEligible(BuildContext context) async {
    // The add-product screen verifies account activation. Advertising packages
    // are intentionally not consulted here because publishing is not a paid quota.
    _handleMenuTap(context, const AddProductTabView(fromHome: false));
  }

  BusinessPageModel? getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    BusinessPageModel? pageModel;
    if(pagesList != null && pagesList.isNotEmpty){
      for (var page in pagesList) {
        if(page.slug == slug) {
          pageModel = page;
        }
      }
    }
    return pageModel;
  }

}
