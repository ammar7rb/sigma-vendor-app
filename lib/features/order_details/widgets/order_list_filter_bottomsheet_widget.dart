import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_date_picker_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_drop_down_item_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/category_model.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/customer_search_screen.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/enums/product_type_enum.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/helper/validation_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

enum FilterDateType {
  allTime('all_time'),
  today('today'),
  thisWeek('this_week'),
  thisMonth('this_month'),
  customDate('custom_date');

  final String key;
  const FilterDateType(this.key);

  static FilterDateType fromKey(String key) {
    return FilterDateType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => FilterDateType.allTime,
    );
  }
}

class OrderListFilterBottomSheet extends StatefulWidget {
  const OrderListFilterBottomSheet({super.key});

  @override
  State<OrderListFilterBottomSheet> createState() =>
      _OrderListFilterBottomSheetState();
}

class _OrderListFilterBottomSheetState
    extends State<OrderListFilterBottomSheet> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  final List<String> filterDateType = [
    'all_time',
    'today',
    'this_week',
    'this_month',
    'custom_date'
  ];

  @override
  void initState() {
    final ProductController productController =
        Provider.of<ProductController>(context, listen: false);
    productController.initFilterData(context);
    minPriceController.text =
        (productController.minPrice ?? 0).toStringAsFixed(0);
    maxPriceController.text =
        (productController.maxPrice ?? 0).toStringAsFixed(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if (!isKeyboardOpen) {
      _onCheckPriceRangeValidity(minPriceController, maxPriceController);
    }

    return GestureDetector(
      onTap: () => _onCloseKeyboard(minPriceController, maxPriceController),
      child: Consumer<OrderController>(builder: (context, orderController, _) {
        return Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.95),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusDefault),
              topRight: Radius.circular(Dimensions.radiusDefault),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: Column(children: [
            FilterTitleWidget(),
            Divider(
                height: 1,
                color: Theme.of(context).hintColor.withValues(alpha: .15),
                thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropDownItemWidget(
                              title: 'date_type',
                              borderRadius: Dimensions.radiusDefault,
                              widget: DropdownButtonFormField<String>(
                                initialValue: orderController
                                        .filterModel.filterDateType ??
                                    filterDateType[0],
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                iconSize: 24,
                                elevation: 16,
                                style: robotoRegular,
                                onChanged: (value) {
                                  orderController.filterModel.filterDateType =
                                      value;
                                  setState(() {});
                                },
                                items: filterDateType
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(getTranslated(value, context)!,
                                        style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color)),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (orderController.filterModel.filterDateType ==
                                'custom_date') ...[
                              SizedBox(height: Dimensions.paddingSizeSmall),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: Row(children: [
                                  Expanded(
                                      child: CustomDatePickerWidget(
                                    prefixIcon: false,
                                    fromClearance: true,
                                    fromVacation: true,
                                    iconHintColor: true,
                                    title: getTranslated('from', context),
                                    image: Images.reviewCalenderIcon,
                                    text: orderController.startDateFilter !=
                                            null
                                        ? orderController.dateFormat
                                            .format(orderController
                                                .startDateFilter!)
                                            .toString()
                                        : getTranslated('select_date', context),
                                    selectDate: () => orderController
                                        .selectFilterDate('start', context),
                                    isTitleTransparent: true,
                                  )),
                                  SizedBox(width: Dimensions.paddingSizeSmall),
                                  Expanded(
                                      child: CustomDatePickerWidget(
                                    prefixIcon: false,
                                    fromClearance: true,
                                    fromVacation: true,
                                    iconHintColor: true,
                                    title: getTranslated('to', context),
                                    image: Images.reviewCalenderIcon,
                                    text: orderController.endDateFilter != null
                                        ? orderController.dateFormat
                                            .format(
                                                orderController.endDateFilter!)
                                            .toString()
                                        : getTranslated('select_date', context),
                                    selectDate: () => orderController
                                        .selectFilterDate('end', context),
                                    isTitleTransparent: true,
                                  )),
                                ]),
                              ),
                            ]
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleWidget(
                                title:
                                    getTranslated('show_order_for', context)!),
                            Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                              child: Column(
                                children: [
                                  _CheckboxItem(
                                    isStart: false,
                                    title: getTranslated(
                                        'only_pos_orders', context),
                                    checked: orderController
                                            .filterModel.onlyPosOrder ==
                                        1,
                                    onTap: () {
                                      if (orderController
                                              .filterModel.onlyPosOrder ==
                                          1) {
                                        orderController
                                            .filterModel.onlyPosOrder = 0;
                                      } else {
                                        orderController
                                            .filterModel.onlyPosOrder = 1;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  _CheckboxItem(
                                    isStart: false,
                                    title: getTranslated(
                                        'only_website_orders', context),
                                    checked: orderController
                                            .filterModel.onlyWebsiteOrders ==
                                        1,
                                    onTap: () {
                                      if (orderController
                                              .filterModel.onlyWebsiteOrders ==
                                          1) {
                                        orderController
                                            .filterModel.onlyWebsiteOrders = 0;
                                      } else {
                                        orderController
                                            .filterModel.onlyWebsiteOrders = 1;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleWidget(
                                title: getTranslated(
                                    'edit_order_amount_settlement', context)!),
                            Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                              child: Column(
                                children: [
                                  _CheckboxItem(
                                    isStart: false,
                                    title: getTranslated(
                                        'has_return_amount', context),
                                    checked: orderController
                                            .filterModel.hasReturnAmount ==
                                        1,
                                    onTap: () {
                                      if (orderController
                                              .filterModel.hasReturnAmount ==
                                          1) {
                                        orderController
                                            .filterModel.hasReturnAmount = 0;
                                      } else {
                                        orderController
                                            .filterModel.hasReturnAmount = 1;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  _CheckboxItem(
                                    isStart: false,
                                    title: getTranslated(
                                        'has_due_amount', context),
                                    checked: orderController
                                            .filterModel.hasDueAmount ==
                                        1,
                                    onTap: () {
                                      if (orderController
                                              .filterModel.hasDueAmount ==
                                          1) {
                                        orderController
                                            .filterModel.hasDueAmount = 0;
                                      } else {
                                        orderController
                                            .filterModel.hasDueAmount = 1;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      if (orderController.orderType == 'all') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: Dimensions.paddingSizeMedium),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.05),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleWidget(
                                  title:
                                      getTranslated('order_status', context)!),
                              Container(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                ),
                                child: Column(
                                  children: [
                                    _CheckboxItem(
                                      isStart: false,
                                      title: getTranslated('pending', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('pending'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('pending')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('pending');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('pending');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CheckboxItem(
                                      isStart: false,
                                      title:
                                          getTranslated('confirmed', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('confirmed'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('confirmed')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('confirmed');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('confirmed');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CheckboxItem(
                                      isStart: false,
                                      title:
                                          getTranslated('packaging', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('processing'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('processing')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('processing');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('processing');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CheckboxItem(
                                      isStart: false,
                                      title: getTranslated(
                                          'out_for_delivery', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('out_for_delivery'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('out_for_delivery')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('out_for_delivery');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('out_for_delivery');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CheckboxItem(
                                      isStart: false,
                                      title:
                                          getTranslated('delivered', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('delivered'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('delivered')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('delivered');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('delivered');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CheckboxItem(
                                      isStart: false,
                                      title: getTranslated('canceled', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('canceled'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('canceled')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('canceled');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('canceled');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CheckboxItem(
                                      isStart: false,
                                      title: getTranslated('returned', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('returned'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('returned')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('returned');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('returned');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    _CheckboxItem(
                                      isStart: false,
                                      title: getTranslated('failed', context),
                                      checked: orderController
                                          .filterModel.orderStatus
                                          .contains('failed'),
                                      onTap: () {
                                        if (orderController
                                            .filterModel.orderStatus
                                            .contains('failed')) {
                                          orderController
                                              .filterModel.orderStatus
                                              .remove('failed');
                                        } else {
                                          orderController
                                              .filterModel.orderStatus
                                              .add('failed');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.paddingSizeSmall),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleWidget(
                                title:
                                    getTranslated('payment_status', context)!),
                            Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                              child: Column(
                                children: [
                                  _CheckboxItem(
                                    isStart: false,
                                    title: getTranslated('paid', context),
                                    checked: orderController
                                            .filterModel.paymentStatusPaid ==
                                        1,
                                    onTap: () {
                                      if (orderController
                                              .filterModel.paymentStatusPaid ==
                                          1) {
                                        orderController
                                            .filterModel.paymentStatusPaid = 0;
                                      } else {
                                        orderController
                                            .filterModel.paymentStatusPaid = 1;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                  _CheckboxItem(
                                    isStart: false,
                                    title: getTranslated('unpaid', context),
                                    checked: orderController
                                            .filterModel.paymentStatusUnpaid ==
                                        1,
                                    onTap: () {
                                      if (orderController.filterModel
                                              .paymentStatusUnpaid ==
                                          1) {
                                        orderController.filterModel
                                            .paymentStatusUnpaid = 0;
                                      } else {
                                        orderController.filterModel
                                            .paymentStatusUnpaid = 1;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropDownItemWidget(
                              title: 'customer',
                              widget: Consumer<CartController>(
                                  builder: (context, cartController, _) {
                                return InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const CustomerSearchScreen(
                                                    fromOrderFilter: true))),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.paddingSizeExtraSmall),
                                      child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(Dimensions
                                                      .paddingSizeExtraSmall)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeSmall),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        cartController
                                                                .searchCustomerController
                                                                .text
                                                                .trim()
                                                                .isNotEmpty
                                                            ? cartController
                                                                .searchCustomerController
                                                                .text
                                                            : '${getTranslated('select_customer', context)}',
                                                        style: robotoRegular
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color))),
                                                const Icon(
                                                    Icons.arrow_drop_down_sharp)
                                              ],
                                            ),
                                          )),
                                    ));
                              }),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                    ],
                  ),
                ),
              ),
            ),
            _ButtonWidget(minPriceController, maxPriceController)
          ]),
        );
      }),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String? title;
  final bool checked;
  final bool? isStart;
  final bool? isSubCategory;
  final bool? isSubSubCategory;
  final bool? showDropdown;
  final Function()? onTap;
  const _CheckboxItem(
      {required this.title,
      required this.checked,
      this.onTap,
      this.isStart = false,
      this.showDropdown = false,
      this.isSubCategory = false,
      this.isSubSubCategory = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: isStart!
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            if (isStart!) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: checked
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  color: checked
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
                child: checked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),
            ],
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: isSubCategory!
                        ? Dimensions.paddingSizeDefault
                        : isSubSubCategory!
                            ? Dimensions.paddingSizeButton
                            : 0,
                  ),
                  Flexible(
                    child: Text(
                      title ?? '',
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showDropdown ?? false)
                    Icon(
                      checked
                          ? Icons.keyboard_arrow_down_outlined
                          : Icons.keyboard_arrow_right,
                      size: Dimensions.iconSizeMedium,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                ],
              ),
            ),
            if (!isStart!)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: checked
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  color: checked
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
                child: checked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewMoreWidget extends StatelessWidget {
  final Function() onTap;
  final bool isMore;
  final bool isActive;
  final String count;
  const _ViewMoreWidget(
      {required this.onTap,
      required this.isMore,
      required this.isActive,
      required this.count});

  @override
  Widget build(BuildContext context) {
    return isActive
        ? Center(
            child: TextButton(
            onPressed: () => onTap(),
            child: Text(
                '${getTranslated(isMore ? 'see_less' : 'see_more', context)!}${!isMore ? '($count)' : ''}',
                style: robotoMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                )),
          ))
        : const SizedBox();
  }
}

class TitleWidget extends StatelessWidget {
  final String title;
  const TitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: Dimensions.paddingSizeSmall,
          bottom: Dimensions.paddingSizeExtraSmall),
      child: Text(title,
          style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }
}

class FilterTitleWidget extends StatelessWidget {
  const FilterTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 30),
          Text(getTranslated('filter_data', context)!,
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).hintColor.withValues(alpha: .1)),
              child: const Icon(Icons.close, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;

  const _ButtonWidget(this.minPriceController, this.maxPriceController);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(builder: (context, orderController, _) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[
                    Provider.of<ThemeController>(context).darkTheme
                        ? 800
                        : 200]!,
                spreadRadius: 0.5,
                blurRadius: 0.3)
          ],
        ),
        child:
            Consumer<ProductController>(builder: (ctx, productController, _) {
          return Row(children: [
            Expanded(
                child: CustomButtonWidget(
              isColor: true,
              btnTxt: '${getTranslated('clear_filter', context)}',
              backgroundColor:
                  Theme.of(context).hintColor.withValues(alpha: .1),
              fontColor: Theme.of(context).textTheme.bodyLarge?.color,
              onTap: () async {
                orderController.resetFilters(notify: true);
                await orderController.getOrderList(context, 1,
                    orderController.orderType, orderController.filterModel);
              },
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
                child: CustomButtonWidget(
              isLoading: false,
              btnTxt: '${getTranslated('filter', context)}',
              backgroundColor: (ValidationHelper.canOrderFilter(
                          orderController.filterModel) ||
                      Provider.of<CustomerController>(context, listen: false)
                              .customerId !=
                          0)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor.withValues(alpha: .5),
              onTap: !ValidationHelper.canOrderFilter(
                      orderController.filterModel)
                  ? null
                  : () async {
                      int selectedCustomerId = Provider.of<CustomerController>(
                                  context,
                                  listen: false)
                              .customerId ??
                          -1;
                      orderController.filterModel.selectedCustomerId =
                          selectedCustomerId == -1
                              ? 'all'
                              : selectedCustomerId.toString();
                      if (orderController.filterModel.filterDateType ==
                              'custom_date' &&
                          (orderController.startDateFilter == null ||
                              orderController.endDateFilter == null)) {
                        showCustomSnackBarWidget(
                            getTranslated(
                                "please_select_start_and_end_date", context),
                            context,
                            isError: true);
                      } else if (orderController.filterModel.filterDateType ==
                              'custom_date' &&
                          orderController.endDateFilter!
                              .isBefore(orderController.startDateFilter!)) {
                        showCustomSnackBarWidget(
                            getTranslated(
                                "end_date_should_not_before_start_date",
                                context),
                            context,
                            isError: true);
                      } else {
                        await orderController.getOrderList(
                            context,
                            1,
                            orderController.orderType,
                            orderController.filterModel);
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
            )),
          ]);
        }),
      );
    });
  }

  bool _areCategoriesEqual(
      List<CategoryModel>? categoryList, List<int>? currentCategoryIds) {
    final Set<int> selectedCategoryIds = (categoryList?.isEmpty ?? true)
        ? {}
        : categoryList!
            .where((category) => category.checked == true)
            .map((category) => category.id!)
            .toSet();
    final Set<int> currentCategorySet = currentCategoryIds?.toSet() ?? {};
    return selectedCategoryIds.length == currentCategorySet.length &&
        selectedCategoryIds.containsAll(currentCategorySet);
  }

  bool areSubCategoriesEqual(
    List<CategoryModel>? categoryList,
    List<int>? currentSubIds,
  ) {
    final Set<dynamic> selectedSet = (categoryList ?? [])
        .expand((cat) => cat.subCategories ?? [])
        .where((sub) => sub.checked == true)
        .map((sub) => sub.id!)
        .toSet();

    final Set<int> currentSet = currentSubIds?.toSet() ?? {};

    return selectedSet.length == currentSet.length &&
        selectedSet.containsAll(currentSet);
  }

  bool areSubSubCategoriesEqual(
    List<CategoryModel>? categoryList,
    List<int>? currentSubSubIds,
  ) {
    final Set<dynamic> selectedSet = (categoryList ?? [])
        .expand((cat) => cat.subCategories ?? [])
        .expand((sub) => sub.subSubCategories ?? [])
        .where((subSub) => subSub.checked == true)
        .map((subSub) => subSub.id!)
        .toSet();

    final Set<int> currentSet = currentSubSubIds?.toSet() ?? {};

    return selectedSet.length == currentSet.length &&
        selectedSet.containsAll(currentSet);
  }

  bool _areAuthorsEqual(
      Set<int> authorIds, Set<int> currentAuthorIds, ProductTypeEnum? type) {
    if (type == ProductTypeEnum.physical) return true;
    return authorIds.length == currentAuthorIds.length &&
        authorIds.containsAll(currentAuthorIds);
  }

  bool _arePublishersEqual(Set<int> publisherIds, Set<int> currentPublisherIds,
      ProductTypeEnum? type) {
    if (type == ProductTypeEnum.physical) return true;
    return publisherIds.length == currentPublisherIds.length &&
        publisherIds.containsAll(currentPublisherIds);
  }

  bool _areBrandsEqual(
      Set<int> brandIds, Set<int> currentBrandIds, ProductTypeEnum? type) {
    if (type == ProductTypeEnum.digital) return true;
    return brandIds.length == currentBrandIds.length &&
        brandIds.containsAll(currentBrandIds);
  }
}

void _onCloseKeyboard(
    TextEditingController minController, TextEditingController maxController) {
  _onCheckPriceRangeValidity(minController, maxController);
  FocusManager.instance.primaryFocus?.unfocus();
}

bool _areSortFilterEqual(String productSort, String filterSort) {
  return productSort == filterSort;
}

void _onCheckPriceRangeValidity(
    TextEditingController minController, TextEditingController maxController) {
  final ProductController productController =
      Provider.of<ProductController>(Get.context!, listen: false);
  if (!productController.isPriceRangeValid) {
    final ConfigModel? configModel =
        Provider.of<SplashController>(Get.context!, listen: false).configModel;
    final double systemMaxPrice = PriceConverter.convertAmount(
        configModel?.productMaxPriceRange ?? 1, Get.context!);
    final double tempMin = productController.invalidMinPrice ?? 0;
    final double tempMax = productController.invalidMaxPrice ?? 0;

    if (tempMin > systemMaxPrice || tempMax > systemMaxPrice) {
      productController.setPriceRange(systemMaxPrice, systemMaxPrice);
      minController.text = systemMaxPrice.toString();
      maxController.text = systemMaxPrice.toString();
    } else if (tempMin > tempMax) {
      productController.setPriceRange(tempMin, tempMin);
      minController.text = tempMin.toString();
      maxController.text = tempMin.toString();
    }
  }
}
