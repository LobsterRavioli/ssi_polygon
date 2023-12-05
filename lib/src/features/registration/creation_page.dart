import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk_example/main.dart';
import 'package:polygonid_flutter_sdk_example/src/state_objects/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final isLogged;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<User>().logged)
        Navigator.pushNamed(context, '/homepage');
    });
    // logCheck().whenComplete(() => () async => {
    //   Timer(Duration(seconds: 2), () => isLogged == null ? Navigator.pushNamed(context, '/') : Navigator.pushNamed(context, '/homepage'))
    // });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 420.0,
          width: 420.0,
          child: const Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Image(
                    image: AssetImage("assets/icons/shield.png"),
                  width:  150,
                  height: 150,
                ),
                Text(
                  "Private Identity Wallet",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25
                  ),
                ),
                Text(
                  "Based on zero knoledge proof",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.blueAccent,
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            PolygonIdSdk sdk = await getIt.get<PolygonIdSdk>();
            FlutterSecureStorage storage = await getIt.get<FlutterSecureStorage>();
            User user = context.read<User>();
            PrivateIdentityEntity identity = await PolygonIdSdk.I.identity.addIdentity();
            user.identity = identity;
            user.Login();
            log("Chiave privata creata: ${identity.privateKey} e did: ${identity.did}");
            await storage.write(key: "PRIVATE_KEY", value:identity.privateKey);
            Navigator.pushNamed(context, '/homepage');
          },
          child: const Center(
            child: Text("Create a Wallet"),
          ),
        ),
      ),
    );
  }
}
