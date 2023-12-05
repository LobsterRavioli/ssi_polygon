import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/download_info_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:polygonid_flutter_sdk/sdk/identity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk_example/src/data/secure_storage.dart';
import 'package:polygonid_flutter_sdk_example/src/features/app.dart';
import 'package:polygonid_flutter_sdk_example/src/presentation/ui/claims/claims_event.dart';
import 'package:polygonid_flutter_sdk_example/src/state_objects/user.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

final getIt = GetIt.instance;
Future<void> main() async {

  await PolygonIdSdk.init(env: EnvEntity(
    blockchain: 'polygon',
    network: 'mumbai',
    web3Url: 'https://polygon-mumbai.infura.io/v3/',
    web3RdpUrl: 'wss://polygon-mumbai.infura.io/v3/',
    web3ApiKey: '90372d43a2b34c169d5fed6bf77fa349',
    idStateContract: '0x134B1BE34911E39A8397ec6289782989729807a4',
    pushUrl: 'https://push-staging.polygonid.com/api/v1',
    ipfsUrl: "https://2Xu7IZ4UAth3JDlcSXOJO4s8bGZ:4503df3d4f7b79f38f274d2e112dca11@ipfs.infura.io:5001",
  ));


  Stream<DownloadInfo> stream = await PolygonIdSdk.I.proof.initCircuitsDownloadAndGetInfoStream;
  getIt.registerLazySingleton<PolygonIdSdk>(() => PolygonIdSdk.I);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => FlutterSecureStorage());

  final storage = new FlutterSecureStorage();
  String? privateKey = await storage.read(key: "PRIVATE_KEY");

  User user = new User();

  if (privateKey!.isNotEmpty){
    String did = await PolygonIdSdk.I.identity.getDidIdentifier(privateKey: privateKey, blockchain: "polygon", network: "mumbai");
    IdentityEntity identity = await PolygonIdSdk.I.identity.getIdentity(genesisDid: did, privateKey: privateKey);
    user.Login();
    user.did = did;
    user.identity = identity;
    user.private_key = privateKey;
    print("did: ${user.identity} e private key: ${user.private_key}");
    user.credentials = await PolygonIdSdk.I.credential.getClaims(genesisDid: did, privateKey: privateKey);
    log(user.credentials.toString());
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => user),
      ],
      child: const App(),
    ),
  );
}

