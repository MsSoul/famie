// filename: dashboard/dashboard_screen.dart (Displays the child profiles on the dashboard)
import 'package:flutter/material.dart';
import '../child_profile/child_profile_manager.dart';
import '../design/theme.dart'; // Import your custom theme file
import '../child_profile/scan_child.dart';

class DashboardScreen extends StatefulWidget {
  final String parentId;

  const DashboardScreen({super.key, required this.parentId});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late ChildProfileManager _childProfileManager;
  List<Map<String, String>> children = [];
  Map<String, String>? _selectedChild; // Store the currently selected child
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _childProfileManager = ChildProfileManager();
    loadChildren();
  }

  // Load children from the backend using ChildProfileManager
  Future<void> loadChildren() async {
    bool success = await _childProfileManager.loadChildren(widget.parentId);
    if (success && mounted) {
      setState(() {
        children = _childProfileManager.getChildren();
        print('Children data loaded in UI: $children'); // Debug output to verify children are loaded
        _selectedChild = children.isNotEmpty ? children[0] : null; // Set the first child as default
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Dashboard', isLoggedIn: true), // Use the custom AppBar here
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          : Column(
              children: [
                SizedBox(
                  height: 140, // Adjust the height as needed
                  child: Scrollbar( // Add Scrollbar for better UI experience
                    thumbVisibility: true,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                      itemCount: children.length + 1, // Add one for the "Add Child" button
                      itemBuilder: (context, index) {
                        if (index == children.length) {
                          return _buildAddChildButton(); // Display Add Child button at the end
                        }
                        return _buildChildAvatar(children[index]);
                      },
                    ),
                  ),
                ),
                const Divider(color: Colors.green, height: 2),
                if (_selectedChild != null)
                  _buildSelectedChildProfile(_selectedChild!), // Display selected child's avatar and name
              ],
            ),
    );
  }

  // Build each child avatar in the horizontal list
  Widget _buildChildAvatar(Map<String, String> child) {
    bool isSelected = _selectedChild != null && _selectedChild!['childId'] == child['childId'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChild = child; // Update the selected child when tapped
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 0), // Add top margin
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(child['avatar'] ?? 'assets/avatar/default_avatar.png'),
              radius: 40,
              backgroundColor: Colors.transparent,
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback to default image if there's an error loading the avatar
                print('Error loading avatar: ${child['avatar']}, using default avatar.');
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.blue : Colors.green, width: 3), // Highlight selected child
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80, // Limit the width to prevent overflow
              child: Text(
                child['name'] ?? 'Unknown',
                overflow: TextOverflow.ellipsis, // Ensure long names don't overflow
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center, // Center the name text
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the "Add Child" button with the QR code scanning functionality
  Widget _buildAddChildButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to the QR scanning screen when the "Add Child" button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildRegistrationScreen(
              parentId: widget.parentId, // Pass the parent ID
              onChildRegistered: (String childName, String childAvatar) {
                // Add the new child to the list and update the UI
                setState(() {
                  children.add({
                    'name': childName,
                    'avatar': childAvatar,
                    'childId': 'new_child_id', // Use the actual child ID after registration
                  });
                  _selectedChild = children.last; // Set the newly added child as selected
                });
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 0), // Add top margin to align with avatars
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 5), // Thicker green border
              ),
              child: const Icon(Icons.add, size: 40, color: Colors.green), // Green "Add Child" icon
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Child',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), // Green text for "Add Child"
            ),
          ],
        ),
      ),
    );
  }

  // Build the profile view with only the selected child's avatar and name
  Widget _buildSelectedChildProfile(Map<String, String> child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(child['avatar'] ?? 'assets/avatar/default_avatar.png'),
          radius: 50, // Adjust the size of the avatar
          backgroundColor: Colors.transparent,
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback to default image if there's an error loading the avatar
            print('Error loading selected avatar: ${child['avatar']}, using default avatar.');
          },
        ),
        const SizedBox(height: 10), // Space between avatar and name
        Text(
          child['name'] ?? 'Unknown Name', // Show child's name
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/*
import 'package:flutter/material.dart';
import '../child_profile/child_profile_manager.dart';
import '../design/theme.dart'; // Import your custom theme file
import '../child_profile/scan_child.dart'; // Import the scan child screen

class DashboardScreen extends StatefulWidget {
  final String parentId;

  const DashboardScreen({super.key, required this.parentId});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late ChildProfileManager _childProfileManager;
  List<Map<String, String>> children = [];
  Map<String, String>? _selectedChild; // Store the currently selected child
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _childProfileManager = ChildProfileManager();
    loadChildren();
  }

  Future<void> loadChildren() async {
    bool success = await _childProfileManager.loadChildren(widget.parentId);
    if (success && mounted) {
      setState(() {
        children = _childProfileManager.getChildren();
        _selectedChild = children.isNotEmpty ? children[0] : null; // Set the first child as default
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Dashboard', isLoggedIn: true), // Use the custom AppBar here
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          : Column(
              children: [
                SizedBox(
                  height: 140, // Adjust the height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: children.length + 1, // Add one for the "Add Child" button
                    itemBuilder: (context, index) {
                      if (index == children.length) {
                        return _buildAddChildButton(); // Display Add Child button at the end
                      }
                      return _buildChildAvatar(children[index]);
                    },
                  ),
                ),
                const Divider(color: Colors.green, height: 2),
                if (_selectedChild != null)
                  _buildSelectedChildProfile(_selectedChild!), // Display selected child's avatar and name
              ],
            ),
    );
  }

  // Build each child avatar in the horizontal list
  Widget _buildChildAvatar(Map<String, String> child) {
    bool isSelected = _selectedChild != null && _selectedChild!['id'] == child['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChild = child; // Update the selected child when tapped
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 0), // Add top margin
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(child['avatar']!),
              radius: 40,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.blue : Colors.green, width: 3), // Highlight selected child
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(child['name'] ?? 'Unknown'), // Display child's name
          ],
        ),
      ),
    );
  }

  // Build the "Add Child" button with the QR code scanning functionality
  Widget _buildAddChildButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to the QR scanning screen when the "Add Child" button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildRegistrationScreen(
              parentId: widget.parentId, // Pass the parent ID
              onChildRegistered: (String childName, String childAvatar) {
                // Reload the child list when a new child is registered
                loadChildren();
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 0), // Add top margin to align with avatars
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.add, size: 50),
            ),
            const SizedBox(height: 8),
            const Text('Add Child'),
          ],
        ),
      ),
    );
  }

  // Build the profile view with only the selected child's avatar and name
  Widget _buildSelectedChildProfile(Map<String, String> child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(child['avatar']!),
          radius: 50, // Adjust the size of the avatar
        ),
        const SizedBox(height: 10), // Space between avatar and name
        Text(
          child['name'] ?? 'Unknown Name', // Show child's name
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
*/