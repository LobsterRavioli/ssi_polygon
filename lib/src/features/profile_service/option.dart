import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk_example/main.dart';
import 'package:polygonid_flutter_sdk_example/src/state_objects/user.dart';

class OptionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Sposta il contenuto in alto
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          FlutterSecureStorage storage = getIt.get<FlutterSecureStorage>();
                          String did = context.read<User>().identity.did;
                          String privateKey = await storage.read(key: "PRIVATE_KEY") ?? "";
                          if(privateKey.isNotEmpty){
                            await getIt.get<PolygonIdSdk>().identity.removeIdentity(genesisDid: did, privateKey: privateKey);
                            storage.write(key: "PRIVATE_KEY", value:"");
                            context.read<User>().logged = false;
                            context.read<User>().credentials = [];

                            Navigator.pushNamed(context, "/");
                          }
                        },
                        child: Text('Remove Identity'),
                      ),
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
}
