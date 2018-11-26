import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class IamOptions {
  String iamApiKey;
  String url;
  String accessToken;
  String refreshToken;
  String tokenType;
  int expiresIn;
  int expiration;
  String scope;

  IamOptions({@required this.iamApiKey, @required this.url});

  Future<IamOptions> build() async {

    Map datos = {
      "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
      "apikey": this.iamApiKey
    };
    var response = await http.post(
      "https://iam.bluemix.net/identity/token",
      headers: {
        HttpHeaders.authorizationHeader: "Basic Yng6Yng=",
        HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        HttpHeaders.acceptHeader: "application/json",
      },
      body: datos,
    ).timeout(const Duration(seconds: 360));
    Map data = json.decode(response.body);
    this.accessToken = data["access_token"];
    if(this.accessToken==null){
      print("AccessToken is Null, verified your Token");
    }
    this.refreshToken = data["refresh_token"];
    this.tokenType = data["token_type"];
    this.expiresIn = data["expires_in"];
    this.expiration = data["expiration"];
    this.scope = data["scope"];
    return this;
  }
}
