import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk_example/main.dart';
import 'package:polygonid_flutter_sdk_example/src/presentation/ui/claims/claims_event.dart';
import 'package:polygonid_flutter_sdk_example/src/state_objects/user.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Homepage'),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 240,
                  height: 80,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "/did_page");
                    },
                    icon: Icon(Icons.person),
                    label: Text(
                      'My Identity',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: 240,
                  height: 80,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/credentials');
                    },
                    icon: Icon(Icons.security),
                    label: Text(
                      'My Credentials',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: 240,
                  height: 80,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "/option");
                    },
                    icon: Icon(Icons.settings),
                    label: Text(
                      'Options',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 56.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () async {
                    User user = context.read<User>();
                    log(user.did);
                    log(user.private_key);
                    PolygonIdSdk sdk = await getIt.get<PolygonIdSdk>();
                    String barcodeAuth =
                        await FlutterBarcodeScanner.scanBarcode(
                            '#ff6666', 'Cancel', false, ScanMode.BARCODE);

                    Iden3MessageEntity iden3messageEntity = await sdk.iden3comm
                        .getIden3Message(message: barcodeAuth);

                    sdk.iden3comm.authenticate(
                        message: iden3messageEntity,
                        genesisDid: user.did,
                        privateKey: user.private_key);

                    String barcodeCredential =
                        await FlutterBarcodeScanner.scanBarcode(
                            '#ff6666', 'Cancel', false, ScanMode.BARCODE);

                    log(barcodeCredential);
                    iden3messageEntity = await sdk.iden3comm
                        .getIden3Message(message: barcodeCredential);


                    bool confirmDownload = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Conferma'),
                          content: Text('Sei sicuro di voler scaricare le credenziali?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Annulla'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Conferma'),
                            ),
                          ],
                        );
                      },
                    );
                    if(confirmDownload){
                      List<ClaimEntity> claims =  await sdk.iden3comm.fetchAndSaveClaims(message: iden3messageEntity, genesisDid: user.did, privateKey: user.private_key);
                      claims.forEach((claim) {
                        context.read<User>().addCredentials(claim);
                      });
                    }
                  },
                ),
                IconButton(onPressed: () async {
                  User user = context.read<User>();
                  PolygonIdSdk sdk = await getIt.get<PolygonIdSdk>();
                  String barcodeAuth =
                  await FlutterBarcodeScanner.scanBarcode(
                      '#ff6666', 'Cancel', false, ScanMode.BARCODE);
                  log(barcodeAuth);
                  Iden3MessageEntity entity = await sdk.iden3comm.getIden3Message(message: barcodeAuth);

                  await sdk.iden3comm.authenticate(
                        message: entity,
                        genesisDid: user.did,
                        privateKey: user.private_key);

                  // String message =
                  // await FlutterBarcodeScanner.scanBarcode(
                  //     '#ff6666', 'Cancel', false, ScanMode.BARCODE);
                  // iden3messageEntity = await sdk.iden3comm
                  //     .getIden3Message(message: message);
                  // await sdk.iden3comm.getProofs(message: iden3messageEntity, genesisDid: user.did, privateKey: user.private_key);
                }, icon: Icon(Icons.shield))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
