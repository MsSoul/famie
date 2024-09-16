import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../child_profile/child_profile_manager.dart';
import '../child_profile/child_profile_reg_form.dart'; // Assuming this import is necessary

class DashboardScreen extends StatefulWidget {
  final String parentId;

  const DashboardScreen({super.key, required this.parentId});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final ChildProfileManager childProfileManager = ChildProfileManager();
  List<Map<String, String>> children = [];
  Map<String, String>? selectedChild;
  final Logger logger = Logger('DashboardScreen');
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren(); // Load children on initialization
  }

  /// Function to load children associated with the parent
  Future<void> _loadChildren() async {
    setState(() {
      isLoading = true; // Start loading indicator
    });

    try {
      bool success = await childProfileManager.loadChildren(widget.parentId);
      if (success) {
        setState(() {
          children = childProfileManager.getChildren();
          isLoading = false; // Stop loading indicator

          // Automatically select the first child if there are any
          if (children.isNotEmpty) {
            selectedChild = children.first;
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Failed to load children. Please try again.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logger.severe('Failed to load children: $e');
      _showErrorDialog('An error occurred while loading children.');
    }
  }

  /// Callback when a child is successfully registered
  void _onChildRegistered(String childName, String childAvatar) {
    setState(() {
      children.add({
        'name': childName,
        'avatar': childAvatar,
      });
      selectedChild = children.last;  // Automatically select the newly added child
    });
  }

  /// Function to open the child registration form
 Future<void> _openChildRegistrationForm() async {
  await showDialog(
    context: context,
    builder: (context) => ChildRegistrationForm(
      parentId: widget.parentId,
      onChildRegistered: _onChildRegistered,
      deviceName: 'Your Device Name',  // Provide actual device name
      macAddress: 'Your MAC Address',  // Provide actual MAC address
    ),
  );
 }

  /// Error dialog to show when loading children fails
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Image.asset('assets/image2.png', height: 40.0, fit: BoxFit.contain),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align contents to the left
          children: [
            // Loading indicator when fetching data
            if (isLoading)
              const Center(child: CircularProgressIndicator()),

            // Message when no children profiles are available
            if (!isLoading && children.isEmpty)
              const Text('No children available', style: TextStyle(fontSize: 18)), // Left-aligned text

            // List of children if available
            if (!isLoading && children.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    bool isSelected = selectedChild == child;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(child['avatar'] ?? 'assets/avatar/default_avatar.png'),
                        radius: 30.0,
                      ),
                      title: Text(
                        child['name'] ?? '',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.green : Colors.black,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedChild = child;
                        });
                      },
                      tileColor: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
                    );
                  },
                ),
              ),

            // Dashboard title and screen time section
            const SizedBox(height: 20),
            const Text(
              'Dashboard', // Left-aligned dashboard title
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.left, // Ensures left alignment
            ),
            const Divider(thickness: 2.0),

            // Display selected child's screen time info if available
            if (selectedChild != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align the screen time info to the left
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Screen Time Limit',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const TimeCard(title: 'Allowed Time', time: '05:00 Hours'),
                      const SizedBox(height: 10),
                      const TimeCard(title: 'Time Spent', time: '04:30 Hours'),
                      const SizedBox(height: 10),
                      const TimeCard(title: 'Remaining Time Left', time: '00:30 Hours'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// TimeCard widget for displaying time-related information
class TimeCard extends StatelessWidget {
  final String title;
  final String time;

  const TimeCard({
    super.key,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          time,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
