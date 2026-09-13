import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_filter_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/order_list_filter_bottomsheet_widget.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionFilterWidget extends StatefulWidget {
  final int tabIndex;
  final VoidCallback? onApply;

  const AuctionFilterWidget({
    super.key,
    required this.tabIndex,
    this.onApply,
  });

  @override
  State<AuctionFilterWidget> createState() => _AuctionFilterWidgetState();
}

class _AuctionFilterWidgetState extends State<AuctionFilterWidget> {
  late SortBy? _sortBy;
  late Set<ActiveStatus> _selectedActiveStatuses;
  late AuctionClaimStatus? _auctionClaimStatus;
  late Set<Disbursement> _disbursement;
  late Set<AuctionStatus> _selectedAuctionStatuses;
  late DurationFilter? _durationFilter;
  late DateTime? _from;
  late DateTime? _to;
  late Set<int> _selectedBrandIds;
  late Set<int> _selectedCategoryIds;
  bool _brandSeeMore = false;
  bool _categorySeeMore = false;
  late EndingTimeUnit _claimDurationUnit;
  late int _claimDurationMin;
  late int _claimDurationMax;
  late TextEditingController _claimMinController;
  late TextEditingController _claimMaxController;
  late EndingTimeUnit _endDurationUnit;
  late int _endDurationMin;
  late int _endDurationMax;
  late TextEditingController _endMinController;
  late TextEditingController _endMaxController;
  late AuctionTabFilterConfig _config;

  @override
  void initState() {
    super.initState();

    _config = AuctionTabFilterConfig.forTab(widget.tabIndex);

    final String languageCode =
    Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US' ? 'en'
        : Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();

    Provider.of<ProductController>(context, listen: false).getBrandList(context, languageCode);

    final f = Provider.of<AuctionProductController>(context, listen: false).filterParamsForTab(widget.tabIndex);

    _sortBy = f.sortBy;
    _auctionClaimStatus = f.auctionClaimStatus;
    _selectedActiveStatuses = Set.from(f.activeStatuses);
    _disbursement = Set.from(f.disbursement);
    _selectedAuctionStatuses = Set.from(f.selectedAuctionStatuses);
    _durationFilter = f.durationFilter;
    _from = f.from;
    _to = f.to;
    _selectedBrandIds = Set.from(f.selectedBrandIds);
    _selectedCategoryIds = Set.from(f.selectedCategoryIds);
    _claimDurationUnit = f.claimDuration?.unit ?? EndingTimeUnit.minute;
    _claimDurationMin = f.claimDuration?.min ?? 0;
    _claimDurationMax = f.claimDuration?.max ?? _claimDurationUnit.maxRange;
    _claimMinController = TextEditingController(text: '$_claimDurationMin');
    _claimMaxController = TextEditingController(text: '$_claimDurationMax');
    _endDurationUnit = f.endingTime?.unit ?? EndingTimeUnit.minute;
    _endDurationMin = f.endingTime?.min ?? 0;
    _endDurationMax = f.endingTime?.max ?? _endDurationUnit.maxRange;
    _endMinController = TextEditingController(text: '$_endDurationMin');
    _endMaxController = TextEditingController(text: '$_endDurationMax');
  }

  @override
  void dispose() {
    _claimMinController.dispose();
    _claimMaxController.dispose();
    _endMinController.dispose();
    _endMaxController.dispose();
    super.dispose();
  }

  void _onClaimUnitChanged(EndingTimeUnit unit) {
    setState(() {
      _claimDurationUnit = unit;
      _claimDurationMin = 0;
      _claimDurationMax = unit.maxRange;
      _claimMinController.text = '0';
      _claimMaxController.text = '${unit.maxRange}';
    });
  }

  void _onEndUnitChanged(EndingTimeUnit unit) {
    setState(() {
      _endDurationUnit = unit;
      _endDurationMin = 0;
      _endDurationMax = unit.maxRange;
      _endMinController.text = '0';
      _endMaxController.text = '${unit.maxRange}';
    });
  }

  void _syncEndFromControllers() {
    final min = int.tryParse(_endMinController.text) ?? 0;
    final max = int.tryParse(_endMaxController.text) ?? _endDurationUnit.maxRange;
    final clampedMin = min.clamp(0, _endDurationUnit.maxRange);
    final clampedMax = max.clamp(0, _endDurationUnit.maxRange);
    setState(() {
      _endDurationMin = clampedMin <= clampedMax ? clampedMin : 0;
      _endDurationMax = clampedMax >= clampedMin ? clampedMax : _endDurationUnit.maxRange;
    });
  }

