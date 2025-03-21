import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

const kFontFamily = "Poppins";
const Color kPrimaryColor = Color(0xff004B96);
const Color kPrimaryDarkColor = Color(0xff001463);
const Color kRedColor = Color(0xffE00206);
const Color kHomeBgGradientTopColor = Color(0xff1179E0);
const Color kHomeBgGradientBottomColor = Color(0xff00488E);
const Color kCategory1GradientTopColor = Color(0xff59CAF3);
const Color kCategory1GradientBottomColor = Color(0xff154F78);
const Color kCategory2GradientTopColor = Color(0xffF5B606);
const Color kCategory2GradientBottomColor = Color(0xffDFA400);
const Color kCategory3GradientTopColor = Color(0xff02B2C1);
const Color kCategory3GradientBottomColor = Color(0xff008F9B);
const Color kCategory4GradientTopColor = Color(0xff008846);
const Color kCategory4GradientBottomColor = Color(0xff00C164);

class AppUtils {
  static String baseImage = "assets/images/";
  static String logo = "${baseImage}logo.png";
  static String watermarkLogo = "${baseImage}logo_watermark.png";
  static String splashBottom = "${baseImage}img_splash_bottom.png";
  static String splashTop = "${baseImage}img_splash_top.png";
  static String lamp = "${baseImage}img_lamp.png";
  static String bgHome = "${baseImage}img_home_bg.png";
  static String slider1 = "${baseImage}slider_step_1.png";
  static String slider2 = "${baseImage}slider_step_2.png";
  static String slider3 = "${baseImage}slider_step_3.png";
  static String madrisa = "${baseImage}img_madrisa.png";
  static String masjid = "${baseImage}img_masjid.png";
  static String welfare = "${baseImage}img_welfare.png";
  static String education = "${baseImage}img_education.png";
  static String giftAidHeader = "${baseImage}gift_aid_header.png";
  static String gift = "${baseImage}img_gift.png";
  static String tapCard = "${baseImage}tap-card-hUtpX1Jiqu.png";
  static String testingReaderId = "tmr_F9o8ywzZIKzDEq";

  static Widget getBrandingWidget() {
    return Container(
        alignment: Alignment.bottomCenter,
        height: 4.5.h,
        color: kPrimaryDarkColor,
        child: Padding(
          padding: EdgeInsets.only(top: 0.5.h, bottom: 2.h),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Designed & Developed by ',
                    style: TextStyle(
                        fontFamily: kFontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 2.w)),
                TextSpan(
                    text: 'Technicreate Ltd',
                    style: TextStyle(
                        fontFamily: kFontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 2.w)),
                TextSpan(text: ' world!'),
              ],
            ),
          ),
        ));
  }

  static currency(context) {
    Locale locale = Localizations.localeOf(context);
    var format =
        NumberFormat.simpleCurrency(locale: Platform.localeName, name: "GBP");
    return format;
  }
}
