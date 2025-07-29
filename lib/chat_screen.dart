import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:http/http.dart' as http;

import 'login_screen.dart'; // Make sure this matches your project structure

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  String? _currentUserId;
  String? _authToken;

  final String lambdaUrl =
      "https://lcmchmrnl8.execute-api.us-east-1.amazonaws.com/prod/journal";

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    try {
      final session =
      await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        final tokens = session.userPoolTokensResult.valueOrNull;
        _authToken = tokens?.idToken.raw; // ✅ Token as string
        final user = await Amplify.Auth.getCurrentUser();
        setState(() {
          _currentUserId = user.userId;
        });
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint("Session error: $e");
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
      _navigateToLogin();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _controller.clear();
      _isTyping = true;
    });

    try {
      final response = await http.post(
        Uri.parse(lambdaUrl),
        headers: {
          "Authorization": _authToken ?? "",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "text": userMessage,
          "userId": _currentUserId ??
              "flutter_user_${DateTime.now().millisecondsSinceEpoch}",
        }),
      );

      String botReply;
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        botReply =
            responseData['reply'] ?? "I'm not sure how to respond to that.";
      } else {
        botReply = "Error ${response.statusCode}: Unable to process request.";
      }

      setState(() {
        _messages.add({"sender": "bot", "text": botReply});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text":
          "Network error. Please check your internet connection.",
        });
      });
    }

    setState(() => _isTyping = false);
  }

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg["sender"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          msg["text"] ?? "",
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.deepPurple[800] : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "MindCompanion", // ✅ Heart removed
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                return _buildMessage(msg);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0, left: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Bot is typing..."),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isTyping,
                      decoration: InputDecoration(
                        hintText: "How are you feeling today?",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) =>
                      !_isTyping ? _sendMessage() : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor:
                    _isTyping ? Colors.grey : Colors.deepPurple,
                    child: IconButton(
                      icon: Icon(
                        _isTyping ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: !_isTyping ? _sendMessage : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
