import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo; // Use 'as' to avoid conflicts with Flutter's State class
import '../services/child_database_service.dart'; // Import your database service
import '../algorithm/decision_tree.dart'; // Import the DecisionTree class

class AppManagement extends StatefulWidget {
  final String parentId;

  const AppManagement({super.key, required this.parentId});

  @override
  AppManagementState createState() => AppManagementState();
}

class AppManagementState extends State<AppManagement> {
  final DatabaseService dbHelper = DatabaseService(); // Instance of your database service
  List<Map<String, dynamic>> apps = []; // List to store the apps fetched from MongoDB
  bool isLoading = true; // Boolean to manage the loading state
  final Logger _logger = Logger('AppManagement'); // Logger for debugging

  // Instantiate your DecisionTree with specific theta1 and theta2 values
  final DecisionTree decisionTree = DecisionTree(theta1: 0.5, theta2: 0.5);

  @override
  void initState() {
    super.initState();
    fetchChildAndApps(); // Fetch the child profiles and apps when the widget is initialized
  }

  void fetchChildAndApps() async {
    try {
      _logger.info("Fetching child profiles for parentId: ${widget.parentId}");
      List<Map<String, dynamic>> children = await dbHelper.getChildren(widget.parentId);

      if (children.isNotEmpty) {
        String childId = children.first['_id'].toString();
        _logger.info("Child found. Fetching apps for childId: $childId");
        fetchApps(childId); // Fetch apps for the first child
      } else {
        setState(() {
          isLoading = false; // Stop loading if no children are found
        });
        _logger.warning("No children found for parentId: ${widget.parentId}");
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading if there's an error
      });
      _logger.severe("Error fetching child profiles", e);
    }
  }

  void fetchApps(String childId) async {
    try {
      // Log the childId being used in the query
      _logger.info('Child ID to be queried: $childId');

      // Get the database instance
      final db = await dbHelper.database;

      // Access the 'app_management' collection
      final collection = db.collection('app_management');

      // Query the collection using the provided childId
      final result = await collection.findOne(mongo.where.eq('child_id', mongo.ObjectId.parse(childId)));

      // Log the result from MongoDB
      _logger.info('Result from MongoDB: $result');

      // Check if the result is not null (i.e., data was found)
      if (result != null) {
        List<Map<String, dynamic>> appList = [];

        // Loop through the nested objects in the result document
        result.forEach((key, value) {
          if (key != 'child_id') { // Skip the child_id field
            appList.add({
              'app_name': key,
              'package_name': value['package_name'],
              'is_allowed': value['is_allowed'],
            });
          }
        });

        // If the widget is still mounted, update the UI
        if (mounted) {
          setState(() {
            apps = appList;
            isLoading = false; // Stop loading once data is fetched
          });
        }

        // Log the list of apps retrieved
        _logger.info('Apps List: $apps');
      } else {
        // If no data found, stop loading and display the 'No apps found' message
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // If there's an error, stop loading and log the error
      setState(() {
        isLoading = false;
      });
      _logger.severe("Error fetching apps", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Management'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Display a loading indicator while fetching data
          : apps.isEmpty
              ? const Center(child: Text("No apps found.")) // Show a message if no apps are found
              : ListView.builder(
                  itemCount: apps.length, // Number of apps to display
                  itemBuilder: (context, index) {
                    Map<String, dynamic> app = apps[index]; // Get each app from the list
                    return ListTile(
                      leading: Image.asset(
                        'assets/icons/${app['package_name']}.png', // Display the app icon
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.apps); // Fallback icon if the image is not found
                        },
                      ),
                      title: Text(app['app_name']), // Display the app name
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: app['is_allowed'] ? Colors.green : Colors.grey, // Button color based on the app's allowed status
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              toggleApp(app['app_name'], true); // Allow the app when the button is pressed
                            },
                            child: const Text('Allow'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: !app['is_allowed'] ? Colors.red : Colors.grey, // Button color based on the app's allowed status
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              toggleApp(app['app_name'], false); // Disallow the app when the button is pressed
                            },
                            child: const Text('Disallow'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void toggleApp(String appName, bool isAllowed) async {
    try {
      // Example inputs for the decision-making process, replace with actual logic
      double x1 = 0.4; // This could be based on app usage, time, etc.
      double x2 = 0.7; // Another parameter for decision-making

      // Use the decision tree to decide the action
      String decision = decisionTree.decide(x1, x2);
      bool shouldAllow = decision == 'Allow';

      // Update the database based on the decision
      await dbHelper.updateApp(appName, shouldAllow);

      // Refresh the app list after updating
      fetchApps(widget.parentId);

      _logger.info("Toggled app $appName to isAllowed: $shouldAllow");
    } catch (e) {
      _logger.severe("Error updating app", e);
    }
  }
}
