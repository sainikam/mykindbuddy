import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MentalHealthApp());
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure('''{
      "auth": {
        "plugins": {
          "awsCognitoAuthPlugin": {
            "CognitoUserPool": {
              "Default": {
                "PoolId": "ap-south-1_SikSfQkK4",
                "AppClientId": "7tupm75u7lq0hq0i5nqh00t0q6",
                "Region": "ap-south-1"
              }
            },
            "Auth": {
              "Default": {
                "authenticationFlowType": "USER_SRP_AUTH"
              }
            }
          }
        }
      }
    }''');
    print("Amplify configured");
  } catch (e) {
    print("Amplify config error: $e");
  }
}

class MentalHealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindCompanion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
    );
  }
}
