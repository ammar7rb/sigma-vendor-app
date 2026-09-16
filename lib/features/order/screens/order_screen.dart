import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/order_widget.dart';

import '../../../main.dart';

class OrderScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final bool fromHome;
  const OrderScreen(
      {super.key, this.isBacButtonExist = false, this.fromHome = false});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Provider.of<CustomerController>(Get.context!, listen: false)
        .resetCustomerId(isUpdate: false, customerId: -1);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final orders = context.read<OrderController>();
        orders.getOrderList(context, 1, orders.orderType, orders.filterModel);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: CustomAppBarWidget(
        title: getTranslated('my_order', context),
        isBackButtonExist: widget.isBacButtonExist,
        isAction: false,
        isFilter: false,
      ),
      body: Consumer<OrderController>(
        builder: (context, order, child) {
          List<Order>? orderList = [];
          orderList = order.orderModel?.orders;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    OrderTypeButton(
                        text: getTranslated('all', context), index: 0),
                    const SizedBox(width: 8),
                    OrderTypeButton(
                        text: getTranslated(
                            'seller_journey_active_orders', context),
                        index: 10),
                    const SizedBox(width: 8),
                    OrderTypeButton(
                        text: getTranslated(
                                'insurance_pending_orders', context) ??
                            'Insurance pending',
                        index: 9),
                    const SizedBox(width: 8),
                    OrderTypeButton(
                        text: getTranslated('disputed_orders', context) ??
                            'Disputes',
                        index: 11),
                  ]),
                ),
              ),
              order.orderModel != null
                  ? orderList!.isNotEmpty
                      ? Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await order.getOrderList(context, 1,
                                  order.orderType, order.filterModel);
                            },
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: PaginatedListViewWidget(
                                reverse: false,
                                scrollController: scrollController,
                                totalSize: order.orderModel?.totalSize,
                                offset: order.orderModel != null
                                    ? int.parse(
                                        order.orderModel!.offset.toString())
                                    : null,
                                onPaginate: (int? offset) async {
                                  await order.getOrderList(context, offset!,
                                      order.orderType, order.filterModel,
                                      reload: false);
                                },
                                itemView: ListView.builder(
                                  itemCount: orderList.length,
                                  padding: const EdgeInsets.all(0),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return OrderWidget(
                                      orderModel: orderList![index],
                                      index: index,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Expanded(
                          child: NoDataScreen(
                          title: 'no_order_found',
                        ))
                  : const Expanded(child: OrderShimmer()),
            ],
          );
        },
      ),
    );
  }
}

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(0),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          color: Theme.of(context).highlightColor,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
            highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 10,
                    width: 150,
                    color: Theme.of(context).colorScheme.secondaryContainer),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                        child: Container(
                            height: 45,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer)),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Container(
                              height: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                  height: 10,
                                  width: 70,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer),
                              const SizedBox(width: 10),
                              Container(
                                  height: 10,
                                  width: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OrderTypeButton extends StatelessWidget {
  final String? text;
  final int index;

  const OrderTypeButton({super.key, required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Provider.of<OrderController>(context, listen: false)
              .setIndex(context, index);
        },
        child: Consumer<OrderController>(
          builder: (context, order, child) {
            return Container(
              height: 40,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: order.orderTypeIndex == index
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                border: Border.all(
                    color: order.orderTypeIndex == index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(text!,
                  style: order.orderTypeIndex == index
                      ? titilliumBold.copyWith(
                          color: order.orderTypeIndex == index
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context).textTheme.bodyLarge?.color)
                      : robotoRegular.copyWith(
                          color: order.orderTypeIndex == index
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context).textTheme.bodyLarge?.color)),
            );
          },
        ),
      ),
    );
  }
}
