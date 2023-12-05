import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polygonid_flutter_sdk_example/src/features/credentials_service/check_page.dart';
import 'package:polygonid_flutter_sdk_example/src/features/credentials_service/credentials.dart';
import 'package:polygonid_flutter_sdk_example/src/features/profile_service//did_page.dart';
import 'package:polygonid_flutter_sdk_example/src/features/profile_service/homepage.dart';
import 'package:polygonid_flutter_sdk_example/src/features/profile_service/option.dart';
import 'package:polygonid_flutter_sdk_example/src/features/registration/creation_page.dart';

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      routes: {
        '/': (context) => LoginPage(),
        '/homepage': (context) => HomePage(),
        '/did_page': (context) => DidInfo(),
        '/option': (context) => OptionsWidget(),
        '/credentials': (context) => CredentialsPage()
      },
    );
  }


}
