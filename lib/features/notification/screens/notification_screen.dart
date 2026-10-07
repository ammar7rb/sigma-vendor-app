import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_inbox_screen.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_loader_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/widgets/auction_notification_item_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuctionEnabled = false;
  TabController? _tabController;
  final ScrollController _auctionScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isAuctionEnabled = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.isAuctionFeatureEnabled ==
        true;
    if (_isAuctionEnabled) {
      _tabController = TabController(length: 2, vsync: this);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nc = Provider.of<NotificationController>(context, listen: false);
      if (_isAuctionEnabled) nc.getAuctionNotificationList(1);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _auctionScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('notification', context)),
      body: _isAuctionEnabled
          ? Column(children: [
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).hintColor,
                dividerColor: Colors.transparent,
                labelStyle: titilliumRegular.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Dimensions.fontSizeDefault,
                ),
                tabs: [
                  Tab(text: getTranslated('general', context) ?? 'General'),
                  Tab(text: getTranslated('auction', context) ?? 'Auction'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController!,
                  children: [_generalTab(), _auctionTab()],
                ),
              ),
            ])
          : _generalTab(),
    );
  }

  Widget _generalTab() => const VendorInboxScreen(embedded: true);

  Widget _auctionTab() {
    return Consumer<NotificationController>(
      builder: (context, nc, _) {
        if (nc.isAuctionNotificationLoading) return const CustomLoaderWidget();

        final model = nc.auctionNotificationModel;
        if (model == null || (model.notifications?.isEmpty ?? true)) {
          return const Center(child: NoDataScreen());
        }

        return SingleChildScrollView(
          controller: _auctionScrollController,
          child: PaginatedListViewWidget(
            scrollController: _auctionScrollController,
            totalSize: model.totalSize,
            offset: model.offset,
            onPaginate: (int? offset) async {
              await nc.getAuctionNotificationList(offset!);
            },
            itemView: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: model.notifications!.length,
              itemBuilder: (_, i) => AuctionNotificationItemWidget(
                item: model.notifications![i],
                index: i,
                allItems: model.notifications!,
              ),
            ),
          ),
        );
      },
    );
  }
}
