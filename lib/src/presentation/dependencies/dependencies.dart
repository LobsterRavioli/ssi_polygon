
import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk_example/src/common/env.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  registerEnv();  // Registrazione del file di configurazione env con le variabili di configurazione
  registerProviders();
}

void registerEnv() {
  Map<String, dynamic> polygonMumbai = jsonDecode(Env.polygonMumbai);
  List<EnvEntity> env = [
    EnvEntity(
      blockchain: polygonMumbai['blockchain'],
      network: polygonMumbai['network'],
      web3Url: polygonMumbai['web3Url'],
      web3RdpUrl: polygonMumbai['web3RdpUrl'],
      web3ApiKey: polygonMumbai['web3ApiKey'],
      idStateContract: polygonMumbai['idStateContract'],
      pushUrl: polygonMumbai['pushUrl'],
      ipfsUrl: polygonMumbai['ipfsUrl'],
    ),
  ];
  getIt.registerSingleton<List<EnvEntity>>(env);
}

Future<void> registerProviders() async {
  await PolygonIdSdk.init(env: getIt<List<EnvEntity>>()[0]);
  getIt.registerLazySingleton<PolygonIdSdk>(() => PolygonIdSdk.I);
}