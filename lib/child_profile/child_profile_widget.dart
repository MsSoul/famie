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
    // Get theme colors and font styles
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color; // Updated reference to text color
    final textFontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;

    return Column(
      children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: 135, // Adjust height as needed
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: children.length + 1, // +1 for the "Add Child" button
                        itemBuilder: (context, index) {
                          if (index == children.length) {
                            return _buildAddChildButton(appBarColor, textFontFamily);
                          }
                          return _buildChildAvatar(children[index], appBarColor, textFontFamily, textColor);
                        },
                      ),
                    ),
                  ),
                  Divider(
                    color: appBarColor, // Use AppBar color for divider
                    height: 0.5, // Slightly reduced height to minimize space
                    thickness: 1, // Set thickness for better visibility
                  ),
                ],
              ),
      ],
    );
  }

  // Build child avatar item
  Widget _buildChildAvatar(Map<String, String> child, Color? appBarColor, String? fontFamily, Color? textColor) {
    bool isSelected = _selectedChild != null && _selectedChild!['childId'] == child['childId'];

    // Capitalize first letter of each word in the child's name
    String childName = (child['name'] ?? 'Unknown').split(' ').map((word) {
      return word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : word;
    }).join(' ');

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
                  border: Border.all(
                    color: isSelected ? appBarColor! : Colors.white, // Use AppBar color for selected child
                    width: 5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: appBarColor, // Use AppBar color for selected dot
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.only(right: 5),
                  ),
                Text(
                  childName, // Display the capitalized name
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold for selected child
                    fontFamily: fontFamily, // Use the theme font
                    color: textColor, // Use the theme text color
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build "Add Child" button
  Widget _buildAddChildButton(Color? appBarColor, String? fontFamily) {
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
                    color: appBarColor!, // Use AppBar color for Add Child button border
                    width: 4, // Border width
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: appBarColor, // Use AppBar color for Add Child icon
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Child',
              style: TextStyle(
                color: appBarColor, // Use AppBar color for Add Child text
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily, // Use the theme font
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*e modify kay mag butang ug no child added
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
    // Get theme colors and font styles
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color; // Updated reference to text color
    final textFontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;

    return Column(
      children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: 135, // Adjust height as needed
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: children.length + 1, // +1 for the "Add Child" button
                        itemBuilder: (context, index) {
                          if (index == children.length) {
                            return _buildAddChildButton(appBarColor, textFontFamily);
                          }
                          return _buildChildAvatar(children[index], appBarColor, textFontFamily, textColor);
                        },
                      ),
                    ),
                  ),
                  Divider(
                    color: appBarColor, // Use AppBar color for divider
                    height: 0.5, // Slightly reduced height to minimize space
                    thickness: 1, // Set thickness for better visibility
                  ),
                ],
              ),
      ],
    );
  }

  // Build child avatar item
  Widget _buildChildAvatar(Map<String, String> child, Color? appBarColor, String? fontFamily, Color? textColor) {
    bool isSelected = _selectedChild != null && _selectedChild!['childId'] == child['childId'];

    // Capitalize first letter of each word in the child's name
    String childName = (child['name'] ?? 'Unknown').split(' ').map((word) {
      return word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : word;
    }).join(' ');

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
                  border: Border.all(
                    color: isSelected ? appBarColor! : Colors.white, // Use AppBar color for selected child
                    width: 5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: appBarColor, // Use AppBar color for selected dot
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.only(right: 5),
                  ),
                Text(
                  childName, // Display the capitalized name
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold for selected child
                    fontFamily: fontFamily, // Use the theme font
                    color: textColor, // Use the theme text color
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build "Add Child" button
  Widget _buildAddChildButton(Color? appBarColor, String? fontFamily) {
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
                    color: appBarColor!, // Use AppBar color for Add Child button border
                    width: 4, // Border width
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: appBarColor, // Use AppBar color for Add Child icon
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Child',
              style: TextStyle(
                color: appBarColor, // Use AppBar color for Add Child text
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily, // Use the theme font
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*update and design 
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
                  height: 135, // Adjust height as needed
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
               const Divider(
  color: Colors.green,
  height: 0.5, // Slightly reduced height to minimize space
  thickness: 1, // Set thickness for better visibility
),
                // Removed the selected child's avatar and name below.
              ],
            ),
    ],
  );
}

  // Build child avatar item
  // Build child avatar item
Widget _buildChildAvatar(Map<String, String> child) {
  bool isSelected = _selectedChild != null && _selectedChild!['childId'] == child['childId'];

  // Capitalize first letter of each word in the child's name
  String childName = (child['name'] ?? 'Unknown').split(' ').map((word) {
    return word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : word;
  }).join(' ');

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
                border: Border.all(color: isSelected ? Colors.green : Colors.white, width: 5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green, // Green dot for selected child
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(right: 5),
                ),
              Text(
                childName,  // Display the capitalized name
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold for selected child
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
}
*/

/*
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
}*/
