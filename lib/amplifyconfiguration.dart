const amplifyconfig = '''
{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-south-1_YourPoolId",
                        "AppClientId": "7u9jsqvmhekcrdn9b2ri147r8f",
                        "Region": "ap-south-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "OAuth": {
                            "WebDomain": "ap-south-1ywdi1jpsy.auth.ap-south-1.amazoncognito.com",
                            "AppClientId": "7u9jsqvmhekcrdn9b2ri147r8f",
                            "SignInRedirectURI": "https://d84l1y8p4kdic.cloudfront.net",
                            "SignOutRedirectURI": "https://d84l1y8p4kdic.cloudfront.net",
                            "Scopes": [
                                "phone",
                                "email",
                                "openid"
                            ]
                        },
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [
                            "email"
                        ],
                        "signupAttributes": [
                            "email"
                        ],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [
                            "SMS"
                        ],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                }
            }
        }
    }
}''';
