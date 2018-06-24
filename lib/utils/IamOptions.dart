import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class IamOptions {
  String iam_api_key;
  String url;
  String access_token;
  String refresh_token;
  String token_type;
  int expires_in;
  int expiration;
  String scope;

  IamOptions({@required this.iam_api_key, @required this.url});

  Future<IamOptions> build() async {

    Map datos = {
      "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
      "apikey": this.iam_api_key
    };
    var response = await http.post(
      "https://iam.bluemix.net/identity/token",
      headers: {
        HttpHeaders.AUTHORIZATION: "Basic Yng6Yng=",
        HttpHeaders.CONTENT_TYPE: "application/x-www-form-urlencoded",
        HttpHeaders.ACCEPT: "application/json",
      },
      body: datos,
    );
    Map data = JSON.decode(response.body);
    this.access_token = data["access_token"];
    this.refresh_token = data["refresh_token"];
    this.token_type = data["token_type"];
    this.expires_in = data["expires_in"];
    this.expiration = data["expiration"];
    this.scope = data["scope"];
    return this;
  }
}
