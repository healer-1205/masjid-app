import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mosque_donation_app/models/post_donation_info_model.dart';
import 'package:mosque_donation_app/screens/payment_confirmation_screen.dart';
import 'package:mosque_donation_app/utils/app_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class ScanPage extends StatefulWidget {
  final ModelPostDonationInfo? modelPostDonationInfo;
  final String donationAmount;

  const ScanPage(
      {super.key, this.modelPostDonationInfo, required this.donationAmount});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanning = false;
  String scanStatus = "Discover & Connect Reader";
  Terminal? _terminal;
  Location? _selectedLocation;
  List<Reader> _readers = [];
  Reader? _reader;
  bool showSpinner = false;

  static const bool _isSimulated = true; //if testing >> true otherwise false

  //Tap & Pay
  StreamSubscription? _onConnectionStatusChangeSub;

  var _connectionStatus = ConnectionStatus.notConnected;

  StreamSubscription? _onPaymentStatusChangeSub;

  PaymentStatus _paymentStatus = PaymentStatus.notReady;

  StreamSubscription? _onUnexpectedReaderDisconnectSub;

  StreamSubscription? _discoverReaderSub;

  void _startDiscoverReaders(Terminal terminal) async {
    showSnackBar("Discovering Readers...");

    // Ensure previous discovery process is stopped
    _stopDiscoverReaders();

    // Disconnect from any currently connected reader before starting a new discovery
    if (_terminal!.getConnectedReader() != null) {
      showSnackBar("Disconnecting from previous reader...");
      await _terminal!.disconnectReader();
    }

    isScanning = true;
    _readers = [];
    final discoverReaderStream =
        terminal.discoverReaders(const LocalMobileDiscoveryConfiguration(
      isSimulated: _isSimulated,
    ));
    setState(() {
      _discoverReaderSub = discoverReaderStream.listen((readers) async {
        scanStatus = "Reader Discovered";
        setState(() => _readers = readers);
        //Auto connect to first reader found
        showSnackBar("Connecting to the reader...");
        setState(() {
          showSpinner = true;
        });
        await _connectReader(_terminal!, _readers[0]).then((v) {
          setState(() {
            showSpinner = false;
          });
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => EnterPaymentScreen(
          //         modelPostDonationInfo:
          //         widget.modelPostDonationInfo ??
          //             ModelPostDonationInfo(),
          //         terminal: _terminal!,
          //       )),
          // );

          //ToDo Calling Payment intent from here:
          _collectPayment();
        });
      }, onDone: () {
        setState(() {
          _discoverReaderSub = null;
          _readers = const [];
        });
      });
    });
  }

  void _stopDiscoverReaders() async {
    if (_discoverReaderSub != null) {
      await _discoverReaderSub?.cancel();
    }

    // unawaited(_discoverReaderSub?.cancel());
    setState(() {
      _discoverReaderSub = null;
      isScanning = false;
      scanStatus = "Scan readers";
      _readers = const [];
    });
  }

  Future<void> _connectReader(Terminal terminal, Reader reader) async {
    try {
      final newToken =
          await getConnectionToken(); // Fetch new token before connecting

      await _tryConnectReader(terminal, reader).then((value) {
        final connectedReader = value;
        if (connectedReader == null) {
          showSnackBar('Error connecting to reader! Please try again');
        } else {
          _reader = connectedReader;
          showSnackBar(
              'Connected to the reader: ${connectedReader.serialNumber}');
        }
      });
    } catch (e) {
      showSnackBar(e.toString());
      setState(() {
        showSpinner = false;
      });
    }
  }

  Future<Reader?> _tryConnectReader(Terminal terminal, Reader reader) async {
    try {
      String? getLocationId() {
        showSnackBar('Fetching location...');

        final locationId = _selectedLocation?.id ?? reader.locationId;
        if (locationId == null) {
          showSnackBar('Missing location');
        }

        return locationId;
      }

      final locationId = getLocationId();

      return await terminal.connectMobileReader(
        reader,
        locationId: locationId ?? "",
      );
    } catch (e) {
      showSnackBar(e.toString());
      setState(() {
        showSpinner = false;
      });
    }
    return null;
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

  Future<void> _initTerminal() async {
    await requestPermissions();
    await initTerminal();
    await _fetchLocations();
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

  Future<void> initTerminal() async {
    // final connectionToken = await getConnectionToken();
    final terminal = await Terminal.getInstance(
      shouldPrintLogs: false,
      fetchToken: () async {
        // return connectionToken;
        return await getConnectionToken(); // Always fetch a new token
      },
    ).then((terminal) {
      _terminal = terminal;
      // showSnackBar("Initialized Stripe Terminal");
      _onConnectionStatusChangeSub =
          terminal.onConnectionStatusChange.listen((status) {
        print('Connection Status Changed: ${status.name}');
        _connectionStatus = status;
        scanStatus = _connectionStatus.name;
      });
      _onUnexpectedReaderDisconnectSub =
          terminal.onUnexpectedReaderDisconnect.listen((reader) {
        print('Reader Unexpected Disconnected: ${reader.label}');
      });
      _onPaymentStatusChangeSub =
          terminal.onPaymentStatusChange.listen((status) {
        print('Payment Status Changed: ${status.name}');
        _paymentStatus = status;
      });
      if (_terminal == null) {
        print('Please try again later!');
      } else {
        _startDiscoverReaders(terminal);
      }
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  bool _isPaymentSuccessful = false;
  PaymentIntent? _paymentIntent;
  final _formKey = GlobalKey<FormState>();

  Future<bool> _createPaymentIntent(Terminal terminal, String amount) async {
    showSnackBar("Creating payment intent...");
    setState(() {
      showSpinner = true; // Show loader
    });

    try {
      final paymentIntent =
          await terminal.createPaymentIntent(PaymentIntentParameters(
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
    } finally {
      setState(() {
        showSpinner = false; // Hide loader
      });
    }

    return await _collectPaymentMethod(terminal, _paymentIntent!);
  }

  Future<bool> _collectPaymentMethod(
      Terminal terminal, PaymentIntent paymentIntent) async {
    showSnackBar("Collecting payment method...");

    final collectingPaymentMethod = terminal.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );

    try {
      final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
      _paymentIntent = paymentIntentWithPaymentMethod;
      await _confirmPaymentIntent(terminal, _paymentIntent!).then((value) {});
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

  Future<void> _confirmPaymentIntent(
      Terminal terminal, PaymentIntent paymentIntent) async {
    setState(() {
      showSpinner = true; // Show loader
    });

    try {
      showSnackBar('Processing!');

      final processedPaymentIntent =
          await terminal.confirmPaymentIntent(paymentIntent);
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PaymentConfirmationScreen(
                    paymentStatus: true,
                  )));
    } catch (e) {
      showSnackBar('Inside collect payment exception ${e.toString()}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PaymentConfirmationScreen(
                    paymentStatus: false,
                  )));
      print(e.toString());
    } finally {
      setState(() {
        showSpinner = false; // Hide loader
      });
    }
    // navigate to payment success screen
  }

  void _collectPayment() async {
    // if (_formKey.currentState!.validate()) {
    setState(() {
      showSpinner = true; // Show loader
    });

    try {
      showSnackBar("Terminal Connected: ${_terminal?.getConnectedReader()}");
      bool status =
          await _createPaymentIntent(_terminal!, widget.donationAmount);
      if (status) {
        showSnackBar('Payment Collected: ${widget.donationAmount}');
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PaymentConfirmationScreen(
                      paymentStatus: false,
                    )));
        showSnackBar('Payment Cancelled');
      }
    } catch (e) {
      showSnackBar("Collect Payment Exception: $e");
    }
    // }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // showSnackBar("Wait initializing Stripe Terminal");
    });

    _initTerminal();
  }

  Future<void> restartTerminalSession() async {
    if (_terminal != null && _terminal!.getConnectedReader() != null) {
      await _terminal?.disconnectReader();
    }

    await initTerminal(); // Re-initialize with a fresh token
  }

  @override
  void dispose() {
    _stopDiscoverReaders(); // Ensure discovery is stopped

    // Ensure reader is disconnected when leaving the page
    restartTerminalSession();

    unawaited(_onConnectionStatusChangeSub?.cancel());
    // unawaited(_discoverReaderSub?.cancel());
    unawaited(_onUnexpectedReaderDisconnectSub?.cancel());
    unawaited(_onPaymentStatusChangeSub?.cancel());
    super.dispose();
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
        body: Center(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Image.asset(AppUtils.watermarkLogo)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Center(
                      child: Text(scanStatus,
                          style: TextStyle(
                              fontFamily: kFontFamily,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 4.5.w)),
                    ),
                  ),
                  if (_readers.isNotEmpty)
                    ..._readers.map((reader) => Center(
                          child: TextButton(
                            onPressed: () async {
                              setState(() {
                                showSpinner = true;
                              });
                              await _connectReader(_terminal!, reader)
                                  .then((v) {
                                setState(() {
                                  showSpinner = false;
                                });
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => EnterPaymentScreen(
                                //             modelPostDonationInfo:
                                //                 widget.modelPostDonationInfo ??
                                //                     ModelPostDonationInfo(),
                                //             terminal: _terminal!,
                                //           )),
                                // );
                                _collectPayment();
                              });
                            },
                            child: Text(
                              "Device Type: ${reader.deviceType?.name}\nSerial No.: ${reader.serialNumber}" ??
                                  "",
                              style: TextStyle(
                                  fontSize: 4.w, color: kPrimaryColor),
                            ),
                          ),
                        )),
                ],
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     isScanning
        //         ? _stopDiscoverReaders()
        //         : _startDiscoverReaders(_terminal!);
        //   },
        //   label: Text(isScanning ? 'Stop Scanning' : 'Scan Reader',
        //   style: TextStyle(
        //       color: Colors.white,
        //     fontFamily: kFontFamily
        //   ),),
        //   icon: Icon(isScanning ? Icons.stop : Icons.scanner, color: Colors.white,),
        //   backgroundColor: kPrimaryColor,
        //   elevation: 5,
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
