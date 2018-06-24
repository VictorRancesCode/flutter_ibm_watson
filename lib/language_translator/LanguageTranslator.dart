library flutter_ibm_watson;

import 'package:flutter_ibm_watson/utils/IamOptions.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TranslationResult {
  int word_count;
  int character_count;
  dynamic translations;

  TranslationResult(Map result) {
    translations = result["translations"];
    word_count = result["word_count"];
    character_count = result["character_count"];
  }

  String toString() {
    return translations[0]["translation"];
  }

  int get_word_count() {
    return this.word_count;
  }

  int get_character_count() {
    return this.translations;
  }
}

class ItemIdentifyLanguageResult {
  double confidence;
  String language;

  ItemIdentifyLanguageResult({this.confidence, this.language});

  @override
  String toString() {
    // TODO: implement toString
    return JSON.encode({"language":this.language,"condidence":this.confidence});
  }
}

class IdentifyLanguageResult {
  List<ItemIdentifyLanguageResult> _list;

  IdentifyLanguageResult() {
    this._list = new List<ItemIdentifyLanguageResult>();
  }

  void add(ItemIdentifyLanguageResult item) {
    this._list.add(item);
  }

  String getLanguageProbability() {
    if (this._list.length < 1) {
      return "";
    }
    return this._list.elementAt(0).language;
  }

  List<ItemIdentifyLanguageResult> getAllLanguageProbability() {
    return this._list;
  }

  @override
  String toString() {
    // TODO: implement toString
    return getLanguageProbability();
  }
}

class LanguageTranslator {
  String URL = "https://gateway.watsonplatform.net/language-translator/api";
  String model_id;
  final String version;
  IamOptions iamOptions;

  LanguageTranslator({
    @required this.iamOptions,
    this.version = "2018-05-01",
  });

  String _getUrl(method) {
    String url = iamOptions.url;
    if (iamOptions.url == "" || iamOptions.url == null) {
      url = URL;
    }
    return "$url/v3/$method?version=$version";
  }

  Future<TranslationResult> translate(
      String text, String source, String target) async {
    String token = this.iamOptions.access_token;
    model_id = source + "-" + target;
    var response = await http.post(
      _getUrl("translate"),
      headers: {
        HttpHeaders.AUTHORIZATION: "Bearer $token",
        HttpHeaders.ACCEPT: "application/json",
        HttpHeaders.CONTENT_TYPE: "application/json",
      },
      body: '{\"text\":[\"$text\"],\"model_id\":\"$model_id\"}',
    );
    return new TranslationResult(JSON.decode(response.body));
  }

  Future<IdentifyLanguageResult> identifylanguage(String text) async {
    IdentifyLanguageResult identifyLanguageResult =
        new IdentifyLanguageResult();
    String token = this.iamOptions.access_token;
    var response = await http.post(
      _getUrl("identify"),
      headers: {
        HttpHeaders.AUTHORIZATION: "Bearer $token",
        HttpHeaders.ACCEPT: "application/json",
        HttpHeaders.CONTENT_TYPE: "text/plain",
      },
      body: text,
    );
    Map result = JSON.decode(response.body);
    dynamic languages = result["languages"];
    List<dynamic> list_languages = languages;
    for (int i = 0; i < list_languages.length; i++) {
      Map language = list_languages[0];
      identifyLanguageResult.add(new ItemIdentifyLanguageResult(
          confidence: language["confidence"], language: language["language"]));
    }
    return identifyLanguageResult;
  }
}
