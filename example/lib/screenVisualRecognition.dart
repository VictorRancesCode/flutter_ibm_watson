
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'package:image_picker/image_picker.dart';

class ScreenVisualRecognition extends StatefulWidget {
  ScreenVisualRecognition({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ScreenVisualRecognition createState() => new _ScreenVisualRecognition();
}

class _ScreenVisualRecognition extends State<ScreenVisualRecognition> {
  IamOptions options;
  File _image;
  String _text = "Loading";
  String _text2 = "";
  String url;

  Future<Null> getOptions() async {
    this.options = await IamOptions(
        iamApiKey: "Your ApiKey",
        url:
        "https://api.us-south.visual-recognition.watson.cloud.ibm.com/instances/d9b2881c-9dba-4d68-b52f-c1e54d08f471")
        .build();
    print(this.options.accessToken);
    print(this.options);
  }

  @override
  void initState() {
    // TODO: implement initState
    getOptions();
    super.initState();
  }

  void visualRecognitionUrl() async {
    //await getOptions();
    VisualRecognition visualRecognition = new VisualRecognition(
        iamOptions: this.options, language: Language.ENGLISH);
    ClassifiedImages classifiedImages =
    await visualRecognition.classifyImageUrl(this.url);
    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getClasses()[0]
        .className);
    setState(() {
      _text = classifiedImages.getImages()[0].getClassifiers()[0].toString();
      _text2 = classifiedImages
          .getImages()[0]
          .getClassifiers()[0]
          .getClasses()[0]
          .className;
    });
  }

  void visualRecognitionFile() async {
    //await getOptions();
    VisualRecognition visualRecognition = new VisualRecognition(
        iamOptions: this.options, language: Language.ENGLISH);
    ClassifiedImages classifiedImages =
    await visualRecognition.classifyImageFile(_image.path);

    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getClasses()[0]
        .className);
    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getHigherScore()
        .className);
    ClassResult r =
    classifiedImages.getImages()[0].getClassifiers()[0].getHigherScore();
    setState(() {
      _text = classifiedImages.getImages()[0].getClassifiers()[0].toString();
      _text2 = r.className + " " + r.score.toString();
    });
  }

  final picker = ImagePicker();

  Future getPhoto() async {
    var image = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IBM Watson Visual Recognition"),
      ),
      body: new SingleChildScrollView(
        child: new Container(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? new Text('Not image selected.')
                  : new Image.file(
                _image,
                height: 300.0,
                width: 300.0,
              ),
              new RaisedButton(
                child: const Text('Photo'),
                onPressed: getPhoto,
              ),
              new Text("or"),
              new Container(
                margin: const EdgeInsets.all(5.0),
                child: new TextField(
                  decoration: new InputDecoration(labelText: "Enter Url Image"),
                  onChanged: (String value) {
                    this.url = value;
                  },
                ),
              ),
              new Container(
                margin: const EdgeInsets.all(5.0),
                child: new Text(_text2,
                    style: new TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.bold)),
              ),
              new Container(
                margin: const EdgeInsets.all(5.0),
                child: new Text(_text),
              ),
              new Container(
                margin: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                  child: const Text('Visual Recognition File'),
                  color: Theme.of(context).accentColor,
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  textColor: Colors.white,
                  onPressed: visualRecognitionFile,
                ),
              ),
              new Container(
                margin: const EdgeInsets.all(10.0),
                child: new RaisedButton(
                  child: const Text('Visual Recognition Url'),
                  color: Theme.of(context).accentColor,
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  textColor: Colors.white,
                  onPressed: visualRecognitionUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
