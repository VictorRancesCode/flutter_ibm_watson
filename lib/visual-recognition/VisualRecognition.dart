import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_ibm_watson/utils/Language.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';

class ClassResult {
  String class_name;
  double score;
  String type_hierarchy;

  ClassResult(Map result) {
    this.class_name = result["class"] ?? "";
    this.score = result["score"] ?? "";
    this.type_hierarchy = result["type_hierarchy"] ?? "";
  }

  @override
  String toString() {
    // TODO: implement toString
    return JSON.encode(toJson());
  }

  dynamic toJson() {
    return {
      "class": this.class_name,
      "score": this.score,
      "type_hierarchy": this.type_hierarchy
    };
  }
}

class ClassifierResult {
  String _classifier_id;
  String _name;
  List<ClassResult> _classes;

  ClassifierResult(Map item) {
    this._classifier_id = item["classifier_id"] ?? "";
    this._name = item["name"] ?? "";
    _classes = new List<ClassResult>();
    for (Map result in item["classes"]) {
      _classes.add(new ClassResult(result));
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return JSON.encode({
      "classifier_id": this._classifier_id,
      "name": this._name,
      "classes": JSON.decode(this._classes.toString())
    });
  }

  List<ClassResult> getClasses() {
    return this._classes;
  }

  String get_classifier_id() {
    return this._classifier_id;
  }

  String get_classifier_name() {
    return this._name;
  }
}

class ClassifiedImage {
  List<ClassifierResult> _classifiers;
  String source_url;
  String resolved_url;
  String image;

  ClassifiedImage(Map result_image) {
    this.source_url = result_image["source_url"] ?? "";
    this.resolved_url = result_image["resolved_url"] ?? "";
    this.image = result_image["image"] ?? "";
    _classifiers = new List<ClassifierResult>();
    for (Map item in result_image["classifiers"]) {
      _classifiers.add(new ClassifierResult(item));
    }
  }

  List<ClassifierResult> getClassifiers() {
    return this._classifiers;
  }

  @override
  String toString() {
    // TODO: implement toString
    return JSON.encode({
      "classifiers": JSON.decode(this._classifiers.toString()),
      "source_url": this.source_url,
      "resolved_url": this.resolved_url,
      "image": this.image
    });
  }
}

class ClassifiedImages {
  List<ClassifiedImage> _images;
  int images_processed;
  int custom_classes;

  ClassifiedImages(Map response) {
    this.images_processed = response["images_processed"] ?? "";
    this.custom_classes = response["custom_classes"] ?? "";
    this._images = new List<ClassifiedImage>();
    for (Map image in response["images"]) {
      _images.add(new ClassifiedImage(image));
    }
  }

  List<ClassifiedImage> getImages() {
    return this._images;
  }

  @override
  String toString() {
    // TODO: implement toString
    return JSON.encode({
      "images": JSON.decode(this._images.toString()),
      "images_processed": this.images_processed,
      "custom_classes": this.custom_classes
    });
  }
}

class VisualRecognition {
  String urlApi = "https://gateway.watsonplatform.net/visual-recognition/api";
  IamOptions iamOptions;
  final String version;
  double threshold;
  String language;

  VisualRecognition(
      {@required this.iamOptions,
      this.language = "en",
      this.version = "2018-03-19",
      this.threshold = 0.5});

  String _getUrl(method, imageUrl) {
    String url = iamOptions.url;
    if (iamOptions.url == "" || iamOptions.url == null) {
      url = urlApi;
    }
    return "$url/v3/$method?url=$imageUrl&version=$version&threshold=$threshold";
  }

  Future<ClassifiedImages> classifyImageUrl(String url) async {
    String token = this.iamOptions.access_token;
    var response = await http.get(
      _getUrl("classify", url),
      headers: {
        HttpHeaders.AUTHORIZATION: "Bearer $token",
        HttpHeaders.ACCEPT_LANGUAGE: this.language ?? Language.ENGLISH,
      },
    );
    return ClassifiedImages(JSON.decode(response.body));
  }

  String _getUrlFile(String method) {
    String url = iamOptions.url;
    if (iamOptions.url == "" || iamOptions.url == null) {
      url = urlApi;
    }
    return "$url/v3/$method?version=$version";
  }

  Future<ClassifiedImages> classifyImageFile(String filePath) async {
    ClassifiedImages classifiedImages;
    String token = this.iamOptions.access_token;
    var request =
        new http.MultipartRequest("POST", Uri.parse(_getUrlFile("classify")));
    request.fields['threshold'] = this.threshold.toString();
    var file = await http.MultipartFile.fromPath("images_file", filePath,
        contentType: new MediaType('application', '*'));
    request.files.add(file);
    request.headers.addAll({
      HttpHeaders.AUTHORIZATION: "Bearer $token",
      HttpHeaders.ACCEPT_LANGUAGE: this.language ?? Language.ENGLISH,
    });
    var response = await request.send();
    await response.stream.transform(utf8.decoder).listen((value) {
      dynamic result = JSON.decode(value);
      classifiedImages = new ClassifiedImages(result);
    });
    return classifiedImages;
  }
}
