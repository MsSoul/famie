// filename:main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'child_profile/child_profile_provider.dart';
import 'services/api_service.dart';
import 'services/theme_service.dart';
import 'design/theme.dart';
import 'signup_form.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensure all bindings are initialized

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<ThemeData> _loadTheme() async {
    final themeService = ThemeService();
    String adminId = '66965e1ebfcd686202c11838'; // Example adminId, adjust accordingly
    return await themeService.fetchTheme(adminId);  // Pass the correct admin_id here
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChildProfileProvider(),  // Initialize ChildProfileProvider
      child: FutureBuilder<ThemeData>(
        future: _loadTheme(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error loading theme: ${snapshot.error}'),
                ),
              ),
            );
          } else {
            return MaterialApp(
              theme: snapshot.data,
              home: const LoginScreen(),
            );
          }
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var logger = Logger();
  ApiService apiService = ApiService();
  bool _obscureText = true;

  Future<void> _login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    logger.d('Attempting login with username: $username');

    try {
      var result = await apiService.login(username, password);
      logger.d('Login response: $result');
      if (result['success']) {
        logger.d('Login successful');
        _navigateToHome(result['parentId']);
      } else {
        logger.d('Login failed');
        _showDialog('Invalid username or password');
      }
    } catch (e) {
      logger.e('Exception during login: $e');
      _showDialog('An error occurred. Please try again.');
    }
  }

  void _navigateToHome(String parentId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(parentId: parentId)),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Login Screen', isLoggedIn: false, parentId: ''), // No parentId needed here yet
      body: SingleChildScrollView(
        child: Container(
          margin: appMargin,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Parent!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  color: Colors.green[700],
                ),
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
                style: const TextStyle(color: Colors.black),
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                    foregroundColor: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                    textStyle: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}),
                    shape: Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({}),
                  ),
                  child: const Text('Log In'),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      "Don’t have an account?  ",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontFamily: 'Georgia',
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ParentSignupForm()),
                      );
                    },
                    child: Text(
                      "Create one",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.green[700],
                        decoration: TextDecoration.underline,
                        fontFamily: 'Georgia',
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
import 'package:famie_one/services/child_database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'child_profile/child_profile_provider.dart';
import 'services/api_service.dart';
import 'services/theme_service.dart';
import 'design/theme.dart';
import 'signup_form.dart';
import 'home.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized(); // Ensure all bindings are initialized
  DatabaseService dbService = DatabaseService();

  try {
    await dbService.database; // Attempt to connect to the database
    if (kDebugMode) {
      print('MongoDB connection successful');
    }
  } catch (e) {
    if (kDebugMode) {
      print('MongoDB connection failed: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<ThemeData> _loadTheme() async {
    final themeService = ThemeService();
    return await themeService.fetchTheme('66965e1ebfcd686202c11838'); // Pass the correct admin_id
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
      future: _loadTheme(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error loading theme: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return MaterialApp(
            theme: snapshot.data,
            home: const LoginScreen(),
          );
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  var logger = Logger();
  ApiService apiService = ApiService();
  bool _obscureText = true;

  Future<void> _login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    logger.d('Attempting login with username: $username');

    try {
      var result = await apiService.login(username, password);
      logger.d('Login response: $result');
      if (result['success']) {
        logger.d('Login successful');
        _navigateToHome(result['parentId']);
      } else {
        logger.d('Login failed');
        _showDialog('Invalid username or password');
      }
    } catch (e) {
      logger.e('Exception during login: $e');
      _showDialog('An error occurred. Please try again.');
    }
  }

  void _navigateToHome(String parentId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(parentId: parentId)),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Login Screen'),
      body: SingleChildScrollView(
        child: Container(
          margin: appMargin,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Parent!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  color: Colors.green[700],
                ),
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
                style: const TextStyle(color: Colors.black), // Set input text color to black
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                style: const TextStyle(color: Colors.black), // Set input text color to black
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[200],
                ),
                child: const Text('Log In'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      "Don’t have an account?  ",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontFamily: 'Georgia',
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ParentSignupForm()),
                      );
                    },
                    child: Text(
                      "Create one",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.green[700],
                        decoration: TextDecoration.underline,
                        fontFamily: 'Georgia',
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/