import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uri? currentUri;
  String? urlPath;

  String code = "";
  late String mytoken;
  late List<Map<String, dynamic>> mdata;

  @override
  void initState() {
    super.initState();
    mytoken = '';
    mdata = [];
  }

  Future<String> getCodeFromUrl(String url) async {
    Uri uri = Uri.parse(url);

    code = uri.queryParameters['code'] ?? '';
    if (code.isNotEmpty) {
      mytoken = await getToken(code);
      mdata = await fetchData(mytoken);
      setState(() {});
    }

    return code;
  }

  void geturl() async {
    currentUri = Uri.base;
    String currentUrl = currentUri.toString();
    var code = await getCodeFromUrl(currentUrl);
    setState(() {
      urlPath = currentUrl;
    });
    print('Current URL: $urlPath');
  }

  String? token = "";

  Future<void> _authenticate() async {
    final clientId = '8f4562b21a';
    final redirectUri = 'https://vercel.com/ajays-projects-0dcf3faa/tallyweb/';
    final authUrl =
        "https://demo.extensionerp.com/api/method/frappe.integrations.oauth2.authorize?client_id=$clientId&response_type=code&grant_type=authorization_code&redirect_uri=$redirectUri";
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'myapp',
      );
      log("Result: $result");
      token = result;

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
            if (code.isNotEmpty) Text("Code $code"),
            if (code.isNotEmpty) Text("Access Token $mytoken"),
            TextButton(
              child: const Text("OAuth"),
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
            if (mdata.isNotEmpty)
              Column(
                children: [
                  Text(mdata[0]['name']),
                  Text(mdata[0]['creation']),
                  Text(mdata[0]['first_name'])
                ],
              )
          ],
        ),
      ),
    );
  }
}

Dio dio = Dio();
Future<String> getToken(String authCode) async {
  String apiUrl =
      'https://demo.extensionerp.com/api/method/frappe.integrations.oauth2.get_token';
  String redirectUri = 'https://vercel.com/ajays-projects-0dcf3faa/tallyweb/';
  String clientId = '8f4562b21a';

  try {
    String accessToken;
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
        'code': authCode,
        'redirect_uri': Uri.encodeFull(redirectUri),
        'client_id': clientId,
      },
    );

    if (response.statusCode == 200) {
      accessToken = response.data['access_token'];

      print('Access Token: $accessToken');
      return accessToken;
    } else {
      print('Non-200 status code: ${response.statusCode}');
      throw Exception('Failed to get access token');
    }
  } catch (error) {
    print('Error: $error');
    throw Exception('Failed to get access token');
  }
}

Future<List<Map<String, dynamic>>> fetchData(String accessToken) async {
  final url =
      Uri.parse('https://demo.extensionerp.com/api/resource/Lead?fields=["*"]');

  try {
    final response = await dio.get(
      '$url',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
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
      throw Exception('Failed to fetch data');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to fetch data');
  }
}
