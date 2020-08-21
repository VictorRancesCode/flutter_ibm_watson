import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

class Voice {
  String gender;
  dynamic supported_feature;
  String name;
  bool customizable;
  String description;
  String language;
  String url;

  Voice(Map data) {
    this.gender = data['gender'];
    this.supported_feature = data['supported_features'];
    this.name = data['name'];
    this.customizable = data['customizable'];
    this.description = data['description'];
    this.language = data['language'];
    this.url = data['url'];
  }
}

class TextToSpeech {
  String urlBase = "https://api.us-south.text-to-speech.watson.cloud.ibm.com";
  String modelId;
  final String version;
  IamOptions iamOptions;
  String accept;
  String voice;

  TextToSpeech(
      {@required this.iamOptions,
      this.version = "2018-05-01",
      this.accept = "audio/mp3",
      this.voice = "en-US_AllisonV3Voice"});

  void setVoice(String v) {
    this.voice = v;
  }

  String _getUrl(method, {param = ""}) {
    String url = iamOptions.url;
    if (iamOptions.url == "" || iamOptions.url == null) {
      url = urlBase;
    }
    return "$url/v1/$method$param";
  }

  Future<Uint8List> toSpeech(String text) async {
    String token = this.iamOptions.accessToken;
    var response = await http.post(
      _getUrl("synthesize", param: "?voice=$voice"),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
        'Accept': this.accept
      },
      body: '{\"text\":\"$text\"}',
    );
    return response.bodyBytes;
  }

  Future<List<Voice>> getListVoices() async {
    String token = this.iamOptions.accessToken;
    var response = await http.get(_getUrl("voices"), headers: {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
    });
    List<Voice> resp = [];
    if (response.statusCode == 200) {
      Map result = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> data = result['voices'];
      for (Map d in data) {
        resp.add(new Voice(d));
      }
    }
    return resp;
  }
}
