import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mosque_donation_app/screens/payment_confirmation_screen.dart';
import 'package:mosque_donation_app/utils/global_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class ScanPaymenyScreen extends StatefulWidget {
  final String donationAmount;
  const ScanPaymenyScreen({super.key, required this.donationAmount});

  @override
  State<ScanPaymenyScreen> createState() => _ScanPaymenyScreenState();
}

class _ScanPaymenyScreenState extends State<ScanPaymenyScreen> {
  List<GlobalModel> globalModel = [];
  GlobalModel? selectedDiscovery;
  Terminal? _terminal;
  Location? _selectedLocation;
  StreamSubscription<List<Reader>>? _discoverReaderSub;
  List<Reader> _readers = [];
  PaymentIntent? _paymentIntent;
  bool showSpinner = false;
  Reader? _reader;
  bool _isPaymentSuccessful = false;
  bool isSimulated = true;

  @override
  void initState() {
    super.initState();
    initiateTerminl();
    createDiscoveryMethod();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    disconnectReader();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
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
        body: Column(
          children: [
            DropdownButtonFormField<GlobalModel>(
              value: selectedDiscovery,
              decoration: InputDecoration(border: OutlineInputBorder()),
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              // underline: Container(height: 2, color: Colors.deepPurpleAccent),
              onChanged: (GlobalModel? value) async {
                // This is called when the user selects an item.
                await _stopDiscoverReaders();
                await disconnectReader();
                setState(() {
                  selectedDiscovery = value!;
                });
              },
              items: globalModel
                  .map<DropdownMenuItem<GlobalModel>>((GlobalModel value) {
                return DropdownMenuItem<GlobalModel>(
                    value: value, child: Text(value.readerDescoveryMethod));
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                connectReader();
              },
              child: Text(
                "Scan Readers",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400),
            ),
            ElevatedButton(
              onPressed: () async {
                await _stopDiscoverReaders();
              },
              child: Text(
                "Disconnect Readers",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  showSpinner = true;
                });
                bool status = await _createPaymentIntent(widget.donationAmount);
                await _stopDiscoverReaders();
                await disconnectReader();

                if (status) {
                  showSnackBar('Payment Collected: ${widget.donationAmount}');

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentConfirmationScreen(
                                paymentStatus: true,
                              )));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentConfirmationScreen(
                                paymentStatus: false,
                              )));
                  showSnackBar('Payment Cancelled');
                }
                setState(() {
                  showSpinner = false;
                });
              },
              child: Text(
                "Start Payment",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Simulated"),
                Switch(
                  value: isSimulated,
                  onChanged: (value) {
                    setState(() {
                      isSimulated = value;
                    });
                  },
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _readers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      _reader = await _terminal!.connectBluetoothReader(
                          _readers[index],
                          locationId: _selectedLocation!.id!);
                      showSnackBar(
                          'Connected to a device: ${_reader!.label ?? _reader!.serialNumber}');
                    } catch (e) {
                      showSnackBar(e.toString());
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  },
                  title: Text(
                      "${_readers[index].deviceType!.name} ${isSimulated ? "simulate" : "No simulate"}"),
                  subtitle: Text(_readers[index].serialNumber),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void createDiscoveryMethod() {
    globalModel = [
      GlobalModel(
          readerDescoveryMethod: "Bluetooth",
          isSimulated: isSimulated,
          type: 1),
      GlobalModel(
          readerDescoveryMethod: "Internet", isSimulated: isSimulated, type: 2),
    ];

    selectedDiscovery = globalModel.first;
  }

  void initiateTerminl() async {
    await requestPermissions();
    await initTerminal();
    await _fetchLocations();
  }

  Future<void> requestPermissions() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
    ];

    for (final permission in permissions) {
      final result = await permission.request();
      if (result == PermissionStatus.denied ||
          result == PermissionStatus.permanentlyDenied) return;
    }
  }

  initTerminal() async {
    _terminal = await Terminal.getInstance(
        shouldPrintLogs: true,
        fetchToken: () async {
          // return connectionToken;
          return await getConnectionToken(); // Always fetch a new token
        });
  }

  Future<String> getConnectionToken() async {
    http.Response response = await http.post(
      Uri.parse("https://api.stripe.com/v1/terminal/connection_tokens"),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );
    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (jsonResponse['secret'] != null) {
      return jsonResponse['secret'];
    } else {
      return "";
    }
  }

  Future<void> _fetchLocations() async {
    final locations = await _terminal!.listLocations();
    _selectedLocation = locations.first;
    showSnackBar("Location: ${_selectedLocation?.id}");
    if (_selectedLocation == null) {
      showSnackBar(
          'Please create location on stripe dashboard to proceed further!');
    }
    setState(() {});
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  connectReader() {
    setState(() {
      showSpinner = true;
    });
    var discoverReaderStream;
    switch (selectedDiscovery!.type) {
      case 1:
        discoverReaderStream = _terminal!.discoverReaders(
            BluetoothDiscoveryConfiguration(isSimulated: isSimulated));
        break;
      case 2:
        discoverReaderStream = _terminal!.discoverReaders(
            InternetDiscoveryConfiguration(
                isSimulated: isSimulated, locationId: _selectedLocation!.id!));
        break;
      default:
    }

    setState(() {
      _discoverReaderSub = discoverReaderStream.listen((readers) {
        setState(() => _readers = readers);
      }, onDone: () {
        setState(() => _discoverReaderSub = null);
      });
    });
    setState(() {
      showSpinner = false;
    });
  }

  Future<void> _stopDiscoverReaders() async {
    await _discoverReaderSub?.cancel();
    setState(() {
      _discoverReaderSub = null;
      _readers = [];
    });
  }

  Future<bool> _createPaymentIntent(String amount) async {
    showSnackBar("Creating payment intent...");

    try {
      final paymentIntent =
          await _terminal!.createPaymentIntent(PaymentIntentParameters(
        amount: (double.parse(double.parse(amount).toStringAsFixed(2)) * 100)
            .ceil(),
        currency: "GBP",
        captureMethod: CaptureMethod.automatic,
        paymentMethodTypes: [PaymentMethodType.cardPresent],
      ));
      _paymentIntent = paymentIntent;
      if (_paymentIntent == null) {
        showSnackBar('Payment intent is not created!');
      }
    } catch (e) {
      showSnackBar("Payment Intent error: $e");
    } finally {}

    return await _collectPaymentMethod(_paymentIntent!);
  }

  Future<bool> _collectPaymentMethod(PaymentIntent paymentIntent) async {
    showSnackBar("Collecting payment method...");

    final collectingPaymentMethod = _terminal!.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );

    try {
      final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
      _paymentIntent = paymentIntentWithPaymentMethod;
      await _confirmPaymentIntent(_paymentIntent!).then((value) {});
      return true;
    } on TerminalException catch (exception) {
      switch (exception.code) {
        case TerminalExceptionCode.canceled:
          showSnackBar(
              'Collecting Payment method is cancelled! Exception: ${exception.message}');
          return false;
        default:
          rethrow;
      }
    }
  }

  Future<void> _confirmPaymentIntent(PaymentIntent paymentIntent) async {
    try {
      showSnackBar('Processing!');

      final processedPaymentIntent =
          await _terminal!.confirmPaymentIntent(paymentIntent);
      _paymentIntent = processedPaymentIntent;
      // Show the animation for a while and then reset the state
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _isPaymentSuccessful = false;
        });
      });
      setState(() {
        _isPaymentSuccessful = true;
      });
      showSnackBar('Payment processed!');
    } catch (e) {
      showSnackBar('Inside collect payment exception ${e.toString()}');

      print(e.toString());
    } finally {}
    // navigate to payment success screen
  }

  Future<void> disconnectReader() async {
    await _stopDiscoverReaders();

    await _terminal!.disconnectReader();
  }
}
