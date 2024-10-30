import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/child_profile_service.dart';

class ChildRegistrationForm extends StatefulWidget {
  final String parentId;
  final String deviceName;
  final String macAddress;
  final String childId;
  final Function(String, String) onChildRegistered;

  const ChildRegistrationForm({
    super.key,
    required this.parentId,
    required this.deviceName,
    required this.macAddress,
    required this.childId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationFormState createState() => ChildRegistrationFormState();
}

class ChildRegistrationFormState extends State<ChildRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedAvatar;
  final Logger _logger = Logger();
  final ChildProfileService _childProfileService = ChildProfileService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _registerChild() async {
    final childName = _nameController.text.trim();

    if (childName.isEmpty || selectedAvatar == null) {
      _showErrorDialog('Please fill in all fields and select an avatar.');
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      _logger.i('Registering child with ID: ${widget.childId}');

      bool success = await _childProfileService.registerChild(
        widget.parentId,
        widget.childId,
        childName,
        selectedAvatar!,
        widget.deviceName,
        widget.macAddress,
      );

      if (success) {
        widget.onChildRegistered(childName, selectedAvatar!);
        if (mounted) {
          _showSuccessDialog(childName);
        }
      } else {
        _showErrorDialog('Failed to register child. Please try again.');
      }
    } catch (e) {
      _logger.e('Error registering child: $e');
      _showErrorDialog('An error occurred: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: appBarColor)),
          ),
        ],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appBarColor ?? Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessDialog(String childName) {
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text('Child "$childName" has been successfully registered.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context, true);
            },
            child: Text('OK', style: TextStyle(color: appBarColor)),
          ),
        ],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appBarColor ?? Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Child\'s Name:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Avatar:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/boy.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/boy.jfif'
                                ? appBarColor
                                : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/boy.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/girl.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/girl.jfif'
                                ? appBarColor
                                : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/girl.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _registerChild,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Register Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*//filename:child_profile/child_profile_reg_form.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/child_profile_service.dart'; // Import the child profile service

class ChildRegistrationForm extends StatefulWidget {
  final String parentId;
  final String deviceName;
  final String macAddress;
  final String childId; // Child ID extracted from QR code
  final Function(String, String) onChildRegistered;

  const ChildRegistrationForm({
    super.key,
    required this.parentId,
    required this.deviceName,
    required this.macAddress,
    required this.childId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationFormState createState() => ChildRegistrationFormState();
}

class ChildRegistrationFormState extends State<ChildRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedAvatar;
  final Logger _logger = Logger(); // Correctly initializing Logger
  final ChildProfileService _childProfileService = ChildProfileService(); // Use the new service
  bool _isSubmitting = false; // Prevents multiple submissions

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _registerChild() async {
    final childName = _nameController.text.trim();

    if (childName.isEmpty || selectedAvatar == null) {
      _showErrorDialog('Please fill in all fields and select an avatar.');
      return;
    }

    try {
      setState(() {
        _isSubmitting = true; // Disable button during submission
      });

      _logger.i('Registering child with ID: ${widget.childId}'); // Using logger.i for informational logging

      // Register the child using the ChildProfileService
      bool success = await _childProfileService.registerChild(
        widget.parentId,
        widget.childId, // Use the childId from QR code
        childName,
        selectedAvatar!,
        widget.deviceName, // Use the deviceName from QR code
        widget.macAddress, // Use the macAddress from QR code
      );

      if (success) {
        widget.onChildRegistered(childName, selectedAvatar!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child registered successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showErrorDialog('Failed to register child. Please try again.');
      }
    } catch (e) {
      _logger.e('Error registering child: $e'); // Using logger.e for error logging
      _showErrorDialog('An error occurred: $e');
    } finally {
      setState(() {
        _isSubmitting = false; // Re-enable button after submission
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.blue; // Use the app bar color from theme

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Child\'s Name:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Avatar:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/boy.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/boy.jfif'
                                ? appBarColor // Use app bar color for selected avatar
                                : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/boy.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/girl.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/girl.jfif'
                                ? appBarColor // Use app bar color for selected avatar
                                : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/girl.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _registerChild,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Register Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/child_profile_service.dart'; // Import the child profile service

class ChildRegistrationForm extends StatefulWidget {
  final String parentId;
  final String deviceName;
  final String macAddress;
  final String childId; // Child ID extracted from QR code
  final Function(String, String) onChildRegistered;

  const ChildRegistrationForm({
    super.key,
    required this.parentId,
    required this.deviceName,
    required this.macAddress,
    required this.childId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationFormState createState() => ChildRegistrationFormState();
}

class ChildRegistrationFormState extends State<ChildRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedAvatar;
  final Logger _logger = Logger(); // Correctly initializing Logger
  final ChildProfileService _childProfileService = ChildProfileService(); // Use the new service
  bool _isSubmitting = false; // Prevents multiple submissions

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _registerChild() async {
    final childName = _nameController.text.trim();

    if (childName.isEmpty || selectedAvatar == null) {
      _showErrorDialog('Please fill in all fields and select an avatar.');
      return;
    }

    try {
      setState(() {
        _isSubmitting = true; // Disable button during submission
      });

      _logger.i('Registering child with ID: ${widget.childId}'); // Using logger.i for informational logging

      // Register the child using the ChildProfileService
      bool success = await _childProfileService.registerChild(
        widget.parentId,
        widget.childId, // Use the childId from QR code
        childName,
        selectedAvatar!,
        widget.deviceName, // Use the deviceName from QR code
        widget.macAddress, // Use the macAddress from QR code
      );

      if (success) {
        widget.onChildRegistered(childName, selectedAvatar!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child registered successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showErrorDialog('Failed to register child. Please try again.');
      }
    } catch (e) {
      _logger.e('Error registering child: $e'); // Using logger.e for error logging
      _showErrorDialog('An error occurred: $e');
    } finally {
      setState(() {
        _isSubmitting = false; // Re-enable button after submission
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Child\'s Name:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Avatar:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/boy.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/boy.jfif' ? Colors.green : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/boy.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/girl.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/girl.jfif' ? Colors.green : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/girl.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _registerChild,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Register Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/api_service.dart';

class ChildRegistrationForm extends StatefulWidget {
  final String parentId;
  final String deviceName;
  final String macAddress;
  final String childId; // Child ID extracted from QR code
  final Function(String, String) onChildRegistered;

  const ChildRegistrationForm({
    super.key,
    required this.parentId,
    required this.deviceName,
    required this.macAddress,
    required this.childId,
    required this.onChildRegistered,
  });

  @override
  ChildRegistrationFormState createState() => ChildRegistrationFormState();
}

class ChildRegistrationFormState extends State<ChildRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedAvatar;
  final Logger _logger = Logger(); // Correctly initializing Logger
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false; // Prevents multiple submissions

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _registerChild() async {
    final childName = _nameController.text.trim();

    if (childName.isEmpty || selectedAvatar == null) {
      _showErrorDialog('Please fill in all fields and select an avatar.');
      return;
    }

    try {
      setState(() {
        _isSubmitting = true; // Disable button during submission
      });

      _logger.i('Registering child with ID: ${widget.childId}'); // Using logger.i for informational logging

      // Register the child using API with childId, macAddress, and deviceName from QR code
      bool success = await _apiService.registerChild(
        widget.parentId,
        widget.childId, // Use the childId from QR code
        childName,
        selectedAvatar!,
        widget.deviceName, // Use the deviceName from QR code
        widget.macAddress, // Use the macAddress from QR code
      );

      if (success) {
        widget.onChildRegistered(childName, selectedAvatar!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child registered successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showErrorDialog('Failed to register child. Please try again.');
      }
    } catch (e) {
      _logger.e('Error registering child: $e'); // Using logger.e for error logging
      _showErrorDialog('An error occurred: $e');
    } finally {
      setState(() {
        _isSubmitting = false; // Re-enable button after submission
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Child\'s Name:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Avatar:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/boy.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/boy.jfif' ? Colors.green : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/boy.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/girl.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/girl.jfif' ? Colors.green : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/girl.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _registerChild,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Register Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
/*
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/api_service.dart';

class ChildRegistrationForm extends StatefulWidget {
  final String parentId;
  final Function(String, String) onChildRegistered;
  final String deviceName;
  final String macAddress;

  const ChildRegistrationForm({
    super.key,
    required this.parentId,
    required this.onChildRegistered,
    required this.deviceName,
    required this.macAddress,
  });

  @override
  ChildRegistrationFormState createState() => ChildRegistrationFormState();
}

class ChildRegistrationFormState extends State<ChildRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedAvatar;
  final Logger _logger = Logger('ChildRegistrationForm');
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;  // State to prevent multiple submissions

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Ensure you provide a unique childId here
  String generateChildId() {
    return DateTime.now().millisecondsSinceEpoch.toString(); // Example of generating an ID based on the timestamp
  }

  Future<void> _registerChild() async {
    final childName = _nameController.text.trim();

    if (childName.isEmpty || selectedAvatar == null) {
      _showErrorDialog('Please fill in all fields and select an avatar.');
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;  // Disable button during submission
      });

      // Generate childId
      final childId = generateChildId();  // Call the function to generate an ObjectId

      _logger.info('Generated childId: $childId');  // Log the generated ID

      // Call the API to register the child with the generated childId
      bool success = await _apiService.registerChild(
        widget.parentId,
        childId,  // Use the generated ObjectId here
        childName,
        selectedAvatar!, // Avatar path
        widget.deviceName,
        widget.macAddress,
      );

      if (success) {
        // Call the onChildRegistered callback to update the dashboard
        widget.onChildRegistered(childName, selectedAvatar!);

        // Display a success message
        if (mounted) {  // Ensure the widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child registered successfully')),
          );

          // Close the registration form
          Navigator.pop(context, true);
        }
      } else {
        _showErrorDialog('Failed to register child. Please try again.');
      }
    } catch (e) {
      _logger.severe('Error registering child: $e');
      _showErrorDialog('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;  // Re-enable the button after submission
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Child\'s Name:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Avatar:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/boy.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/boy.jfif' ? Colors.green : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/boy.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = 'assets/avatar/girl.jfif';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedAvatar == 'assets/avatar/girl.jfif' ? Colors.green : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar/girl.jfif'),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () async {
                  await _registerChild();
                },
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/