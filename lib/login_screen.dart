import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUp = false;
  bool _isVerification = false;
  String _userEmail = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// ✅ Ensure no old session exists before sign-in
  Future<void> _forceSignOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (_) {
      // ignore errors if already signed out
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    await _forceSignOut(); // ✅ make sure no stale session

    try {
      final result = await Amplify.Auth.signIn(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.isSignedIn) {
        _showSnackBar('Successfully signed in!', isError: false);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      } else {
        _showSnackBar('Sign-in not complete. Check your email.');
      }
    } on AuthException catch (e) {
      _showSnackBar('Sign in failed: ${e.message}');
    } catch (e) {
      _showSnackBar('Unexpected error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signUp() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await Amplify.Auth.signUp(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: _emailController.text.trim(),
          },
        ),
      );

      if (result.isSignUpComplete) {
        _showSnackBar('Account created successfully!', isError: false);
        setState(() => _isSignUp = false);
      } else {
        _userEmail = _emailController.text.trim();
        setState(() => _isVerification = true);
        _showSnackBar(
          'Please check your email for a verification code.',
          isError: false,
        );
      }
    } on AuthException catch (e) {
      _showSnackBar('Sign up failed: ${e.message}');
    } catch (e) {
      _showSnackBar('Unexpected error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _confirmSignUp() async {
    if (_verificationCodeController.text.trim().isEmpty) {
      _showSnackBar('Please enter verification code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: _userEmail,
        confirmationCode: _verificationCodeController.text.trim(),
      );

      if (result.isSignUpComplete) {
        _showSnackBar('Email verified successfully!', isError: false);
        setState(() {
          _isVerification = false;
          _isSignUp = false;
        });
      }
    } on AuthException catch (e) {
      _showSnackBar('Verification failed: ${e.message}');
    } catch (e) {
      _showSnackBar('Unexpected error: $e');
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Icon(Icons.psychology, size: 60, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text(
                "MindCompanion",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),

              if (_isVerification) ...[
                _buildTextField(
                  controller: _verificationCodeController,
                  label: 'Verification Code',
                  icon: Icons.verified_user,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
              ] else ...[
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                if (_isSignUp) ...[
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                ],
              ],

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_isVerification) {
                      _confirmSignUp();
                    } else if (_isSignUp) {
                      _signUp();
                    } else {
                      _signIn();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _isVerification
                        ? 'Verify Email'
                        : _isSignUp
                        ? 'Create Account'
                        : 'Sign In',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              if (!_isVerification)
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : 'Don’t have an account? Sign Up',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
