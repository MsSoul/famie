//filename: services/child_database_services.dart
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logging/logging.dart';

class DatabaseService {
  // Singleton pattern implementation
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  Db? _db;
  final Logger _logger = Logger('DatabaseService');

  DatabaseService._internal();

  // Getter for the database connection
  Future<Db> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Initialize the MongoDB connection
  Future<Db> _initDatabase() async {
    try {
      final dbUri = Platform.environment['MONGODB_URI'] ?? 'mongodb+srv://your-username:your-password@cluster0.yz9ynbq.mongodb.net/your-database-name';
      _db = Db(dbUri);
      await _db!.open();
      _logger.info('Connected to MongoDB');
    } catch (e) {
      _logger.severe('Failed to connect to MongoDB: $e');
      rethrow; // Rethrow the error after logging
    }
    return _db!;
  }

  // Method to close the database connection
  Future<void> closeDatabase() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      _logger.info('Database connection closed');
    }
  }

  // Insert a new child profile
 /* Future<void> insertChild(String parentId, String name, String avatar, String deviceName, String macAddress) async {
    _logger.info('Inserting child: parentId=$parentId, name=$name, avatar=$avatar, deviceName=$deviceName, macAddress=$macAddress');
    if (parentId.isEmpty || name.isEmpty || deviceName.isEmpty || macAddress.isEmpty) {
      _logger.warning('Invalid input data for insertChild');
      throw Exception('Invalid input data');
    }

    ObjectId parentObjectId;
    try {
      parentObjectId = ObjectId.parse(parentId);
    } catch (e) {
      _logger.severe('Invalid ObjectId format for parentId: $parentId');
      throw Exception('Invalid ObjectId format');
    }

    final db = await database;
    final collection = db.collection('child_profile');
    try {
      _logger.info('Inserting child into MongoDB...');
      var result = await collection.insertOne({
        'parent_id': parentObjectId,
        'name': name,
        'avatar': avatar,
        'device_name': deviceName,
        'mac_address': macAddress,
      });
      _logger.info('Insert successful: ${result.id}');
    } catch (e, stackTrace) {
      _logger.severe('Failed to insert child: $e', stackTrace);
      throw Exception('Failed to insert child: $e'); // Throw an exception to handle it later
    }
  }*/

  // Fetch children profiles based on parentId
  Future<List<Map<String, dynamic>>> getChildren(String parentId) async {
    if (parentId.isEmpty) {
      _logger.warning('Invalid parentId for getChildren');
      throw Exception('Invalid parentId');
    }

    // Validate ObjectId parsing
    ObjectId parentObjectId;
    try {
      parentObjectId = ObjectId.parse(parentId);
    } catch (e) {
      _logger.severe('Invalid ObjectId format for parentId: $parentId');
      throw Exception('Invalid ObjectId format');
    }

    final db = await database;
    final collection = db.collection('child_profile');
    try {
      _logger.info('Fetching children for parentId: $parentId');
      final children = await collection.find(where.eq('parent_id', parentObjectId)).toList();
      _logger.info('Fetched children: $children');
      return children;
    } catch (e) {
      _logger.severe('Failed to fetch children: $e');
      return []; // Return an empty list on error
    }
  }

  // Insert a new app management entry
  Future<void> insertApp(String childId, String name, String icon, bool isAllowed) async {
    if (childId.isEmpty || name.isEmpty || icon.isEmpty) {
      _logger.warning('Invalid input data for insertApp');
      throw Exception('Invalid input data');
    }

    // Validate ObjectId parsing
    ObjectId childObjectId;
    try {
      childObjectId = ObjectId.parse(childId);
    } catch (e) {
      _logger.severe('Invalid ObjectId format for childId: $childId');
      throw Exception('Invalid ObjectId format');
    }

    final db = await database;
    final collection = db.collection('app_management');
    try {
      _logger.info('Inserting app into MongoDB...');
      await collection.insertOne({
        'child_id': childObjectId,
        'app_name': name,
        'package_name': icon,
        'is_allowed': isAllowed,
      });
      _logger.info('App inserted: $name');
    } catch (e) {
      _logger.severe('Failed to insert app: $e');
      throw Exception('Failed to insert app: $e'); // Throw an exception to handle it later
    }
  }

  // Fetch apps based on childId
  Future<List<Map<String, dynamic>>> getApps(String childId) async {
    if (childId.isEmpty) {
      _logger.warning('Invalid childId for getApps');
      throw Exception('Invalid childId');
    }

    // Validate ObjectId parsing
    ObjectId childObjectId;
    try {
      childObjectId = ObjectId.parse(childId);
    } catch (e) {
      _logger.severe('Invalid ObjectId format for childId: $childId');
      throw Exception('Invalid ObjectId format');
    }

    final db = await database;
    final collection = db.collection('app_management');
    try {
      _logger.info('Fetching apps for childId: $childId');
      final apps = await collection.find(where.eq('child_id', childObjectId)).toList();
      _logger.info('Fetched apps: $apps');
      return apps;
    } catch (e) {
      _logger.severe('Failed to fetch apps: $e');
      return []; // Return an empty list on error
    }
  }

  // Update an app's allowed status
  Future<void> updateApp(String id, bool isAllowed) async {
    if (id.isEmpty) {
      _logger.warning('Invalid id for updateApp');
      throw Exception('Invalid id');
    }

    // Validate ObjectId parsing
    ObjectId appObjectId;
    try {
      appObjectId = ObjectId.parse(id);
    } catch (e) {
      _logger.severe('Invalid ObjectId format for id: $id');
      throw Exception('Invalid ObjectId format');
    }

    final db = await database;
    final collection = db.collection('app_management');
    try {
      _logger.info('Updating app status for id: $id');
      await collection.updateOne(
        where.id(appObjectId),
        modify.set('is_allowed', isAllowed),
      );
      _logger.info('App updated: $id');
    } catch (e) {
      _logger.severe('Failed to update app: $e');
      throw Exception('Failed to update app: $e'); // Throw an exception to handle it later
    }
  }

  // Save time management data
  Future<void> saveTimeManagement(List<Map<String, String>> schedules, Duration totalScreenTime) async {
    if (schedules.isEmpty) {
      _logger.warning('Invalid schedules data for saveTimeManagement');
      throw Exception('Invalid schedules data');
    }

    final db = await database;
    final collection = db.collection('time_management');
    try {
      _logger.info('Saving time management data to MongoDB...');
      await collection.insertOne({
        'schedules': schedules,
        'total_screen_time': totalScreenTime.inMinutes,
      });
      _logger.info('Time management data saved successfully');
    } catch (e) {
      _logger.severe('Failed to save time management data: $e');
      throw Exception('Failed to save time management data: $e'); // Throw an exception to handle it later
    }
  }
}
