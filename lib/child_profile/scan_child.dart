import 'package:famie_one/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart'; // Import the network_info_plus package
import '../home.dart';
import '../main.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:logger/logger.dart';
import 'child_profile_reg_form.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package
import 'dart:async';

// GlobalKey for ScaffoldMessenger to access the root context
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId;
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  bool isConnected = false;
  mongo.Db? db;
  mongo.DbCollection? collection;
  var logger = Logger();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initMongoDB();

    // Initialize AnimationController
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  // Initialize MongoDB and check for internet connection
  Future<void> _initMongoDB() async {
  // Check network connection first
  var connectivityResult = await (Connectivity().checkConnectivity());

  // Check connectivity result against correct type
  // ignore: unrelated_type_equality_checks
  if (connectivityResult == ConnectivityResult.none) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
    }
    return;  // Exit the function if there's no connection
  }

  try {
    // Use a timeout for MongoDB connection attempt (e.g., 10 seconds)
    db = await mongo.Db.create('mongodb://192.168.1.130:27017/famie').timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException("Connection to MongoDB timed out");
      },
    );
    await db!.open();
    collection = db!.collection('child_profile');
    setState(() {
      isConnected = true;
    });
  } catch (e) {
    // Log the error and show an appropriate message to the user
    logger.e("Error connecting to MongoDB: $e");
    setState(() {
      isConnected = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the database: $e')),
      );
    }
  }
}

  @override
  void dispose() {
    controller?.dispose();
    db?.close();
    _animationController.dispose();
    super.dispose();
  }

  // Function to scan QR Code
  void _scanQRCode() {
    setState(() {
      showScanner = true;
    });
  }

  // QR code listener
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (result == null && scanData.code != null) {
        setState(() {
          result = scanData;
        });
        await controller.pauseCamera();
        await processQRCode(result!.code!);
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
        );
      }
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      List<String> data = qrCodeData.split(',');
      if (data.length != 2) {
        throw Exception('Invalid QR code data format');
      }

      String? macAddress = await fetchMacAddress(); // Get MAC address here
      String deviceName = data[1].trim().replaceAll('"', '').replaceAll('}', '');

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");

      if (macAddress!.isEmpty || macAddress == "Unknown") {
        throw Exception("MAC address is missing or unknown.");
      }

      await _showChildRegistrationForm(macAddress, deviceName);
    } catch (e) {
      logger.e("Error processing QR code: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing QR code: $e')),
        );
      }

      controller?.resumeCamera();
    }
  }

  // Fetch the MAC address using network_info_plus
  Future<String?> fetchMacAddress() async {
    final info = NetworkInfo();

    try {
      String? macAddress = await info.getWifiBSSID();
      if (macAddress == null || macAddress.isEmpty) {
        macAddress = "Unknown";
      }
      return macAddress;
    } catch (e) {
      logger.e("Error fetching MAC address: $e");
      return "Unknown";
    }
  }

  // Show child registration form
  // Modify the method where registration happens
Future<void> _showChildRegistrationForm(String macAddress, String deviceName) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: (String childName, String childAvatar) {
          widget.onChildRegistered(childName, childAvatar);
        },
        deviceName: deviceName,
        macAddress: macAddress,
      ),
    );

    if (result != null && result is bool && result) {
      setState(() {
        isConnected = true;
        showScanner = false;
      });

      // Navigate to the dashboard screen after successful registration
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(parentId: widget.parentId)),
        (Route<dynamic> route) => false,
      );
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/image2.png',
            height: 40.0,
            fit: BoxFit.cover,
          ),
          centerTitle: true,
          backgroundColor: Colors.green[200],
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(parentId: widget.parentId)),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              color: Colors.black,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAddChildButton(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Add Child',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              color: Colors.green,
              thickness: 2,
              height: 20,
              indent: 20,
              endIndent: 20,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (showScanner) _buildQRView(context),
                  if (isConnected && !showScanner) _buildSuccessContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChildButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 80,
          height: 80,
          child: ElevatedButton(
            onPressed: _scanQRCode,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.black, width: 2),
              elevation: 5,
            ),
            child: const Icon(Icons.add, size: 30, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.8;
    return Stack(
      alignment: Alignment.center,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.green,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: size,
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final verticalPosition = size * 0.5 + (_animation.value * (size * 0.8));

            return Positioned(
              top: verticalPosition,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                height: 2,
                color: Colors.green.withOpacity(0.7),
              ),
            );
          },
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.red,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                showScanner = false;
              });
              controller?.stopCamera();
            },
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Align the QR code within the frame to scan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 100,
        ),
        const SizedBox(height: 20),
        const Text(
          'Child Registered Successfully!',
          style: TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isConnected = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text(
            'Add Another Child',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}