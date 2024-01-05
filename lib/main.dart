import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'package:oauth_dio/oauth_dio.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uri? currentUri;
  String? urlPath;
  @override
  void initState() {
    super.initState();
  }

  String code = "";
  var mytoken;
  List<Map<String, dynamic>> mdata = [];
  Future<String> getCodeFromUrl(String url) async {
    Uri uri = Uri.parse(url);

    code = uri.queryParameters['code'] ?? '';
    if (code != null) {
      mytoken = await getToken(code!);
      mdata = await fetchData(mytoken);
      setState(() {});
    } else {}

    return code!;
  }

  void geturl() async {
    currentUri = Uri.base;
    String currentUrl = currentUri.toString();
    var code = await getCodeFromUrl(currentUrl);
    setState(() {
      urlPath = currentUrl;
    });
    print('Current URL: $urlPath  ');
  }

  String? token = "";

  Future<void> _authenticate() async {
    final clientId = '8f4562b21a';
    final redirectUri = 'https://vercel.com/ajays-projects-0dcf3faa/tallyweb/';
    final authUrl =
        "https://demo.extensionerp.com/api/method/frappe.integrations.oauth2.authorize?client_id=$clientId&response_type=code&grant_type=Authorization Code&redirect_uri=$redirectUri";
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'myapp',
      );
      log("Result${result}");
      token = "Result${result}";

      print(result);
    } catch (e) {
      log(e.toString());
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("URL $urlPath"),
            code.isEmpty ? SizedBox() : Text("Code $code"),
            code.isEmpty ? SizedBox() : Text("acess tokenCode $mytoken"),
            TextButton(
              child: const Text("Oauth"),
              onPressed: () {
                _authenticate();
              },
            ),
            TextButton(
              child: const Text("getUrl"),
              onPressed: () {
                geturl();
              },
            ),
            mdata.isNotEmpty
                ? Column(
                    children: [
                      Text(mdata[0]['name']),
                      Text(mdata[0]['creation']),
                      Text(mdata[0]['first_name'])
                    ],
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}

// Future authenticateWeb() async {
//   final oauth = OAuth(
//       clientId: '8f4562b21a',
//       clientSecret: '8d1af1363a',
//       tokenUrl:
//           'https://demo.extensionerp.com/api/method/frappe.integrations.oauth2.authorize?client_id=8f4562b21a&response_type=code&grant_type=Authorization%20Code&redirect_uri=https://demo.extensionerp.com/login');

//   oauth
//       .requestToken(
//           PasswordGrant(username: 'Administrator', password: 'admin1234'))
//       .then((token) {
//     log('AccessToken: ${token.accessToken}');
//     log('RefreshToken: ${token.refreshToken}');
//     log('Expiration: ${token.expiration}');
//   });
// }

Dio dio = Dio();
Future<String> getToken(String authCode) async {
  Dio dio = Dio();

  String apiUrl =
      'https://demo.extensionerp.com/api/method/frappe.integrations.oauth2.get_token';
  String redirectUri = 'https://vercel.com/ajays-projects-0dcf3faa/tallyweb/';
  String clientId = '8f4562b21a';
  String code = authCode;

  try {
    String? accessToken;
    Response response = await dio.post(
      apiUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      ),
      data: {
        'grant_type': 'authorization_code',
        'code': '$code',
        'redirect_uri': Uri.encodeFull(redirectUri),
        'client_id': clientId,
      },
    );

    // Check if the response status code is 200
    if (response.statusCode == 200) {
      // Handle the access token and other properties
      accessToken = response.data['access_token'];

      print('Access Tokens: $accessToken');
    } else {
      print('Non-200 status code: ${response.statusCode}');
    }
    return accessToken!;
  } catch (error) {
    print('Error: $error');
    return '';
  }
}

Future<List<Map<String, dynamic>>> fetchData(String accesstoken) async {
  final Url =
      Uri.parse('https://demo.extensionerp.com/api/resource/Lead?fields=["*"]');

  try {
    final response = await dio.get(
      '$Url',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accesstoken',
        },
      ),
    );
    List<Map<String, dynamic>> mylist = [];
    print("response ${response}");
    if (response.statusCode == 200) {
      // Successful request, parse the response JSON
      response.data['data'].forEach((value) {
        mylist.add(value);
        log("my value $value");
      });
      return mylist;
    } else {
      log("Failed login ");
      throw Exception('Failed login');
    }
  } catch (e) {
    print('Error: $e');
    throw e;
  }
}
