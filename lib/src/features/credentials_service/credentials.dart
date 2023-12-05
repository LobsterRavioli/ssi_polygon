import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk_example/src/state_objects/user.dart';
import 'package:provider/provider.dart';



class CredentialWidget extends StatelessWidget {

  final ClaimEntity claim;

  const CredentialWidget({required this.claim});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          Map<String, dynamic> mappa = claim.info["credentialSubject"];
          mappa.forEach((key, value) {
            print("$key: $value");
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CredentialDetailsPage(claim: claim),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Issuer: ${claim.issuer}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'State: ${claim.state}',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              'Expiration: ${claim.expiration}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}


class CredentialsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Credentials'),
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
          child: ListView.builder(
            itemCount: context.read<User>().credentials.length,
            itemBuilder: (context, index){

              return CredentialWidget(claim: context.read<User>().credentials[index]);
            },

          ),
        ),
      ),
    );
  }
}



class CredentialDetailsPage extends StatelessWidget {
  final ClaimEntity claim;

  const CredentialDetailsPage({required this.claim});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> credentialSubject = claim.info["credentialSubject"];

    return Scaffold(
      appBar: AppBar(
        title: Text('Credential Details'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Issuer', "${claim.issuer}"),
            _buildDetailRow('State', "${claim.state}"),
            _buildDetailRow('Expiration', "${claim.expiration}"),
            SizedBox(height: 24.0),
            Text(
              'Credential Subject',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            _buildCredentialSubjectList(credentialSubject),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialSubjectList(Map<String, dynamic> credentialSubject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: credentialSubject.entries
          .map(
            (entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '${entry.key}:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${entry.value}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}

