import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mosque_donation_app/utils/constants.dart';
import 'package:mosque_donation_app/models/category_model.dart';
import 'package:mosque_donation_app/models/post_donation_info_model.dart';
import 'package:mosque_donation_app/providers/main_provider.dart';
import 'package:mosque_donation_app/screens/donator_info_screen.dart';
import 'package:mosque_donation_app/screens/enter_payment_screen.dart';
import 'package:mosque_donation_app/utils/app_utils.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String selectedCategoryId = "";
  List<String> items = [
    AppUtils.slider1,
    AppUtils.slider2,
    AppUtils.slider3,
  ];

  List<ModelCategories> categoriesList = [], activeCategoriesList = [];
  bool useMobileLayout = false;
  _getCategories() async {
    categoriesList = [];
    Constants.checkInternetConnection().then((value) async {
      if (value == true) {
        var provider = Provider.of<MainProviderClass>(context, listen: false);
        await provider.getCategoriesResponse();
        var body = jsonDecode(provider.mResponse.body);
        if (provider.isSuccess) {
          categoriesList = List<ModelCategories>.from(
              body.map((model) => ModelCategories.fromJson(model)));
          for (var category in categoriesList) {
            if (category.isActive == true) {
              activeCategoriesList.add(category);
            }
          }
        } else {
          String message = (body["detail"]).toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.black, content: Text(message)),
          );
        }
      } else {
        String message = "No Network Connectivity";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.black, content: Text(message)),
        );
      }
    });
  }

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = shortestSide < 600;
    return Scaffold(
      body: Consumer<MainProviderClass>(builder: (thisContext, data, child) {
        return ModalProgressHUD(
          inAsyncCall: data.loading,
          color: Colors.transparent,
          progressIndicator: const CircularProgressIndicator(
            color: Colors.white,
          ),
          child:
          useMobileLayout ?
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(AppUtils.bgHome), fit: BoxFit.cover),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kHomeBgGradientTopColor, kHomeBgGradientBottomColor],
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.w)),
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
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            fontSize: 4.w))
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: orientation == Orientation.portrait
                              ? MediaQuery.of(context).size.height * 0.3
                              : MediaQuery.of(context).size.height * 0.78,
                          child: Stack(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  viewportFraction: 1,
                                  aspectRatio: 2.25,
                                  autoPlay: true,
                                ),
                                items: items
                                    .map((item) =>
                                    Image.asset(item, fit: BoxFit.cover))
                                    .toList(),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("Choose a Donation Category",
                                        style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 4.75.w)),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    Text(
                                        "Select a category to proceed with your donation",
                                        style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 2.5.w)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        SizedBox(
                          height: (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 1),
                          child: GridView.builder(
                            itemCount: activeCategoriesList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 7.w),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1,
                                crossAxisSpacing: MediaQuery.of(context).size.width * 0.12,
                                mainAxisSpacing: 4.h,
                                crossAxisCount:
                                (orientation == Orientation.portrait)
                                    ? 2
                                    : 3),
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  selectedCategoryId = activeCategoriesList[index].sId ?? "";
                                  showGiftAidDialog();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          getGradientTopColor(index),
                                          getGradientBottomColor(index),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                          Colors.black.withOpacity(0.2),
                                          spreadRadius: 12,
                                          blurRadius: 20,
                                          offset: const Offset(0,
                                              7), // changes position of shadow
                                        ),
                                      ],
                                      borderRadius:
                                      BorderRadius.circular(4.w)),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      activeCategoriesList[index]
                                          .image
                                          ?.isEmpty ?? false
                                          ? Image.asset(
                                        AppUtils.masjid,
                                        width: 6.w,
                                      )
                                          : Image.network(
                                          activeCategoriesList[index]
                                              .image ??
                                              ""),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      Text(
                                          activeCategoriesList[index].name ??
                                              "",
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 3.5.w)),
                                      Text(
                                          activeCategoriesList[index]
                                              .description ??
                                              "",
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              color: Colors.white
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 1.9.w))
                                    ],
                                  ),
                                ),
                              );
                              // Container(
                              //   decoration: BoxDecoration(
                              //       gradient: const LinearGradient(
                              //         begin: Alignment.topCenter,
                              //         end: Alignment.bottomCenter,
                              //         colors: [
                              //           kYellowGradientTopColor,
                              //           kYellowGradientBottomColor
                              //         ],
                              //       ),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.2),
                              //           spreadRadius: 12,
                              //           blurRadius: 20,
                              //           offset: const Offset(
                              //               0, 7), // changes position of shadow
                              //         ),
                              //       ],
                              //       borderRadius: BorderRadius.circular(4.w)),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Image.asset(
                              //         AppUtils.madrisa,
                              //         width: 15.w,
                              //       ),
                              //       SizedBox(
                              //         height: 2.h,
                              //       ),
                              //       Text("Madrisa",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 3.w)),
                              //       Text("Donate your charity in Madrisa",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white.withOpacity(0.68),
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 1.75.w))
                              //     ],
                              //   ),
                              // ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //       gradient: const LinearGradient(
                              //         begin: Alignment.topCenter,
                              //         end: Alignment.bottomCenter,
                              //         colors: [
                              //           kSeaBlueGradientTopColor,
                              //           kSeaBlueGradientBottomColor
                              //         ],
                              //       ),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.2),
                              //           spreadRadius: 12,
                              //           blurRadius: 20,
                              //           offset: const Offset(
                              //               0, 7), // changes position of shadow
                              //         ),
                              //       ],
                              //       borderRadius: BorderRadius.circular(4.w)),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Image.asset(
                              //         AppUtils.welfare,
                              //         width: 15.w,
                              //       ),
                              //       SizedBox(
                              //         height: 2.h,
                              //       ),
                              //       Text("Welfare",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 3.w)),
                              //       Text("Donate your charity in Welfare",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white.withOpacity(0.68),
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 1.75.w))
                              //     ],
                              //   ),
                              // ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //       gradient: const LinearGradient(
                              //         begin: Alignment.topCenter,
                              //         end: Alignment.bottomCenter,
                              //         colors: [
                              //           kGreenGradientTopColor,
                              //           kGreenGradientBottomColor
                              //         ],
                              //       ),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.2),
                              //           spreadRadius: 12,
                              //           blurRadius: 20,
                              //           offset: const Offset(
                              //               0, 7), // changes position of shadow
                              //         ),
                              //       ],
                              //       borderRadius: BorderRadius.circular(4.w)),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Image.asset(
                              //         AppUtils.education,
                              //         width: 15.w,
                              //       ),
                              //       SizedBox(
                              //         height: 2.h,
                              //       ),
                              //       Text("Education",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 3.w)),
                              //       Text("Donate your charity in Education",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white.withOpacity(0.68),
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 1.75.w))
                              //     ],
                              //   ),
                              // ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppUtils.getBrandingWidget()
              ],
            ),
          )
         :
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(AppUtils.bgHome), fit: BoxFit.cover),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kHomeBgGradientTopColor, kHomeBgGradientBottomColor],
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.w)),
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
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            fontSize: 4.w))
                  ],
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: orientation == Orientation.portrait
                              ? MediaQuery.of(context).size.height * 0.38
                              : MediaQuery.of(context).size.height * 0.78,
                          child: Stack(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  viewportFraction: 1,
                                  aspectRatio: 2.25,
                                  autoPlay: true,
                                ),
                                items: items
                                    .map((item) =>
                                        Image.asset(item, fit: BoxFit.cover))
                                    .toList(),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("Choose a Donation Category",
                                        style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 4.75.w)),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    Text(
                                        "Select a category to proceed with your donation",
                                        style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 2.5.w)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        SizedBox(
                          height: (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.height * 0.5
                              : MediaQuery.of(context).size.height * 1),
                          child: GridView.builder(
                            itemCount: activeCategoriesList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 7.w),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1.25,
                                    crossAxisSpacing: MediaQuery.of(context).size.width * 0.12,
                                    mainAxisSpacing: 4.h,
                                    crossAxisCount:
                                        (orientation == Orientation.portrait)
                                            ? 2
                                            : 3),
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  selectedCategoryId = activeCategoriesList[index].sId ?? "";
                                  showGiftAidDialog();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          getGradientTopColor(index),
                                          getGradientBottomColor(index),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.2),
                                          spreadRadius: 12,
                                          blurRadius: 20,
                                          offset: const Offset(0,
                                              7), // changes position of shadow
                                        ),
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(4.w)),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      activeCategoriesList[index]
                                              .image
                                              ?.isEmpty ?? false
                                          ? Image.asset(
                                              AppUtils.masjid,
                                              width: 15.w,
                                            )
                                          : Image.network(
                                              activeCategoriesList[index]
                                                      .image ??
                                                  ""),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                          activeCategoriesList[index].name ??
                                              "",
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 3.w)),
                                      Text(
                                          activeCategoriesList[index]
                                                  .description ??
                                              "",
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              color: Colors.white
                                                  .withOpacity(0.36),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 1.75.w))
                                    ],
                                  ),
                                ),
                              );
                              // Container(
                              //   decoration: BoxDecoration(
                              //       gradient: const LinearGradient(
                              //         begin: Alignment.topCenter,
                              //         end: Alignment.bottomCenter,
                              //         colors: [
                              //           kYellowGradientTopColor,
                              //           kYellowGradientBottomColor
                              //         ],
                              //       ),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.2),
                              //           spreadRadius: 12,
                              //           blurRadius: 20,
                              //           offset: const Offset(
                              //               0, 7), // changes position of shadow
                              //         ),
                              //       ],
                              //       borderRadius: BorderRadius.circular(4.w)),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Image.asset(
                              //         AppUtils.madrisa,
                              //         width: 15.w,
                              //       ),
                              //       SizedBox(
                              //         height: 2.h,
                              //       ),
                              //       Text("Madrisa",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 3.w)),
                              //       Text("Donate your charity in Madrisa",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white.withOpacity(0.68),
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 1.75.w))
                              //     ],
                              //   ),
                              // ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //       gradient: const LinearGradient(
                              //         begin: Alignment.topCenter,
                              //         end: Alignment.bottomCenter,
                              //         colors: [
                              //           kSeaBlueGradientTopColor,
                              //           kSeaBlueGradientBottomColor
                              //         ],
                              //       ),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.2),
                              //           spreadRadius: 12,
                              //           blurRadius: 20,
                              //           offset: const Offset(
                              //               0, 7), // changes position of shadow
                              //         ),
                              //       ],
                              //       borderRadius: BorderRadius.circular(4.w)),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Image.asset(
                              //         AppUtils.welfare,
                              //         width: 15.w,
                              //       ),
                              //       SizedBox(
                              //         height: 2.h,
                              //       ),
                              //       Text("Welfare",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 3.w)),
                              //       Text("Donate your charity in Welfare",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white.withOpacity(0.68),
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 1.75.w))
                              //     ],
                              //   ),
                              // ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //       gradient: const LinearGradient(
                              //         begin: Alignment.topCenter,
                              //         end: Alignment.bottomCenter,
                              //         colors: [
                              //           kGreenGradientTopColor,
                              //           kGreenGradientBottomColor
                              //         ],
                              //       ),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.2),
                              //           spreadRadius: 12,
                              //           blurRadius: 20,
                              //           offset: const Offset(
                              //               0, 7), // changes position of shadow
                              //         ),
                              //       ],
                              //       borderRadius: BorderRadius.circular(4.w)),
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Image.asset(
                              //         AppUtils.education,
                              //         width: 15.w,
                              //       ),
                              //       SizedBox(
                              //         height: 2.h,
                              //       ),
                              //       Text("Education",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 3.w)),
                              //       Text("Donate your charity in Education",
                              //           style: TextStyle(
                              //               fontFamily: kFontFamily,
                              //               color: Colors.white.withOpacity(0.68),
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 1.75.w))
                              //     ],
                              //   ),
                              // ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppUtils.getBrandingWidget()
              ],
            ),
          ),
        );
      }),
    );
  }

  Future showGiftAidDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return
            useMobileLayout ?
            (  MediaQuery.of(context).orientation == Orientation.portrait
                ? Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.5.w))),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(2.5.w),
                                  topRight: Radius.circular(2.5.w)),
                              child: Image.asset(
                                AppUtils.giftAidHeader,
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height *
                                    0.22,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(2.w),
                                  child: Icon(
                                    Icons.close_outlined,
                                    color: Colors.white,
                                    size: 4.w,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            "Should Masjid e Aqsa claim Gift Aid on this donation?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 4.w,
                                fontWeight: FontWeight.w600,
                                fontFamily: kFontFamily),
                          ),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            "UK taxpayers can increase their gift by 25% at no extra cost!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 2.w,
                                fontWeight: FontWeight.w500,
                                fontFamily: kFontFamily),
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            "${AppUtils.currency(context).currencySymbol}1 ~ ${AppUtils.currency(context).currencySymbol}1.25",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 2.5.w,
                                fontWeight: FontWeight.w500,
                                fontFamily: kFontFamily),
                          ),
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 7.w),
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DonatorInfoScreen(ukTaxPayer: true, categoryId: selectedCategoryId,)));
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                  )),
                              backgroundColor:
                              WidgetStateProperty.all(kPrimaryColor),
                            ),
                            child: Text(
                              'YES',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 3.w,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: kFontFamily),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 7.w),
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: () {
                              ModelPostDonationInfo modelPostDonationInfo = ModelPostDonationInfo();
                              modelPostDonationInfo.categoryId = selectedCategoryId;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EnterPaymentScreen(modelPostDonationInfo: modelPostDonationInfo)));
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                    side: BorderSide(
                                        color: kPrimaryColor, width: 0.1.w),
                                  )),
                              backgroundColor:
                              WidgetStateProperty.all(Colors.white),
                            ),
                            child: Text(
                              'NO',
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 3.w,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: kFontFamily),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                      ],
                    ),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.13,
                          ),
                          child: Image.asset(
                            AppUtils.gift,
                            width: MediaQuery.of(context).size.width * 0.3,
                          ),
                        )),
                  ],
                ),
              ),
            )
                : Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.5.w))),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(2.5.w),
                                  topRight: Radius.circular(2.5.w)),
                              child: Image.asset(
                                AppUtils.giftAidHeader,
                                fit: BoxFit.cover,
                                width:
                                MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.height *
                                    0.22,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(2.w),
                                  child: Icon(
                                    Icons.close_outlined,
                                    color: Colors.white,
                                    size: 4.w,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.12,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            "Should Masjid e Aqsa claim Gift Aid on this donation?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 3.w,
                                fontWeight: FontWeight.w600,
                                fontFamily: kFontFamily),
                          ),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            "UK taxpayers can increase their gift by 25% at no extra cost!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 1.75.w,
                                fontWeight: FontWeight.w500,
                                fontFamily: kFontFamily),
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            "${AppUtils.currency(context).currencySymbol}1 ~ ${AppUtils.currency(context).currencySymbol}1.25",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 2.5.w,
                                fontWeight: FontWeight.w500,
                                fontFamily: kFontFamily),
                          ),
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 7.w),
                          height: 8.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DonatorInfoScreen(ukTaxPayer: true, categoryId: selectedCategoryId,)));
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                  )),
                              backgroundColor:
                              WidgetStateProperty.all(kPrimaryColor),
                            ),
                            child: Text(
                              'YES',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 3.w,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: kFontFamily),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 7.w),
                          height: 8.h,
                          child: ElevatedButton(
                            onPressed: () {
                              ModelPostDonationInfo modelPostDonationInfo = ModelPostDonationInfo();
                              modelPostDonationInfo.categoryId = selectedCategoryId;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EnterPaymentScreen(modelPostDonationInfo: modelPostDonationInfo)));
                            },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                    side: BorderSide(
                                        color: kPrimaryColor, width: 0.1.w),
                                  )),
                              backgroundColor:
                              WidgetStateProperty.all(Colors.white),
                            ),
                            child: Text(
                              'NO',
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 3.w,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: kFontFamily),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                      ],
                    ),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                          ),
                          child: Image.asset(
                            AppUtils.gift,
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                        )),
                  ],
                ),
              ),
            ))
                :
            (MediaQuery.of(context).orientation == Orientation.portrait
              ? Dialog(
                  backgroundColor: Colors.white,
                  insetPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2.5.w))),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(2.5.w),
                                      topRight: Radius.circular(2.5.w)),
                                  child: Image.asset(
                                    AppUtils.giftAidHeader,
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height *
                                        0.22,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(2.w),
                                      child: Icon(
                                        Icons.close_outlined,
                                        color: Colors.white,
                                        size: 4.w,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Text(
                                "Should Masjid e Aqsa claim Gift Aid on this donation?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 3.w,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                "UK taxpayers can increase their gift by 25% at no extra cost!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 1.75.w,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text(
                                "${AppUtils.currency(context).currencySymbol}1 ~ ${AppUtils.currency(context).currencySymbol}1.25",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 2.5.w,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                            SizedBox(
                              height: 2.5.h,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 7.w),
                              height: 6.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DonatorInfoScreen(ukTaxPayer: true, categoryId: selectedCategoryId,)));
                                },
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                  )),
                                  backgroundColor:
                                      WidgetStateProperty.all(kPrimaryColor),
                                ),
                                child: Text(
                                  'YES',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 3.w,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: kFontFamily),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 2.5.h,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 7.w),
                              height: 6.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  ModelPostDonationInfo modelPostDonationInfo = ModelPostDonationInfo();
                                  modelPostDonationInfo.categoryId = selectedCategoryId;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EnterPaymentScreen(modelPostDonationInfo: modelPostDonationInfo)));
                                },
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                    side: BorderSide(
                                        color: kPrimaryColor, width: 0.1.w),
                                  )),
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                ),
                                child: Text(
                                  'NO',
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 3.w,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: kFontFamily),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                          ],
                        ),
                        Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.1,
                              ),
                              child: Image.asset(
                                AppUtils.gift,
                                width: MediaQuery.of(context).size.width * 0.3,
                              ),
                            )),
                      ],
                    ),
                  ),
                )
              : Dialog(
                  backgroundColor: Colors.white,
                  insetPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2.5.w))),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(2.5.w),
                                      topRight: Radius.circular(2.5.w)),
                                  child: Image.asset(
                                    AppUtils.giftAidHeader,
                                    fit: BoxFit.cover,
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: MediaQuery.of(context).size.height *
                                        0.22,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(2.w),
                                      child: Icon(
                                        Icons.close_outlined,
                                        color: Colors.white,
                                        size: 4.w,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.12,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Text(
                                "Should Masjid e Aqsa claim Gift Aid on this donation?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 3.w,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                "UK taxpayers can increase their gift by 25% at no extra cost!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 1.75.w,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text(
                                "${AppUtils.currency(context).currencySymbol}1 ~ ${AppUtils.currency(context).currencySymbol}1.25",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 2.5.w,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                            SizedBox(
                              height: 2.5.h,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 7.w),
                              height: 8.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DonatorInfoScreen(ukTaxPayer: true, categoryId: selectedCategoryId,)));
                                },
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                  )),
                                  backgroundColor:
                                      WidgetStateProperty.all(kPrimaryColor),
                                ),
                                child: Text(
                                  'YES',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 3.w,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: kFontFamily),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 2.5.h,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 7.w),
                              height: 8.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  ModelPostDonationInfo modelPostDonationInfo = ModelPostDonationInfo();
                                  modelPostDonationInfo.categoryId = selectedCategoryId;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EnterPaymentScreen(modelPostDonationInfo: modelPostDonationInfo)));
                                },
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                    side: BorderSide(
                                        color: kPrimaryColor, width: 0.1.w),
                                  )),
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                ),
                                child: Text(
                                  'NO',
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 3.w,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: kFontFamily),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                          ],
                        ),
                        Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.08,
                              ),
                              child: Image.asset(
                                AppUtils.gift,
                                width: MediaQuery.of(context).size.width * 0.2,
                              ),
                            )),
                      ],
                    ),
                  ),
                ));
        });
  }

  Color getGradientTopColor(int index) {
    switch (index) {
      case 0:
        return kCategory1GradientTopColor;
      case 1:
        return kCategory2GradientTopColor;
      case 2:
        return kCategory3GradientTopColor;
      case 3:
        return kCategory4GradientTopColor;
      default:
        return kCategory1GradientTopColor;
    }
  }

  Color getGradientBottomColor(int index) {
    switch (index) {
      case 0:
        return kCategory1GradientBottomColor;
      case 1:
        return kCategory2GradientBottomColor;
      case 2:
        return kCategory3GradientBottomColor;
      case 3:
        return kCategory4GradientBottomColor;
      default:
        return kCategory1GradientBottomColor;
    }
  }
}
