//filename: child_profile/child_profiling.dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../child_profile/child_profile_manager.dart';

class ChildProfiles extends StatefulWidget {
  final Map<String, String>? selectedChild;
  final Function(Map<String, String>) onChildSelected;
  final Function onAddChild;
  final String parentId;

  const ChildProfiles({
    super.key,
    required this.selectedChild,
    required this.onChildSelected,
    required this.onAddChild,
    required this.parentId,
  });

  @override
  _ChildProfilesState createState() => _ChildProfilesState();
}

class _ChildProfilesState extends State<ChildProfiles> {
  late ChildProfileManager _childProfileManager;
  List<Map<String, String>> _children = [];
  final Logger _logger = Logger('ChildProfiles');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _childProfileManager = ChildProfileManager();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      _logger.info('Loading children for parentId: ${widget.parentId}');
      await _childProfileManager.loadChildren(widget.parentId);
      if (mounted) {
        setState(() {
          _children = _childProfileManager.getChildren();
          _isLoading = false; // Stop loading indicator
        });
      }
      _logger.info('Children loaded: $_children');
    } catch (e) {
      _logger.severe('Failed to load children: $e');
      setState(() {
        _isLoading = false; // Stop loading if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const CircularProgressIndicator(), // Show loading indicator while fetching

        if (!_isLoading && _children.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No children available'),
          ),

        if (!_isLoading && _children.isNotEmpty)
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: child['avatar'] != null
                        ? AssetImage(child['avatar']!)
                        : const AssetImage('assets/avatar/default_avatar.png'), // Fallback image
                  ),
                  title: Text(child['name'] ?? 'No Name'),
                  selected: _areChildrenEqual(widget.selectedChild, child),
                  onTap: () => widget.onChildSelected(child),
                );
              },
            ),
          ),

        ElevatedButton(
          onPressed: () => widget.onAddChild(),
          child: const Text('Add Child'),
        ),
      ],
    );
  }

  bool _areChildrenEqual(Map<String, String>? child1, Map<String, String>? child2) {
    if (child1 == null || child2 == null) return false;
    return child1['name'] == child2['name'] && child1['avatar'] == child2['avatar'];
  }
}

/*
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../child_profile/child_profile_manager.dart';

class ChildProfiles extends StatefulWidget {
  final Map<String, String>? selectedChild;
  final Function(Map<String, String>) onChildSelected;
  final Function onAddChild;
  final String parentId;

  const ChildProfiles({
    super.key,
    required this.selectedChild,
    required this.onChildSelected,
    required this.onAddChild,
    required this.parentId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChildProfilesState createState() => _ChildProfilesState();
}

class _ChildProfilesState extends State<ChildProfiles> {
  late ChildProfileManager _childProfileManager;
  List<Map<String, String>> _children = [];
  final Logger _logger = Logger('ChildProfiles');

  @override
  void initState() {
    super.initState();
    _childProfileManager = ChildProfileManager();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      await _childProfileManager.loadChildren(widget.parentId);
      if (mounted) {
        setState(() {
          _children = _childProfileManager.getChildren();
        });
      }
      _logger.info('Children loaded: $_children');
    } catch (e) {
      _logger.severe('Failed to load children: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _children.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No children available'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _children.length,
                itemBuilder: (context, index) {
                  final child = _children[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: child['avatar'] != null ? AssetImage(child['avatar']!) : null,
                    ),
                    title: Text(child['name'] ?? 'No Name'),
                    selected: _areChildrenEqual(widget.selectedChild, child),
                    onTap: () => widget.onChildSelected(child),
                  );
                },
              ),
        ElevatedButton(
          onPressed: () => widget.onAddChild(),
          child: const Text('Add Child'),
        ),
      ],
    );
  }

  bool _areChildrenEqual(Map<String, String>? child1, Map<String, String>? child2) {
    if (child1 == null || child2 == null) return false;
    return child1['name'] == child2['name'] && child1['avatar'] == child2['avatar'];
  }
}*/