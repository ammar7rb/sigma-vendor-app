import 'package:sixvalley_vendor_app/features/profile/widgets/vendor_navigation_actions.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

import 'package:sixvalley_vendor_app/features/auth/widgets/seller_activation_banner_widget.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/seller_dashboard_overview_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';

import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class HomePageScreen extends StatefulWidget {
  final Function? callback;
  const HomePageScreen({super.key, this.callback});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final ScrollController _scrollController = ScrollController();
  Future<void> _loadData(BuildContext context, bool reload) async {
    await Future.wait([
      Provider.of<ProfileController>(context, listen: false).getSellerInfo(),
      Provider.of<WalletController>(context, listen: false)
          .getSellerDashboardOverview(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _loadData(context, false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData(context, true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              elevation: 0,
              toolbarHeight: 72,
              centerTitle: false,
              titleSpacing: 16,
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              snap: true,
              title: Builder(builder: (context) {
                final dark = Theme.of(context).brightness == Brightness.dark;
                final image = Image.asset(Images.sigmaLogoTransparent,
                    width: 110,
                    height: 48,
                    fit: BoxFit.contain,
                    alignment: AlignmentDirectional.centerStart);
                return dark
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                        child: image)
                    : image;
              }),
              actions: [
                Consumer<LocalizationController>(
                    builder: (context, localization, _) {
                  return PopupMenuButton<int>(
                      tooltip: getTranslated('language', context),
                      onSelected: (index) {
                        final language = AppConstants.languages[index];
                        localization.setLanguage(
                            Locale(
                                language.languageCode!, language.countryCode),
                            index);
                      },
                      itemBuilder: (_) => [
                            for (var index = 0;
                                index < AppConstants.languages.length;
                                index++)
                              PopupMenuItem<int>(
                                  value: index,
                                  child: Row(children: [
                                    Icon(index == localization.languageIndex
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off),
                                    const SizedBox(width: 8),
                                    Text(AppConstants
                                        .languages[index].languageName!)
                                  ]))
                          ],
                      child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).dividerColor)),
                          child: Icon(Icons.translate_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 22)));
                }),
                const VendorNavigationActions(),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const SellerActivationBannerWidget(),
                  const SellerDashboardOverviewWidget(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
