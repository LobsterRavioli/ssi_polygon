import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/download_info_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk_example/src/common/env.dart';
import 'package:polygonid_flutter_sdk_example/src/presentation/dependency_injection/dependencies_provider.dart'
as di;
import 'package:polygonid_flutter_sdk_example/src/presentation/ui/claims/claims_event.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:convert/convert.dart'; // convert bytes to hexadecimal and vice-versa
import 'package:bip39/bip39.dart' as bip39;

const String SECRET = "prva";
const SERVER_LOCATION = "http://172.19.224.128:3002";

Future<void> main() async {
  // Dependency Injection initialization

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
  // we get the sdk instance previously initialized
  final sdk = PolygonIdSdk.I;

  try{
    IdentityEntity lol;
    PrivateIdentityEntity new_user = await sdk.identity.addIdentity(secret: "pr0va");
    print("private key:${new_user.privateKey}");
    print(new_user.did);


  } on IdentityAlreadyExistsException catch (e) {
    print('Eccezione catturata: $e');
  }

  // Ottengo tutte le identità presenti sul wallet
  List<IdentityEntity> list = await sdk.identity.getIdentities();
  log(list.toString());

  String private_key = await sdk.identity.getPrivateKey(secret: SECRET);
  print("CHIAVE PRIVATA ${private_key}");


  String did = await sdk.identity.getDidIdentifier(privateKey: private_key, blockchain: "polygon", network: "mumbai");
  print("DID : ${did}");

  String url = SERVER_LOCATION + '/v1/authentication/qrcode';
  String body = await fetchJsonDataFromUrl(url);

  Iden3MessageEntity iden3messageEntity = await sdk.iden3comm.getIden3Message(message: body);

  await sdk.iden3comm.authenticate(message: iden3messageEntity, genesisDid: "did:polygonid:polygon:mumbai:2qMFAMVw6U745JbnyZv8h4WkZeUJE7kHoab9jKjqsC", privateKey:"fb1d8d4ca6cb3a1a417aedfd764c945ca5a71ddb6434e06445d30b6a98de21dd" );

  body = await fetchJsonDataFromUrl("http://172.19.249.181:3002/v1/credentials/f1c557fc-846c-11ee-838f-0242ac1b0008/qrcode");
  iden3messageEntity = await sdk.iden3comm.getIden3Message(message: body);

  // await sdk.iden3comm.fetchAndSaveClaims(message: iden3messageEntity, genesisDid: did, privateKey: private_key);
  // //
  // body = await fetchJsonDataFromUrl("http://172.19.249.181:3002/v1/credentials/89d8c4ec-8475-11ee-838f-0242ac1b0008/qrcode");
  // iden3messageEntity = await sdk.iden3comm.getIden3Message(message: body);
  // await sdk.iden3comm.fetchAndSaveClaims(message: iden3messageEntity, genesisDid: did, privateKey: private_key);
  // //
  // body = await fetchJsonDataFromUrl("http://172.19.249.181:3002/v1/credentials/dfa5a303-846f-11ee-838f-0242ac1b0008/qrcode");
  // iden3messageEntity = await sdk.iden3comm.getIden3Message(message: body);
  // await sdk.iden3comm.fetchAndSaveClaims(message: iden3messageEntity, genesisDid: did, privateKey: private_key);

  List<ClaimEntity> claims = await sdk.credential.getClaims (genesisDid: did, privateKey: private_key);
  for(ClaimEntity claim in claims)
    print(claim.info);
  sdk.iden3comm.getProofs(message: iden3messageEntity, genesisDid: did, privateKey: private_key);
}



Future<String> _getAuthenticationIden3MessageFromApi() async {
  Uuid uuid = const Uuid();
  String randomUuid = uuid.v1();
  Uri uri = Uri.parse(SERVER_LOCATION + "/v1/authentication/qrcode");
  String params = jsonEncode({"loginId": randomUuid});
  Response response = await post(
    uri,
    headers: {
      HttpHeaders.acceptHeader: '*/*',
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: params,
  );
  return response.body;
}

Future<String> fetchJsonDataFromUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Restituisci il corpo della risposta come stringa JSON
      return response.body;
    } else {
      throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}


Future<void> writeToFile(String filePath, String content) async {
  // Apre il file in modalità di scrittura, creandolo se non esiste
  var file = File(filePath);

  // Scrive il contenuto nel file
  await file.writeAsString(content);
}
