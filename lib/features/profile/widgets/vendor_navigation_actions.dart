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
      builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (final key in ['messages', 'notifications'])
              IconButton(
                  tooltip: getTranslated(
                      key == 'messages'
                          ? 'administration_messages'
                          : 'notification',
                      context),
                  icon: Badge(
                      isLabelVisible: VendorWorkspace.instance.counts[key]! > 0,
                      backgroundColor: key == 'messages'
                          ? AppDesign.success
                          : AppDesign.danger,
                      label: Text('+${VendorWorkspace.instance.counts[key]}'),
                      child: Icon(
                          key == 'messages'
                              ? Icons.mail_outline
                              : Icons.notifications_outlined,
                          size: 20)),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              VendorInboxScreen(messages: key == 'messages')))),
            IconButton(
                tooltip: getTranslated('add_product', context),
                icon: const Icon(Icons.add_box_outlined,
                    color: AppDesign.primary),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AddProductTabView(fromHome: false)))),
          ]));
}

class VendorAddProductAction extends StatelessWidget {
 const VendorAddProductAction({super.key});
 @override Widget build(BuildContext context)=>IconButton(tooltip:getTranslated('add_product',context),icon:const Icon(Icons.add_box_outlined,color:AppDesign.primary),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AddProductTabView(fromHome:false))));
}
