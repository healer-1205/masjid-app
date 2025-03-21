import 'package:flutter/material.dart';
import 'package:mosque_donation_app/models/post_donation_info_model.dart';
import 'package:mosque_donation_app/screens/pos_payment_screen.dart';
import 'package:mosque_donation_app/screens/scan_card_screen.dart';
import 'package:mosque_donation_app/utils/app_utils.dart';
import 'package:sizer/sizer.dart';

class EnterPaymentScreen extends StatefulWidget {
  // final Terminal terminal;
  final ModelPostDonationInfo modelPostDonationInfo;

  const EnterPaymentScreen(
      {super.key,
      /*required this.terminal,*/ required this.modelPostDonationInfo});

  @override
  State<EnterPaymentScreen> createState() => _EnterPaymentScreenState();
}

class _EnterPaymentScreenState extends State<EnterPaymentScreen> {
  var donationCustomAmountController = TextEditingController();
  int donationFixedAmountSelected = 0;

  // bool _isPaymentSuccessful = false;
  // PaymentIntent? _paymentIntent;
  // final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // showSnackBar("Connected");
    // });
  }

  @override
  void dispose() {
    donationCustomAmountController.dispose();
    super.dispose();
  }

  // Future<bool> _createPaymentIntent(Terminal terminal, String amount) async {
  //   showSnackBar("Creating payment intent...");
  //
  //   try {
  //     final paymentIntent =
  //     await terminal.createPaymentIntent(PaymentIntentParameters(
  //       amount:
  //       (double.parse(double.parse(amount).toStringAsFixed(2)) * 100).ceil(),
  //       currency: "GBP",
  //       captureMethod: CaptureMethod.automatic,
  //       paymentMethodTypes: [PaymentMethodType.cardPresent],
  //     ));
  //     _paymentIntent = paymentIntent;
  //     if (_paymentIntent == null) {
  //       showSnackBar('Payment intent is not created!');
  //     }
  //   }
  //   catch(e){
  //     showSnackBar("Payment Intent error: $e");
  //   }
  //
  //   return await _collectPaymentMethod(terminal, _paymentIntent!);
  // }
  //
  // Future<bool> _collectPaymentMethod(
  //     Terminal terminal, PaymentIntent paymentIntent) async {
  //   showSnackBar("Collecting payment method...");
  //
  //   final collectingPaymentMethod = terminal.collectPaymentMethod(
  //     paymentIntent,
  //     skipTipping: true,
  //   );
  //
  //   try {
  //     final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
  //     _paymentIntent = paymentIntentWithPaymentMethod;
  //     await _confirmPaymentIntent(terminal, _paymentIntent!).then((value) {});
  //     return true;
  //   } on TerminalException catch (exception) {
  //     switch (exception.code) {
  //       case TerminalExceptionCode.canceled:
  //         showSnackBar('Collecting Payment method is cancelled! Exception: ${exception.message}');
  //         return false;
  //       default:
  //         rethrow;
  //     }
  //   }
  // }
  //
  // Future<void> _confirmPaymentIntent(
  //     Terminal terminal, PaymentIntent paymentIntent) async {
  //   try {
  //     showSnackBar('Processing!');
  //
  //     final processedPaymentIntent =
  //         await terminal.confirmPaymentIntent(paymentIntent);
  //     _paymentIntent = processedPaymentIntent;
  //     // Show the animation for a while and then reset the state
  //     Future.delayed(const Duration(seconds: 3), () {
  //       setState(() {
  //         _isPaymentSuccessful = false;
  //       });
  //     });
  //     setState(() {
  //       _isPaymentSuccessful = true;
  //     });
  //     showSnackBar('Payment processed!');
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => const PaymentConfirmationScreen(
  //                   paymentStatus: true,
  //                 )));
  //   } catch (e) {
  //     showSnackBar('Inside collect payment exception ${e.toString()}');
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => const PaymentConfirmationScreen(
  //                   paymentStatus: false,
  //                 )));
  //     print(e.toString());
  //   }
  //   // navigate to payment success screen
  // }
  //
  // void _collectPayment() async {
  //   // if (_formKey.currentState!.validate()) {
  //   try {
  //     showSnackBar("Terminal Connected: ${widget.terminal.getConnectedReader()}");
  //     bool status = await _createPaymentIntent(
  //         widget.terminal, donationFixedAmountSelected.toString());
  //       if (status) {
  //         showSnackBar('Payment Collected: $donationFixedAmountSelected');
  //       } else {
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) =>
  //                 const PaymentConfirmationScreen(
  //                   paymentStatus: false,
  //                 )));
  //         showSnackBar('Payment Cancelled');
  //       }
  //     }
  //     catch(e){
  //       showSnackBar("Collect Payment Exception: $e");
  //     }
  //   // }
  // }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

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
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        fontSize: 4.w))
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Make A Donation",
                      style: TextStyle(
                          fontFamily: kFontFamily,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 4.w)),
                  SizedBox(
                    height: 4.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            donationFixedAmountSelected = 5;
                            donationCustomAmountController =
                                TextEditingController(text: '5');
                            /*donationCustomAmountController = TextEditingController(
                                text:
                                '${AppUtils.currency(context).currencySymbol}5');*/
                          });
                        },
                        child: Container(
                          width: 18.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffECAE03),
                                  width:
                                      donationFixedAmountSelected == 5 ? 3 : 0),
                              color: const Color(0xffECAE03)
                                  .withAlpha((0.25 * 255).toInt()),
                              borderRadius: BorderRadius.circular(5.w)),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: AppUtils.currency(context)
                                          .currencySymbol,
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 3.5.w)),
                                  TextSpan(
                                      text: "5",
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 3.5.w)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ), //5 pounds

                      SizedBox(
                        width: 5.w,
                      ),

                      InkWell(
                        onTap: () {
                          setState(() {
                            donationFixedAmountSelected = 10;
                            donationCustomAmountController =
                                TextEditingController(text: '10');
                          });
                        },
                        child: Container(
                          width: 18.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffDC4DDA),
                                  width: donationFixedAmountSelected == 10
                                      ? 3
                                      : 0),
                              color: const Color(0xffDC4DDA)
                                  .withAlpha((0.25 * 255).toInt()),
                              borderRadius: BorderRadius.circular(5.w)),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: AppUtils.currency(context)
                                          .currencySymbol,
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 3.5.w)),
                                  TextSpan(
                                      text: "10",
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 3.5.w)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ), //10 pounds

                      SizedBox(
                        width: 5.w,
                      ),

                      InkWell(
                        onTap: () {
                          setState(() {
                            donationFixedAmountSelected = 15;
                            donationCustomAmountController =
                                TextEditingController(text: '15');
                          });
                        },
                        child: Container(
                          width: 18.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffDA6600),
                                  width: donationFixedAmountSelected == 15
                                      ? 3
                                      : 0),
                              color: const Color(0xffDA6600)
                                  .withAlpha((0.25 * 255).toInt()),
                              borderRadius: BorderRadius.circular(5.w)),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: AppUtils.currency(context)
                                          .currencySymbol,
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 3.5.w)),
                                  TextSpan(
                                      text: "15",
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 3.5.w)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ), //15 pounds

                      SizedBox(
                        width: 5.w,
                      ),

                      InkWell(
                        onTap: () {
                          setState(() {
                            donationFixedAmountSelected = 25;
                            donationCustomAmountController =
                                TextEditingController(text: '25');
                          });
                        },
                        child: Container(
                          width: 18.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                              color: const Color(0xff02A6B4)
                                  .withAlpha((0.25 * 255).toInt()),
                              border: Border.all(
                                  color: const Color(0xff02A6B4),
                                  width: donationFixedAmountSelected == 25
                                      ? 3
                                      : 0),
                              borderRadius: BorderRadius.circular(5.w)),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: AppUtils.currency(context)
                                          .currencySymbol,
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 3.5.w)),
                                  TextSpan(
                                      text: "25",
                                      style: TextStyle(
                                          fontFamily: kFontFamily,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 3.5.w)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ), //25 pounds
                    ],
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Text(
                    "Please Enter your Amount (in ${AppUtils.currency(context).currencySymbol})",
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
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffEBEBEB),
                      borderRadius: BorderRadius.circular(1.5.w),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: TextField(
                        controller: donationCustomAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                        maxLength: 2,
                        textAlign: TextAlign.center,
                        onSubmitted: (value) {
                          donationFixedAmountSelected = int.parse(
                              donationCustomAmountController.text.toString());

                          // _collectPayment();
                        },
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 4.w,
                            fontWeight: FontWeight.w600,
                            fontFamily: kFontFamily),
                        decoration: const InputDecoration(
                            border: InputBorder.none, counter: Text("")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              height: 7.h,
              child: ElevatedButton(
                onPressed: () {
                  if (donationCustomAmountController.text.isNotEmpty) {
                    donationFixedAmountSelected = int.parse(
                        donationCustomAmountController.text.toString());
                  }
//new api functionality

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PosPaymentScreen()));
// old functionality
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ScanPage(
                  //               modelPostDonationInfo:
                  //                   widget.modelPostDonationInfo,
                  //               donationAmount:
                  //                   donationFixedAmountSelected.toString(),
                  //             )));

                  // showTapToPayPopup();
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.w),
                  )),
                  backgroundColor: WidgetStateProperty.all(kPrimaryColor),
                ),
                child: Text(
                  'Donate',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 4.w,
                      fontWeight: FontWeight.w600,
                      fontFamily: kFontFamily),
                ),
              ),
            ),
            AppUtils.getBrandingWidget()
          ]),
        ],
      ),
    );
  }

  Future showTapToPayPopup() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.5.w))),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 3.h,
                    ),
                    Text("Please Tap Your Card",
                        style: TextStyle(
                            fontFamily: kFontFamily,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 4.75.w)),
                    SizedBox(
                      height: 2.h,
                    ),
                    Image.asset(
                      AppUtils.tapCard,
                      height: 40.h,
                    ),
                  ],
                ),
              ));
        });
  }
}
