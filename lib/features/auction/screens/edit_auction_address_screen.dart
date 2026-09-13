import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_details_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class EditAuctionAddressScreen extends StatefulWidget {
  final int auctionProductId;
  final String addressType;
  final AuctionAddressInfo? currentAddress;

  const EditAuctionAddressScreen({
    super.key,
    required this.auctionProductId,
    required this.addressType,
    this.currentAddress,
  });

  @override
  State<EditAuctionAddressScreen> createState() => _EditAuctionAddressScreenState();
}

class _EditAuctionAddressScreenState extends State<EditAuctionAddressScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _zipController;
  late final TextEditingController _addressController;
  late final TextEditingController _countryController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _zipFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final addr = widget.currentAddress;
    _nameController = TextEditingController(text: addr?.contactPersonName ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _emailController = TextEditingController(text: addr?.email ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _zipController = TextEditingController(text: addr?.zip ?? '');
    _addressController = TextEditingController(text: addr?.address ?? '');
    _countryController = TextEditingController(text: addr?.country ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _cityFocus.dispose();
    _zipFocus.dispose();
    _addressFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  Future<void> _onUpdate() async {
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    final success = await controller.updateAuctionAddress(
      auctionProductId: widget.auctionProductId,
      addressType: widget.addressType,
      contactPersonName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      zip: _zipController.text.trim(),
      address: _addressController.text.trim(),
      country: _countryController.text.trim(),
    );
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getTranslated('address_updated_successfully', context) ?? 'Address updated successfully'),
      ));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('update_address', context)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('contact_person_name', context)!, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('enter_contact_person_name', context),
                    textInputType: TextInputType.name,
                    controller: _nameController,
                    focusNode: _nameFocus,
                    nextNode: _phoneFocus,
                    textInputAction: TextInputAction.next,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('contact_person_number', context)!,
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('enter_contact_person_number', context),
                    textInputType: TextInputType.phone,
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    nextNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('email', context) ?? 'Email',
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('email', context),
                    textInputType: TextInputType.emailAddress,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    nextNode: _cityFocus,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('city', context)!,
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('city', context),
                    textInputType: TextInputType.streetAddress,
                    controller: _cityController,
                    focusNode: _cityFocus,
                    nextNode: _zipFocus,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('zip', context)!,
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('zip', context),
                    controller: _zipController,
                    focusNode: _zipFocus,
                    nextNode: _countryFocus,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('country', context) ?? 'Country',
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('country', context),
                    textInputType: TextInputType.name,
                    controller: _countryController,
                    focusNode: _countryFocus,
                    nextNode: _addressFocus,
                    textInputAction: TextInputAction.next,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('delivery_address', context) ?? 'Address',
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('address_line_02', context),
                    textInputType: TextInputType.streetAddress,
                    controller: _addressController,
                    focusNode: _addressFocus,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
          ),

          Consumer<AuctionProductController>(
            builder: (context, controller, _) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: controller.isAddressUpdating
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButtonWidget(
                          btnTxt: getTranslated('update_address', context),
                          onTap: _onUpdate,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