  void _syncClaimFromControllers() {
    final min = int.tryParse(_claimMinController.text) ?? 0;
    final max = int.tryParse(_claimMaxController.text) ?? _claimDurationUnit.maxRange;
    final clampedMin = min.clamp(0, _claimDurationUnit.maxRange);
    final clampedMax = max.clamp(0, _claimDurationUnit.maxRange);
    setState(() {
      _claimDurationMin = clampedMin <= clampedMax ? clampedMin : 0;
      _claimDurationMax = clampedMax >= clampedMin ? clampedMax : _claimDurationUnit.maxRange;
    });
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? (_from ?? DateTime.now()) : (_to ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: Theme.of(ctx).primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
          if (_to != null && _to!.isBefore(picked)) _to = null;
        } else {
          _to = picked;
          if (_from != null && _from!.isAfter(picked)) _from = null;
        }
      });
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _reset() {
    setState(() {
      _sortBy = null;
      _selectedActiveStatuses = {};
      _auctionClaimStatus = null;
      _disbursement = {};
      _selectedAuctionStatuses = {};
      _durationFilter = null;
      _from = null;
      _to = null;
      _selectedBrandIds = {};
      _selectedCategoryIds = {};
      _brandSeeMore = false;
      _categorySeeMore = false;
      _claimDurationUnit = EndingTimeUnit.minute;
      _claimDurationMin = 0;
      _claimDurationMax = EndingTimeUnit.minute.maxRange;
      _claimMinController.text = '0';
      _claimMaxController.text = '${EndingTimeUnit.minute.maxRange}';
      _endDurationUnit = EndingTimeUnit.minute;
      _endDurationMin = 0;
      _endDurationMax = EndingTimeUnit.minute.maxRange;
      _endMinController.text = '0';
      _endMaxController.text = '${EndingTimeUnit.minute.maxRange}';
    });
    _apply(isReset: true);
  }

  void _apply({bool isReset = false}) {
    final controller = Provider.of<AuctionProductController>(context, listen: false);

    final AuctionEndingTimeFilter? claimDuration = (!isReset && _config.showClaimStatus)
        ? AuctionEndingTimeFilter(unit: _claimDurationUnit, min: _claimDurationMin, max: _claimDurationMax)
        : null;
    final AuctionEndingTimeFilter? endingTime = (!isReset && _config.showEndingTime)
        ? AuctionEndingTimeFilter(unit: _endDurationUnit, min: _endDurationMin, max: _endDurationMax)
        : null;

    controller.updateFilter(
      widget.tabIndex,
      AuctionFilterParams(
        sortBy: _config.showSorting ? _sortBy : null,
        activeStatuses: _config.showStatus ? _selectedActiveStatuses : {},
        auctionClaimStatus: _config.showClaimStatus ? _auctionClaimStatus : null,
        disbursement: _config.showDisbursement ? _disbursement : {},
        selectedAuctionStatuses: _config.showAuctionStatus ? _selectedAuctionStatuses : {},
        durationFilter: _config.showAuctionDuration ? _durationFilter : null,
        from: _config.showAuctionDuration ? _from : null,
        to: _config.showAuctionDuration ? _to : null,
        claimDuration: claimDuration,
        endingTime: endingTime,
        selectedBrandIds: _config.showBrand ? _selectedBrandIds : {},
        selectedCategoryIds: _config.showCategory ? _selectedCategoryIds : {},
      ),
    );

    Navigator.pop(context);
    widget.onApply?.call();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.92),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          FilterTitleWidget(),
          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    if (_config.showStatus) ...[
                      _SectionContainer(
                        title: getTranslated('statuss', context) ?? 'Status',
                        child: Column(
                          children: ActiveStatus.values.map((s) {
                            final sel = _selectedActiveStatuses.contains(s);
                            return _CheckboxItem(
                              title: getTranslated(s.translationKey, context) ?? s.translationKey,
                              checked: sel,
                              onTap: () => setState(() => sel ? _selectedActiveStatuses.remove(s) : _selectedActiveStatuses.add(s)),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    if (_config.showAuctionDuration) ...[
                      _SectionContainer(
                        title: getTranslated('auction_duration', context) ?? 'Auction Duration',
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownDecoratorWidget(
                              title: getTranslated('duration', context) ?? 'Duration',
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<DurationFilter?>(
                                  value: _durationFilter,
                                  isExpanded: true,
                                  hint: Text(
                                    getTranslated('select_duration', context) ?? 'Select duration',
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                  items: [
                                    DropdownMenuItem<DurationFilter?>(
                                      value: null,
                                      child: Text(getTranslated('none', context) ?? 'None'),
                                    ),
                                    ...DurationFilter.values.map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(getTranslated(d.translationKey, context) ?? d.translationKey),
                                    )),
                                  ],
                                  onChanged: (v) => setState(() {
                                    _durationFilter = v;
                                    if (v != DurationFilter.custom) {_from = null; _to = null;}
                                  }),
                                ),
                              ),
                            ),
                            if (_durationFilter == DurationFilter.custom) ...[
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DatePickerField(
                                      label: getTranslated('from', context) ?? 'From',
                                      date: _from,
                                      formatDate: _formatDate,
                                      onTap: () => _pickDate(isFrom: true),
                                      onClear: () => setState(() => _from = null),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  Expanded(
                                    child: _DatePickerField(
                                      label: getTranslated('to', context) ?? 'To',
                                      date: _to,
                                      formatDate: _formatDate,
                                      onTap: () => _pickDate(isFrom: false),
                                      onClear: () => setState(() => _to = null),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    if (_config.showAuctionStatus) ...[
                      _SectionContainer(
                        title: getTranslated('auction_status', context) ?? 'Auction Status',
                        child: Column(
                          children: AuctionStatus.filterValues.map((s) {
                            final sel = _selectedAuctionStatuses.contains(s);
                            return _CheckboxItem(
                              title: getTranslated(s.translationKey, context) ?? s.translationKey,
                              checked: sel,
                              onTap: () => setState(() => sel ? _selectedAuctionStatuses.remove(s) : _selectedAuctionStatuses.add(s)),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    if (_config.showClaimStatus) ...[
                      _SectionContainer(
                        title: getTranslated('claim_duration', context) ?? 'Claim Duration',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: _TimeField(
                                    label: getTranslated('min', context) ?? 'Min',
                                    controller: _claimMinController,
                                    maxValue: _claimDurationUnit.maxRange,
                                    onChanged: (_) => _syncClaimFromControllers(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12,
                                    left: Dimensions.paddingSizeSmall,
                                    right: Dimensions.paddingSizeSmall,
                                  ),
                                  child: Text('–', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                                ),
                                Expanded(
                                  child: _TimeField(
                                    label: getTranslated('max', context) ?? 'Max',
                                    controller: _claimMaxController,
                                    maxValue: _claimDurationUnit.maxRange,
                                    onChanged: (_) => _syncClaimFromControllers(),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                _UnitPopupButton(
                                  selectedUnit: _claimDurationUnit,
                                  onChanged: _onClaimUnitChanged,
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Theme.of(context).primaryColor,
                                inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                thumbColor: Theme.of(context).primaryColor,
                                overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                trackHeight: 4,
                              ),
                              child: RangeSlider(
                                min: 0,
                                max: _claimDurationUnit.maxRange.toDouble(),
                                values: RangeValues(
                                  _claimDurationMin.toDouble().clamp(0, _claimDurationUnit.maxRange.toDouble()),
                                  _claimDurationMax.toDouble().clamp(0, _claimDurationUnit.maxRange.toDouble()),
                                ),
                                onChanged: (v) => setState(() {
                                  _claimDurationMin = v.start.round();
                                  _claimDurationMax = v.end.round();
                                  _claimMinController.text = '$_claimDurationMin';
                                  _claimMaxController.text = '$_claimDurationMax';
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    if (_config.showEndingTime) ...[
                      _SectionContainer(
                        title: getTranslated('auction_end_time', context) ?? 'Auction End Time',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: _TimeField(
                                    label: getTranslated('min', context) ?? 'Min',
                                    controller: _endMinController,
                                    maxValue: _endDurationUnit.maxRange,
                                    onChanged: (_) => _syncEndFromControllers(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12,
                                    left: Dimensions.paddingSizeSmall,
                                    right: Dimensions.paddingSizeSmall,
                                  ),
                                  child: Text('–', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                                ),
                                Expanded(
                                  child: _TimeField(
                                    label: getTranslated('max', context) ?? 'Max',
                                    controller: _endMaxController,
                                    maxValue: _endDurationUnit.maxRange,
                                    onChanged: (_) => _syncEndFromControllers(),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                _UnitPopupButton(
                                  selectedUnit: _endDurationUnit,
                                  onChanged: _onEndUnitChanged,
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Theme.of(context).primaryColor,
                                inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                thumbColor: Theme.of(context).primaryColor,
                                overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                trackHeight: 4,
                              ),
                              child: RangeSlider(
                                min: 0,
                                max: _endDurationUnit.maxRange.toDouble(),
                                values: RangeValues(
                                  _endDurationMin.toDouble().clamp(0, _endDurationUnit.maxRange.toDouble()),
                                  _endDurationMax.toDouble().clamp(0, _endDurationUnit.maxRange.toDouble()),
                                ),
                                onChanged: (v) => setState(() {
                                  _endDurationMin = v.start.round();
                                  _endDurationMax = v.end.round();
                                  _endMinController.text = '$_endDurationMin';
                                  _endMaxController.text = '$_endDurationMax';
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    if (_config.showDisbursement) ...[
                      _SectionContainer(
                        title: getTranslated('disbursement', context) ?? 'Disbursement',
                        child: Row(
                          children: Disbursement.values.map((s) {
                            final sel = _disbursement.contains(s);
                            return Expanded(
                              child: _CheckboxItem(
                                isStart: true,
                                title: getTranslated(s.translationKey, context) ?? s.translationKey,
                                checked: sel,
                                onTap: () => setState(() => sel ? _disbursement.remove(s) : _disbursement.add(s),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    if (_config.showSorting) ...[
                      _SectionContainer(
                        title: getTranslated('sorting', context) ?? 'Sort By',
                        child: RadioGroup<SortBy>(
                          groupValue: _sortBy,
                          onChanged: (v) => setState(() => _sortBy = v),
                          child: Column(
                            children: _sortOptionsForTab(widget.tabIndex).map((option) => RadioListTile<SortBy>(
                              contentPadding: EdgeInsets.zero,
                              visualDensity:
                              const VisualDensity(horizontal: -4, vertical: -4),
                              activeColor: Theme.of(context).primaryColor,
                              value: option,
                              title: Text(getTranslated(option.translationKey, context) ?? option.translationKey,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    if (_config.showBrand)
                      Consumer<ProductController>(
                        builder: (context, productController, _) {
                          final brands = productController.brandList ?? [];
                          if (brands.isEmpty) return const SizedBox.shrink();
                          final visible =
                          _brandSeeMore ? brands : brands.take(4).toList();
                          return _SectionContainer(
                            title: getTranslated('brand', context) ?? 'Brand',
                            child: Column(
                              children: [
                                _CheckboxItem(
                                  title: getTranslated('all', context),
                                  checked: _selectedBrandIds.isNotEmpty && _selectedBrandIds.length == brands.length,
                                  onTap: () => setState(() {
                                    if (_selectedBrandIds.length == brands.length) {
                                      _selectedBrandIds.clear();
                                    } else {
                                      _selectedBrandIds = brands.where((b) => b.id != null).map((b) => b.id!).toSet();
                                    }
                                  }),
                                ),
                                ...visible.map((brand) {
                                  if (brand.id == null) return const SizedBox.shrink();
                                  final sel = _selectedBrandIds.contains(brand.id);
                                  return _CheckboxItem(
                                    title: brand.name,
                                    checked: sel,
                                    onTap: () => setState(() => sel ? _selectedBrandIds.remove(brand.id) : _selectedBrandIds.add(brand.id!)),
                                  );
                                }),
                                if (brands.length > 4)
                                  _ViewMoreWidget(
                                    count: (brands.length - 4).toString(),
                                    isMore: _brandSeeMore,
                                    onTap: () => setState(() => _brandSeeMore = !_brandSeeMore),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    if (_config.showCategory)
                      Consumer<CategoryController>(
                        builder: (context, categoryController, _) {
                          final cats = categoryController.categoryList ?? [];
                          if (cats.isEmpty) return const SizedBox.shrink();
                          final visible = _categorySeeMore ? cats : cats.take(4).toList();
                          return _SectionContainer(
                            title: getTranslated('category', context) ?? 'Category',
                            child: Column(
                              children: [
                                _CheckboxItem(
                                  title: getTranslated('all', context),
                                  checked: _selectedCategoryIds.isNotEmpty && _selectedCategoryIds.length == cats.length,
                                  onTap: () => setState(() {
                                    if (_selectedCategoryIds.length == cats.length) {
                                      _selectedCategoryIds.clear();
                                    } else {
                                      _selectedCategoryIds = cats.where((c) => c.id != null).map((c) => c.id!).toSet();
                                    }
                                  }),
                                ),
                                ...visible.map((cat) {
                                  if (cat.id == null) return const SizedBox.shrink();
                                  final sel = _selectedCategoryIds.contains(cat.id);
                                  return _CheckboxItem(
                                    title: cat.name,
                                    checked: sel,
                                    onTap: () => setState(() => sel ? _selectedCategoryIds.remove(cat.id) : _selectedCategoryIds.add(cat.id!)),
                                  );
                                }),
                                if (cats.length > 4)
                                  _ViewMoreWidget(
                                    count: (cats.length - 4).toString(),
                                    isMore: _categorySeeMore,
                                    onTap: () => setState(() => _categorySeeMore = !_categorySeeMore),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault, 0,
              Dimensions.paddingSizeDefault,
              MediaQuery.of(context).padding.bottom + Dimensions.paddingSizeDefault,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    btnTxt: getTranslated('reset', context) ?? 'Reset',
                    isColor: true,
                    backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.15),
                    fontColor: Theme.of(context).textTheme.bodyLarge?.color,
                    onTap: _reset,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: CustomButtonWidget(
                    btnTxt: getTranslated('apply_filter', context) ?? 'Apply Filter',
                    onTap: _apply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<SortBy> _sortOptionsForTab(int tabIndex) {
    if (tabIndex == 8) {
      return const [SortBy.noBidsYet, SortBy.notClaimed];
    }
    return SortBy.values;
  }
}

class _SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleWidget(title: title),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: child,
          ),
        ],
      ),
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

  const _CheckboxItem({
    required this.title,
    required this.checked,
    this.onTap,
    this.isStart = false,
    this.showDropdown = false,
    this.isSubCategory = false,
    this.isSubSubCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment:
          isStart! ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
          children: [
            if (isStart!) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: checked ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  color: checked ? Theme.of(context).primaryColor : Colors.transparent,
                ),
                child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),
            ],
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: isSubCategory! ? Dimensions.paddingSizeDefault : isSubSubCategory! ? Dimensions.paddingSizeButton : 0,
                  ),
                  Flexible(
                    child: Text(title ?? '',
                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showDropdown ?? false)
                    Icon(checked ? Icons.keyboard_arrow_down_outlined : Icons.keyboard_arrow_right,
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
                    color: checked ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  color: checked ? Theme.of(context).primaryColor : Colors.transparent,
                ),
                child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewMoreWidget extends StatelessWidget {
  final String count;
  final bool isMore;
  final VoidCallback onTap;

  const _ViewMoreWidget({
    required this.count,
    required this.isMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Text('${getTranslated(isMore ? 'see_less' : 'see_more', context) ?? (isMore ? 'See Less' : 'See More')}${!isMore ? ' ($count)' : ''}',
          style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxValue;
  final ValueChanged<String> onChanged;

  const _TimeField({
    required this.label,
    required this.controller,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxValueFormatter(maxValue),
            ],
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                borderSide: BorderSide(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.35),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                borderSide: BorderSide(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.35),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.formatDate,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
              border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: Dimensions.iconSizeMedium,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(date != null ? formatDate(date!) : '–',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: date != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                    ),
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitPopupButton extends StatelessWidget {
  final EndingTimeUnit selectedUnit;
  final ValueChanged<EndingTimeUnit> onChanged;

  const _UnitPopupButton({
    required this.selectedUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<EndingTimeUnit>(
      initialValue: selectedUnit,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      itemBuilder: (context) => EndingTimeUnit.values.map((unit) {
        final isSelected = unit == selectedUnit;
        return PopupMenuItem<EndingTimeUnit>(
          value: unit,
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor)
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                getTranslated(unit.translationKey, context) ?? unit.translationKey,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getTranslated(selectedUnit.translationKey, context) ?? selectedUnit.translationKey,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final int maxValue;
  _MaxValueFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final val = int.tryParse(newValue.text);
    if (val == null || val > maxValue) return oldValue;
    return newValue;
  }
}