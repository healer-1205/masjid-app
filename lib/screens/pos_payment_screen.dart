import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_donation_app/models/pos_connect/payment_intent.dart';
import 'package:mosque_donation_app/utils/app_utils.dart';
import 'package:sizer/sizer.dart';

class PosPaymentScreen extends StatefulWidget {
  const PosPaymentScreen({super.key});

  @override
  State<PosPaymentScreen> createState() => _PosPaymentScreenState();
}

class _PosPaymentScreenState extends State<PosPaymentScreen> {
  Timer? timer;
  bool isPaymentprocessDone = false;
  @override
  void initState() {
    super.initState();
    createPaymentIntent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.black,
              size: 6.w,
            ),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Visibility(
            visible: isPaymentprocessDone, child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> createPaymentIntent() async {
    final url = Uri.parse(
        'https://3658-183-83-147-177.ngrok-free.app/api/payments/create-and-process-payment/${AppUtils.testingReaderId}');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "amount": 50,
      "currency": "GBP",
      "readerId": AppUtils.testingReaderId
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        PaymentResponse data =
            PaymentResponse.fromJson(jsonDecode(response.body));
        String paymentIntentId = data.paymentIntent.id;

        Fluttertoast.showToast(msg: "Payment Initiated");

        int elapsedTime = 0;
        timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          if (elapsedTime >= 60) {
            timer.cancel();

            setState(() {
              isPaymentprocessDone = false;
            });
          } else {
            setState(() {
              isPaymentprocessDone = true;
            });
            capturePayment(paymentIntentId);
            elapsedTime += 10;
            Fluttertoast.showToast(
                msg: "check status every $elapsedTime sec. until 1 min.");
          }
        });
      } else {
        Fluttertoast.showToast(msg: response.body);
        print('Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> capturePayment(String paymentIntentId) async {
    final url = Uri.parse(
        'https://3658-183-83-147-177.ngrok-free.app/api/payments/capture-payment/$paymentIntentId');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        PaymentResponse data =
            PaymentResponse.fromJson(jsonDecode(response.body));
        String status = data.paymentIntent.status;
        if (status == "succeeded") {
          Fluttertoast.showToast(msg: "payment success");
        } else {
          Fluttertoast.showToast(msg: "payment Not done");
        }
        setState(() {
          isPaymentprocessDone = false;
        });
        if (timer != null) timer!.cancel();
      } else {
        Fluttertoast.showToast(msg: "payment Not done");
        print('Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "payment Not done");
      print('Error: $e');
    }
  }
}
