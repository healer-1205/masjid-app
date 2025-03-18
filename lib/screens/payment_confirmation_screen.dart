import 'package:flutter/material.dart';
import 'package:mosque_donation_app/screens/home_screen.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_utils.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final bool? paymentStatus;

  const PaymentConfirmationScreen({super.key, this.paymentStatus});

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: Image.asset(AppUtils.watermarkLogo)),
          Column(children: [
            SizedBox(
              height: 4.h,
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
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 4.w))
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            widget.paymentStatus == true
                ? Center(
                    child: Text(
                      "Payment Successful\nThank You!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 6.w,
                          fontWeight: FontWeight.w600,
                          fontFamily: kFontFamily),
                    ),
                  )
                : Center(
                    child: Text(
                      "Payment Failed !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kRedColor,
                          fontSize: 6.w,
                          fontWeight: FontWeight.w600,
                          fontFamily: kFontFamily),
                    ),
                  )
          ]),
          Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                      visible: widget.paymentStatus == false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            margin: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 8.h),
                            height: 7.h,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1.5.w),
                                )),
                                backgroundColor:
                                    WidgetStateProperty.all(kPrimaryColor),
                              ),
                              child: Text(
                                'Try Again',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 3.w,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            margin: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 8.h),
                            height: 7.h,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()));
                              },
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1.5.w),
                                )),
                                backgroundColor: WidgetStateProperty.all(
                                    const Color(0xff979797)),
                              ),
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 3.w,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: kFontFamily),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Visibility(
                    visible: widget.paymentStatus == true,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      height: 6.h,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.w),
                          )),
                          backgroundColor:
                              WidgetStateProperty.all(kPrimaryColor),
                        ),
                        child: Text(
                          'Return to Home',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 3.w,
                              fontWeight: FontWeight.w600,
                              fontFamily: kFontFamily),
                        ),
                      ),
                    ),
                  ),
                  AppUtils.getBrandingWidget(),
                ],
              ))
        ],
      ),
    );
  }
}
