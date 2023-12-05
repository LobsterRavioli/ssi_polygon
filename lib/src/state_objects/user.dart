import 'package:flutter/material.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';

class User extends ChangeNotifier{

  String authMessage = "";
  String credentialMessage = "";
  String _did = "";
  List<ClaimEntity> credentials = [];
  String _private_key = "";
  bool _logged = false;
  late IdentityEntity _identity;

  IdentityEntity get identity => _identity;

  void authenticate(){

  }

  void addCredentials(ClaimEntity claim){
    credentials.add(claim);
  }
  set identity(IdentityEntity value) {
    _identity = value;
  }

  void Login(){
    this._logged = true;
    this._logged = true;
  }
  void Logoff(){
    this._logged = false;
  }

  bool isLogged(){
    return this._logged;
  }

  bool get logged => _logged;

  set logged(bool value) {
    _logged = value;
  }

  String get private_key => _private_key;

  set private_key(String value) {
    _private_key = value;
  }


  String get did => _did;

  set did(String value) {
    _did = value;
  }
}

class Credential extends ChangeNotifier{
  String issuer = "";
  String issuerDid = "";
  String recipientDid = "";
  String context = "";
  var dateOfIssue;
  var experationDate;
  var proofTypes;

}


class UserLoggerInfo extends ChangeNotifier {
  static const String LOGGED = "LOGGED";
  static const String NOTLOGGED = "NOTLOGGED";

  String _userLogged = "";

  String get userLogged => _userLogged;

  void setUserLogged(String user) {
    _userLogged = user;
    notifyListeners();
  }

  UserLoggerInfo(this._userLogged);
}
