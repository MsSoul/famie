//filename:signup_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:logger/logger.dart';
import 'services/api_service.dart';
import 'design/theme.dart';
import 'main.dart';
import 'design/notification_prompts.dart'; // Import the notification prompts

class ParentSignupForm extends StatefulWidget {
  const ParentSignupForm({super.key});

  @override
  State<ParentSignupForm> createState() => _ParentSignupFormState();
}

class _ParentSignupFormState extends State<ParentSignupForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _emailError = '';
  String _usernameError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  // Helper method to validate email
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  // Helper method to validate username
  bool _isValidUsername(String username) {
    return username.isNotEmpty;
  }

  // Helper method to validate password
  bool _isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  void _validateEmail() {
    if (!_isValidEmail(emailController.text)) {
      setState(() {
        _emailError = 'Invalid email format';
      });
    } else {
      setState(() {
        _emailError = '';
      });
    }
  }

  void _validateUsername() {
    if (!_isValidUsername(usernameController.text)) {
      setState(() {
        _usernameError = 'Invalid username';
      });
    } else {
      setState(() {
        _usernameError = '';
      });
    }
  }

  void _validatePassword() {
    if (!_isValidPassword(passwordController.text)) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
    } else {
      setState(() {
        _passwordError = '';
      });
    }
  }

  void _validateConfirmPassword() {
    if (confirmPasswordController.text != passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
    } else {
      setState(() {
        _confirmPasswordError = '';
      });
    }
  }

  void _onSignupPressed() async {
    _validateEmail();
    _validateUsername();
    _validatePassword();
    _validateConfirmPassword();

    if (_emailError.isEmpty && _usernameError.isEmpty && _passwordError.isEmpty && _confirmPasswordError.isEmpty) {
      try {
        _logger.d('Attempting sign up with: ${emailController.text}, ${usernameController.text}');
        bool success = await _apiService.signUp(
          emailController.text,
          usernameController.text,
          passwordController.text,
        );
        _logger.d('Sign up success: $success');
        if (!mounted) return;
        if (success) {
          _logger.d('Signup successful');
          showSuccessPrompt(context); // Show success prompt
        } else {
          _logger.e('Signup failed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup failed')),
          );
        }
      } catch (e) {
        _logger.e('Signup failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        _validateEmail();
      }
    });

    usernameFocusNode.addListener(() {
      if (!usernameFocusNode.hasFocus) {
        _validateUsername();
      }
    });

    passwordFocusNode.addListener(() {
      if (!passwordFocusNode.hasFocus) {
        _validatePassword();
      }
    });

    confirmPasswordFocusNode.addListener(() {
      if (!confirmPasswordFocusNode.hasFocus) {
        _validateConfirmPassword();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Sign Up', isLoggedIn: false),
      body: SingleChildScrollView(
        padding: appMargin,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                focusNode: emailFocusNode,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailError.isNotEmpty ? _emailError : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                focusNode: usernameFocusNode,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: _usernameError.isNotEmpty ? _usernameError : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _passwordError.isNotEmpty ? _passwordError : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                focusNode: confirmPasswordFocusNode,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  errorText: _confirmPasswordError.isNotEmpty ? _confirmPasswordError : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSignupPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                  foregroundColor: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                  textStyle: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}),
                  shape: Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({}),
                ),
                child: const Text('Create'),
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: 'Already using Famie? ',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black, fontFamily: 'Georgia'),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Log in',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 16.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}