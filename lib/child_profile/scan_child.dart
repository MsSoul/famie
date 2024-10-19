//filename:child_profile/scan_child.dart (qr code scanner)
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; // For jsonDecode
import 'child_profile_reg_form.dart'; // Import the child registration form
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection
import '../design/theme.dart'; // Import your theme.dart to use the customAppBar
import 'child_profile_widget.dart'; // Import the child profile widget

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId; // The ID of the parent
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  bool isFirstTimeScanning = true; // Track if it's the first scan
  var logger = Logger();

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Function to scan QR Code
  void _scanQRCode() {
    if (isFirstTimeScanning) {
      _showFirstTimeScanDialog(); // Show the dialog for first-time users
    } else {
      setState(() {
        showScanner = true;
      });
    }
  }

  // Show the first-time scanning dialog
  Future<void> _showFirstTimeScanDialog() async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Welcome to Famie!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'As a parent, you can effectively manage your child\'s screen time. To add a child, please install the FamKid app.',
              textAlign: TextAlign.center, // Center align the text for better readability
            ),
            const SizedBox(height: 20), // Add some spacing
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green, width: 2), // Border around the logo
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding inside the border
                child: Image.asset('assets/famie_icon-removebg-preview.png', height: 100), // Adjust height as needed
              ),
            ),
            const SizedBox(height: 20), // Add spacing between the logo and the new text
            const Text(
              'It will generate a QR code for you to scan.',
              textAlign: TextAlign.center, // Center align the new text
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green, width: 2),
          borderRadius: BorderRadius.circular(8.0),
        ),
      );
    },
  );
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
        await processQRCode(result!.code!); // Process the QR code data
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      // Assume QR code data is in JSON format like: {"macAddress": "xx:xx:xx:xx", "deviceName": "Device Name", "childId": "childId"}
      Map<String, dynamic> data = _parseQRCodeData(qrCodeData);

      String macAddress = data['macAddress'] ?? '';
      String deviceName = data['deviceName'] ?? '';
      String childId = data['childId'] ?? '';

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");
      logger.i("Parsed childId: $childId");

      // Proceed to show the child registration form with the parsed QR data
      await _showChildRegistrationForm(macAddress, deviceName, childId);
    } catch (e) {
      logger.e("Error processing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      controller?.resumeCamera();
    }
  }

  // Parse the JSON data from the QR code
  Map<String, dynamic> _parseQRCodeData(String qrCodeData) {
    try {
      return jsonDecode(qrCodeData); // Properly parse the JSON string
    } catch (e) {
      logger.e('Error decoding QR code data: $e');
      return {};
    }
  }

  // Show the child registration form with the extracted QR code data
  Future<void> _showChildRegistrationForm(String macAddress, String deviceName, String childId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: widget.onChildRegistered,
        deviceName: deviceName, // Pass the device name from QR code
        macAddress: macAddress, // Pass the MAC address from QR code
        childId: childId,       // Pass the childId from QR code
      ),
    );

    if (result != null && result is bool && result) {
      // If child is registered successfully, navigate to the dashboard or handle as needed
      Navigator.pop(context);
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Scan QR Code', isLoggedIn: true, parentId: widget.parentId),
      body: Column(
        children: [
          // Child Profile widget placed below the AppBar
          ChildProfileWidget(
            parentId: widget.parentId,
            onChildSelected: (childId) {
              // Handle child selection if needed
              logger.i("Selected child ID: $childId");
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner) _buildQRView(context),
                if (!showScanner) _buildInitialContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _scanQRCode,
        child: const Text('Start QR Code Scan'),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green, // Set the border color to the app bar color
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; // For jsonDecode
import 'child_profile_reg_form.dart'; // Import the child registration form
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection
import '../design/theme.dart'; // Import your theme.dart to use the customAppBar
import 'child_profile_widget.dart'; // Import the child profile widget

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId; // The ID of the parent
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  var logger = Logger();

  @override
  void dispose() {
    controller?.dispose();
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
        await processQRCode(result!.code!); // Process the QR code data
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      // Assume QR code data is in JSON format like: {"macAddress": "xx:xx:xx:xx", "deviceName": "Device Name", "childId": "childId"}
      Map<String, dynamic> data = _parseQRCodeData(qrCodeData);

      String macAddress = data['macAddress'] ?? '';
      String deviceName = data['deviceName'] ?? '';
      String childId = data['childId'] ?? '';

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");
      logger.i("Parsed childId: $childId");

      // Proceed to show the child registration form with the parsed QR data
      await _showChildRegistrationForm(macAddress, deviceName, childId);
    } catch (e) {
      logger.e("Error processing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      controller?.resumeCamera();
    }
  }

  // Parse the JSON data from the QR code
  Map<String, dynamic> _parseQRCodeData(String qrCodeData) {
    try {
      return jsonDecode(qrCodeData); // Properly parse the JSON string
    } catch (e) {
      logger.e('Error decoding QR code data: $e');
      return {};
    }
  }

  // Show the child registration form with the extracted QR code data
  Future<void> _showChildRegistrationForm(String macAddress, String deviceName, String childId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: widget.onChildRegistered,
        deviceName: deviceName, // Pass the device name from QR code
        macAddress: macAddress, // Pass the MAC address from QR code
        childId: childId,       // Pass the childId from QR code
      ),
    );

    if (result != null && result is bool && result) {
      // If child is registered successfully, navigate to the dashboard or handle as needed
      Navigator.pop(context);
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Scan QR Code', isLoggedIn: true, parentId: widget.parentId),
      body: Column(
        children: [
          // Child Profile widget placed below the AppBar
          ChildProfileWidget(
            parentId: widget.parentId,
            onChildSelected: (childId) {
              // Handle child selection if needed
              logger.i("Selected child ID: $childId");
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner) _buildQRView(context),
                if (!showScanner) _buildInitialContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _scanQRCode,
        child: const Text('Start QR Code Scan'),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green, // Set the border color to the app bar color
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; // For jsonDecode
import 'child_profile_reg_form.dart'; // Import the child registration form
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection
import '../design/theme.dart'; // Import your theme.dart to use the customAppBar
import 'child_profile_widget.dart'; // Import the child profile widget

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId; // The ID of the parent
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  var logger = Logger();

  @override
  void dispose() {
    controller?.dispose();
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
        await processQRCode(result!.code!); // Process the QR code data
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      // Assume QR code data is in JSON format like: {"macAddress": "xx:xx:xx:xx", "deviceName": "Device Name", "childId": "childId"}
      Map<String, dynamic> data = _parseQRCodeData(qrCodeData);

      String macAddress = data['macAddress'] ?? '';
      String deviceName = data['deviceName'] ?? '';
      String childId = data['childId'] ?? '';

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");
      logger.i("Parsed childId: $childId");

      // Proceed to show the child registration form with the parsed QR data
      await _showChildRegistrationForm(macAddress, deviceName, childId);
    } catch (e) {
      logger.e("Error processing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      controller?.resumeCamera();
    }
  }

  // Parse the JSON data from the QR code
  Map<String, dynamic> _parseQRCodeData(String qrCodeData) {
    try {
      return jsonDecode(qrCodeData); // Properly parse the JSON string
    } catch (e) {
      logger.e('Error decoding QR code data: $e');
      return {};
    }
  }

  // Show the child registration form with the extracted QR code data
  Future<void> _showChildRegistrationForm(String macAddress, String deviceName, String childId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: widget.onChildRegistered,
        deviceName: deviceName, // Pass the device name from QR code
        macAddress: macAddress, // Pass the MAC address from QR code
        childId: childId,       // Pass the childId from QR code
      ),
    );

    if (result != null && result is bool && result) {
      // If child is registered successfully, navigate to the dashboard or handle as needed
      Navigator.pop(context);
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Scan QR Code', isLoggedIn: true, parentId: widget.parentId),
      body: Column(
        children: [
          // Child Profile widget placed below the AppBar
          ChildProfileWidget(
            parentId: widget.parentId,
            onChildSelected: (childId) {
              // Handle child selection if needed
              logger.i("Selected child ID: $childId");
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner) _buildQRView(context),
                if (!showScanner) _buildInitialContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _scanQRCode,
        child: const Text('Start QR Code Scan'),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }
}
*/

/* mugana pero wlay child widget
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; // For jsonDecode
import 'child_profile_reg_form.dart'; // Import the child registration form
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection
import '../design/theme.dart'; // Import your theme.dart to use the customAppBar

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId; // The ID of the parent
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  var logger = Logger();

  @override
  void dispose() {
    controller?.dispose();
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
        await processQRCode(result!.code!); // Process the QR code data
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      // Assume QR code data is in JSON format like: {"macAddress": "xx:xx:xx:xx", "deviceName": "Device Name", "childId": "childId"}
      Map<String, dynamic> data = _parseQRCodeData(qrCodeData);

      String macAddress = data['macAddress'] ?? '';
      String deviceName = data['deviceName'] ?? '';
      String childId = data['childId'] ?? '';

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");
      logger.i("Parsed childId: $childId");

      // Proceed to show the child registration form with the parsed QR data
      await _showChildRegistrationForm(macAddress, deviceName, childId);
    } catch (e) {
      logger.e("Error processing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      controller?.resumeCamera();
    }
  }

  // Parse the JSON data from the QR code
  Map<String, dynamic> _parseQRCodeData(String qrCodeData) {
    try {
      return jsonDecode(qrCodeData); // Properly parse the JSON string
    } catch (e) {
      logger.e('Error decoding QR code data: $e');
      return {};
    }
  }

  // Show the child registration form with the extracted QR code data
  Future<void> _showChildRegistrationForm(String macAddress, String deviceName, String childId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: widget.onChildRegistered,
        deviceName: deviceName, // Pass the device name from QR code
        macAddress: macAddress, // Pass the MAC address from QR code
        childId: childId,       // Pass the childId from QR code
      ),
    );

    if (result != null && result is bool && result) {
      // If child is registered successfully, navigate to the dashboard or handle as needed
      Navigator.pop(context);
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Scan QR Code', isLoggedIn: true, parentId: widget.parentId), // Pass parentId here
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner) _buildQRView(context),
                if (!showScanner) _buildInitialContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _scanQRCode,
        child: const Text('Start QR Code Scan'),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }
}

*/
/*
//filename:child_profile/scan_child.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; // For jsonDecode
import 'child_profile_reg_form.dart'; // Import the child registration form
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection
import '../design/theme.dart'; // Import your theme.dart to use the customAppBar

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId; // The ID of the parent
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  var logger = Logger();

  @override
  void dispose() {
    controller?.dispose();
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
        await processQRCode(result!.code!); // Process the QR code data
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      // Assume QR code data is in JSON format like: {"macAddress": "xx:xx:xx:xx", "deviceName": "Device Name", "childId": "childId"}
      Map<String, dynamic> data = _parseQRCodeData(qrCodeData);

      String macAddress = data['macAddress'] ?? '';
      String deviceName = data['deviceName'] ?? '';
      String childId = data['childId'] ?? '';

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");
      logger.i("Parsed childId: $childId");

      // Proceed to show the child registration form with the parsed QR data
      await _showChildRegistrationForm(macAddress, deviceName, childId);
    } catch (e) {
      logger.e("Error processing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      controller?.resumeCamera();
    }
  }

  // Parse the JSON data from the QR code
  Map<String, dynamic> _parseQRCodeData(String qrCodeData) {
    try {
      return jsonDecode(qrCodeData); // Properly parse the JSON string
    } catch (e) {
      logger.e('Error decoding QR code data: $e');
      return {};
    }
  }

  // Show the child registration form with the extracted QR code data
  Future<void> _showChildRegistrationForm(String macAddress, String deviceName, String childId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: widget.onChildRegistered,
        deviceName: deviceName, // Pass the device name from QR code
        macAddress: macAddress, // Pass the MAC address from QR code
        childId: childId,       // Pass the childId from QR code
      ),
    );

    if (result != null && result is bool && result) {
      // If child is registered successfully, navigate to the dashboard or handle as needed
      Navigator.pop(context);
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Scan QR Code', isLoggedIn: true), // Use customAppBar from theme.dart
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner) _buildQRView(context),
                if (!showScanner) _buildInitialContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _scanQRCode,
        child: const Text('Start QR Code Scan'),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }
}
*/

/*
// filename: child_profile/scan_child.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; // For jsonDecode
import 'child_profile_reg_form.dart'; // Import the child registration form
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection
import '../design/theme.dart'; // Import your theme.dart to use the customAppBar

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId; // The ID of the parent
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  var logger = Logger();

  @override
  void dispose() {
    controller?.dispose();
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
        await processQRCode(result!.code!); // Process the QR code data
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      // Assume QR code data is in JSON format like: {"macAddress": "xx:xx:xx:xx", "deviceName": "Device Name", "child_id": "childId"}
      Map<String, dynamic> data = _parseQRCodeData(qrCodeData);

      String macAddress = data['macAddress'] ?? '';
      String deviceName = data['deviceName'] ?? '';
      String childId = data['child_id'] ?? '';

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");
      logger.i("Parsed childId: $childId");

      // Proceed to show the child registration form with the parsed QR data
      await _showChildRegistrationForm(macAddress, deviceName, childId);
    } catch (e) {
      logger.e("Error processing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      controller?.resumeCamera();
    }
  }

  // Parse the JSON data from the QR code
  Map<String, dynamic> _parseQRCodeData(String qrCodeData) {
    try {
      return jsonDecode(qrCodeData); // Properly parse the JSON string
    } catch (e) {
      logger.e('Error decoding QR code data: $e');
      return {};
    }
  }

  // Show the child registration form with the extracted QR code data
  Future<void> _showChildRegistrationForm(String macAddress, String deviceName, String childId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: widget.onChildRegistered,
        deviceName: deviceName, // Pass the device name from QR code
        macAddress: macAddress, // Pass the MAC address from QR code
        childId: childId,       // Pass the childId from QR code
      ),
    );

    if (result != null && result is bool && result) {
      // If child is registered successfully, navigate to the dashboard or handle as needed
      Navigator.pop(context);
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Scan QR Code', isLoggedIn: true), // Use customAppBar from theme.dart
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner) _buildQRView(context),
                if (!showScanner) _buildInitialContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _scanQRCode,
        child: const Text('Start QR Code Scan'),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }
}*/

/*
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; // For jsonDecode
import 'child_profile_reg_form.dart'; // Import the child registration form
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection

class ChildRegistrationScreen extends StatefulWidget {
  final String parentId; // The ID of the parent
  final Function(String, String) onChildRegistered;

  const ChildRegistrationScreen({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationScreenState createState() => ChildRegistrationScreenState();
}

class ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool showScanner = false;
  var logger = Logger();

  @override
  void dispose() {
    controller?.dispose();
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
        await processQRCode(result!.code!); // Process the QR code data
      }
    });
  }

  // Process the QR code after scanning
  Future<void> processQRCode(String qrCodeData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your connection and try again.')),
      );
      return;
    }

    try {
      logger.i("QR Code Data: $qrCodeData");

      // Assume QR code data is in JSON format like: {"macAddress": "xx:xx:xx:xx", "deviceName": "Device Name", "child_id": "childId"}
      Map<String, dynamic> data = _parseQRCodeData(qrCodeData);

      String macAddress = data['macAddress'] ?? '';
      String deviceName = data['deviceName'] ?? '';
      String childId = data['child_id'] ?? '';

      logger.i("Parsed macAddress: $macAddress");
      logger.i("Parsed deviceName: $deviceName");
      logger.i("Parsed childId: $childId");

      // Proceed to show the child registration form with the parsed QR data
      await _showChildRegistrationForm(macAddress, deviceName, childId);
    } catch (e) {
      logger.e("Error processing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
      controller?.resumeCamera();
    }
  }

  // Parse the JSON data from the QR code
  Map<String, dynamic> _parseQRCodeData(String qrCodeData) {
    try {
      return jsonDecode(qrCodeData); // Properly parse the JSON string
    } catch (e) {
      logger.e('Error decoding QR code data: $e');
      return {};
    }
  }

  // Show the child registration form with the extracted QR code data
  Future<void> _showChildRegistrationForm(String macAddress, String deviceName, String childId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChildRegistrationForm(
        parentId: widget.parentId,
        onChildRegistered: widget.onChildRegistered,
        deviceName: deviceName, // Pass the device name from QR code
        macAddress: macAddress, // Pass the MAC address from QR code
        childId: childId,       // Pass the childId from QR code
      ),
    );

    if (result != null && result is bool && result) {
      // If child is registered successfully, navigate to the dashboard or handle as needed
      Navigator.pop(context);
    } else {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner) _buildQRView(context),
                if (!showScanner) _buildInitialContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _scanQRCode,
        child: const Text('Start QR Code Scan'),
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }
}
*/