import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosque_donation_app/utils/constants.dart';
import 'package:mosque_donation_app/screens/home_screen.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var duration = const Duration(seconds: 4);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    var isIpadDevice = MediaQuery.of(context).size.height > 60.h ? true : false;
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            AppUtils.lamp,
                            width: 10.w,
                          ),
                          Image.asset(
                            AppUtils.lamp,
                            width: 10.w,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      AppUtils.splashTop,
                      // width: 15.w,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    AppUtils.splashBottom,
                    height: 28.h,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 17.h),
                child: Hero(
                  tag: "logo",
                  child: Image.asset(
                    AppUtils.logo,
                    width: isIpadDevice
                        ? (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 60.w
                            : 45.h)
                        : (MediaQuery.of(context).orientation ==
                        Orientation.portrait
                        ? 20.w
                        : 20.h),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
