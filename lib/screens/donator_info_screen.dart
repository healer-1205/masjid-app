import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mosque_donation_app/utils/constants.dart';
import 'package:mosque_donation_app/models/post_donation_info_model.dart';
import 'package:mosque_donation_app/providers/main_provider.dart';
import 'package:mosque_donation_app/screens/enter_payment_screen.dart';
import 'package:mosque_donation_app/utils/app_utils.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class DonatorInfoScreen extends StatefulWidget {
  final bool ukTaxPayer;
  final String categoryId;

  DonatorInfoScreen(
      {super.key, required this.ukTaxPayer, required this.categoryId});

  @override
  State<DonatorInfoScreen> createState() => _DonatorInfoScreenState();
}

class _DonatorInfoScreenState extends State<DonatorInfoScreen> {
  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var address1Controller = TextEditingController();
  var address2Controller = TextEditingController();
  bool isTaxPayer = false;
  late FocusNode emailFocusNode,
      nameFocusNode,
      address1FocusNode,
      address2FocusNode;

  ModelPostDonationInfo modelPostDonationInfo = ModelPostDonationInfo();

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    address1FocusNode = FocusNode();
    address2FocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    address1FocusNode.dispose();
    address2FocusNode.dispose();

    super.dispose();
  }

  _postDonatorInfo() async {
    Constants.checkInternetConnection().then((value) async {
      if (value == true) {
        var provider = Provider.of<MainProviderClass>(context, listen: false);
        await provider.postDonationInfoResponse(modelPostDonationInfo);
        var body = jsonDecode(provider.mResponse.body);
        if (provider.isSuccess) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => EnterPaymentScreen(modelPostDonationInfo: modelPostDonationInfo,)));
        } else {
          String message = (body["message"]).toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.black,
                content: Text(message)),
          );
        }
      } else {
        String message = "No Network Connectivity";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
              content: Text(message)),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        Navigator.pop(context);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Consumer<MainProviderClass>(builder: (thisContext, data, child) {
            return ModalProgressHUD(
                inAsyncCall: data.loading,
                color: Colors.transparent,
                progressIndicator: const CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Image.asset(AppUtils.watermarkLogo)),
                    Column(children: [
                      SizedBox(
                        height: 6.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.w)),
                              child: Container(
                                  color: Colors.white,
                                  child: Image.asset(
                                    AppUtils.logo,
                                    width: 6.w,
                                  ))),
                          SizedBox(
                            width: 2.w,
                          ),
                          Text('Masjid-e-AQSA',
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 4.w))
                        ],
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Expanded(
                          child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Full Name TextField
                            Text(
                              "Full Name*",
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 3.5.w),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Container(
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: const Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: TextField(
                                  controller: fullNameController,
                                  keyboardType: TextInputType.name,
                                  autofocus: true,
                                  canRequestFocus: true,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 3.w,
                                      fontFamily: kFontFamily),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            //Email TextField
                            Text(
                              "Email*",
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 3.5.w),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Container(
                              height: 5.h,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                color: const Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: TextField(
                                  focusNode: emailFocusNode,
                                  controller: emailController,
                                  enabled: true,
                                  canRequestFocus: true,
                                  onTap: () => emailFocusNode.requestFocus(),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 3.w,
                                      fontFamily: kFontFamily),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            //Address1 TextField
                            Text(
                              "Address1*",
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 3.5.w),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Container(
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: const Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: TextField(
                                  controller: address1Controller,
                                  keyboardType: TextInputType.streetAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 3.w,
                                      fontFamily: kFontFamily),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            //Address2 TextField
                            Text(
                              "Address2 (Optional)",
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 3.5.w),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Container(
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: const Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: TextField(
                                  controller: address2Controller,
                                  keyboardType: TextInputType.streetAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 3.w,
                                      fontFamily: kFontFamily),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            InkWell(
                              onTap: () {
                                if (isTaxPayer) {
                                  setState(() {
                                    isTaxPayer = false;
                                  });
                                } else {
                                  setState(() {
                                    isTaxPayer = true;
                                  });
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: CheckboxListTile(
                                  value: isTaxPayer,
                                  onChanged: (value) {
                                    if (isTaxPayer) {
                                      setState(() {
                                        isTaxPayer = false;
                                      });
                                    } else {
                                      setState(() {
                                        isTaxPayer = true;
                                      });
                                    }
                                  },
                                  title: Text(
                                    "Are you a UK Taxpayer?",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 3.5.w,
                                        fontFamily: kFontFamily),
                                  ),
                                  activeColor: Colors.black,
                                  checkColor: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 7.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (validatePostDonatorInfo()) {
                                    // _postDonatorInfo();
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => EnterPaymentScreen(modelPostDonationInfo: modelPostDonationInfo,)));
                                  }
                                },
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.w),
                                  )),
                                  backgroundColor:
                                      WidgetStateProperty.all(kPrimaryColor),
                                ),
                                child: Text(
                                  'Proceed to Payment',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 4.w,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: kFontFamily),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                      AppUtils.getBrandingWidget(),
                    ]),

                  ],
                ));
          })),
    );
  }

  bool validatePostDonatorInfo() {
    if (fullNameController.text.isEmpty) {
      String message = "Full Name is required";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            content: Text(message)),
      );
      return false;
    } else if (emailController.text.isEmpty) {
      String message = "Email is required";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            content: Text(message)),
      );
      return false;
    } else if (address1Controller.text.isEmpty) {
      String message = "Address is required";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            content: Text(message)),
      );
      return false;
    } else {
      modelPostDonationInfo = ModelPostDonationInfo();
      modelPostDonationInfo.categoryId = widget.categoryId;
      modelPostDonationInfo.giftAid?.fullName =
          fullNameController.text.toString();
      modelPostDonationInfo.giftAid?.email = emailController.text.toString();
      modelPostDonationInfo.giftAid?.address =
          address1Controller.text.toString();
      modelPostDonationInfo.giftAid?.addressLine2 =
          address2Controller.text.toString();
      modelPostDonationInfo.giftAid?.ukTaxPayer = true;
      modelPostDonationInfo.giftAid?.eligible = true;
      return true;
    }
  }
}
