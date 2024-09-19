// filename: child_profile/child_profile_widget.dart (child profile area display)

import 'package:flutter/material.dart';
import '../child_profile/child_profile_manager.dart';
import 'scan_child.dart'; // Import the scan_child.dart for navigation

class ChildProfileWidget extends StatefulWidget {
  final String parentId;
  final Function(String childId) onChildSelected; // Pass the selected childId

  const ChildProfileWidget({super.key, required this.parentId, required this.onChildSelected});

  @override
  ChildProfileWidgetState createState() => ChildProfileWidgetState();
}

class ChildProfileWidgetState extends State<ChildProfileWidget> {
  final ChildProfileManager _childProfileManager = ChildProfileManager();
  List<Map<String, String>> children = [];
  Map<String, String>? _selectedChild;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    bool success = await _childProfileManager.loadChildren(widget.parentId);
    if (success) {
      setState(() {
        children = _childProfileManager.getChildren();
        if (children.isNotEmpty) {
          _selectedChild = children[0]; // Select the first child by default
          widget.onChildSelected(_selectedChild!['childId']!); // Pass the childId to parent
        }
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
    return Column(
      children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: 140, // Adjust height as needed
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: children.length + 1, // +1 for the "Add Child" button
                        itemBuilder: (context, index) {
                          if (index == children.length) {
                            return _buildAddChildButton();
                          }
                          return _buildChildAvatar(children[index]);
                        },
                      ),
                    ),
                  ),
                  const Divider(color: Colors.green, height: 2),
                  if (_selectedChild != null)
                    _buildSelectedChildProfile(_selectedChild!), // Show the selected child's details
                ],
              ),
      ],
    );
  }

  // Build child avatar item
  Widget _buildChildAvatar(Map<String, String> child) {
    bool isSelected = _selectedChild != null && _selectedChild!['childId'] == child['childId'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChild = child;
          widget.onChildSelected(child['childId']!); // Pass the childId when selected
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(child['avatar'] ?? 'assets/avatar/default_avatar.png'),
              radius: 40,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.green : Colors.white, width: 3),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              child['name'] ?? 'Unknown',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Build "Add Child" button
  Widget _buildAddChildButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to child registration screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildRegistrationScreen(
              parentId: widget.parentId, // Pass the parentId
              onChildRegistered: (String childName, String childAvatar) {
                // Handle what happens when a child is registered
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white, // White background inside the circle
              child: Container(
                width: 80, // Adjust the size to match the avatar size
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green, // Green border
                    width: 4, // Border width
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.green, // Green '+' icon
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Child',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Build the selected child's profile (optional)
  Widget _buildSelectedChildProfile(Map<String, String> child) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(child['avatar'] ?? 'assets/avatar/default_avatar.png'),
          radius: 50,
        ),
        const SizedBox(height: 10),
        Text(
          child['name'] ?? 'Unknown Name',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
