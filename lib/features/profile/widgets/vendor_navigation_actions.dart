import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_inbox_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class VendorNavigationActions extends StatelessWidget {
  const VendorNavigationActions({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: VendorWorkspace.instance,
      builder: (context, _) {
        final workspace = VendorWorkspace.instance;
        final entries = [
          (
            'messages',
            Icons.mail_outline,
            'administration_messages',
            workspace.counts['messages']!,
            AppDesign.success
          ),
          (
            'orders',
            Icons.shopping_bag_outlined,
            'order_notifications',
            workspace.counts['order_notifications']!,
            const Color(0xFFEF6C00)
          ),
          (
            'notifications',
            Icons.notifications_outlined,
            'notification',
            workspace.generalNotifications,
            AppDesign.danger
          ),
        ];
        return Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (key, icon, label, count, color) in entries)
            IconButton(
                tooltip: getTranslated(label, context),
                icon: Badge(
                    isLabelVisible: count > 0,
                    backgroundColor: color,
                    label: Text('+$count'),
                    child: Icon(icon, size: 20)),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => VendorInboxScreen(
                            messages: key == 'messages',
                            ordersOnly: key == 'orders')))),
          IconButton(
              tooltip: getTranslated('add_product', context),
              icon:
                  const Icon(Icons.add_box_outlined, color: AppDesign.primary),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const AddProductTabView(fromHome: false)))),
        ]);
      });
}

class VendorAddProductAction extends StatelessWidget {
 const VendorAddProductAction({super.key});
 @override Widget build(BuildContext context)=>IconButton(tooltip:getTranslated('add_product',context),icon:const Icon(Icons.add_box_outlined,color:AppDesign.primary),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AddProductTabView(fromHome:false))));
}
