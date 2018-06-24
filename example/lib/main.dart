import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Watson Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Watson Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.all(10.0),
              child: new RaisedButton(
                child: const Text('Screen Language Translator'),
                color: Theme.of(context).accentColor,
                elevation: 4.0,
                splashColor: Colors.blueGrey,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenLanguageTranslator()),
                  );
                },
              ),
            ),
            new Container(
              margin: const EdgeInsets.all(10.0),
              child: new RaisedButton(
                child: const Text('Screen Visual Recognition'),
                color: Theme.of(context).accentColor,
                elevation: 4.0,
                splashColor: Colors.blueGrey,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenVisualRecognition()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ScreenLanguageTranslator extends StatefulWidget {
  ScreenLanguageTranslator({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ScreenLanguageTranslator createState() => new _ScreenLanguageTranslator();
}

class _ScreenLanguageTranslator extends State<ScreenLanguageTranslator> {
  IamOptions options;
  String text;
  String result = "";

  Future<Null> getOptions() async {
    this.options = await IamOptions(
            iam_api_key: "fr8sBBKkjZidQJij6HWaetAWAvzfdXmSrKZoHGF8LB",
            url:
                "https://gateway-syd.watsonplatform.net/language-translator/api")
        .build();
    print(this.options.access_token);
  }

  void languageTranslator() async {
    LanguageTranslator service =
        new LanguageTranslator(iamOptions: this.options);
    TranslationResult translationResult =
        await service.translate(this.text, Language.ENGLISH, Language.SPANISH);
    print(translationResult);
    setState(() {
      this.result = translationResult.toString();
    });
  }

  void identifyLanguage() async {
    LanguageTranslator service =
        new LanguageTranslator(iamOptions: this.options);
    IdentifyLanguageResult identifyLanguageResult = await service
        .identifylanguage("You have pushed the button this many times:s");
    print(identifyLanguageResult);
    setState(() {
      this.result = identifyLanguageResult.toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IBM Watson Language Translator"),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.all(10.0),
            child: new TextField(
              decoration: new InputDecoration(
                labelText: "Enter Text",
              ),
              onChanged: (String value) {
                this.text = value;
              },
            ),
          ),
          new Container(
            margin: const EdgeInsets.all(10.0),
            child: new RaisedButton(
              child: const Text('Language Translator'),
              color: Theme.of(context).accentColor,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: languageTranslator,
            ),
          ),
          new Container(
            margin: const EdgeInsets.all(10.0),
            child: new RaisedButton(
              child: const Text('Identify Language'),
              color: Theme.of(context).accentColor,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: identifyLanguage,
            ),
          ),
          new Text("result: $result")
        ],
      ),
    );
  }
}

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
            iam_api_key: "PtrgxzcADASVCXCjDmalrW1gXSADDgEt533gxwQAliAnvvjDDFmNHKNzgnLQ",
            url: "https://gateway.watsonplatform.net/visual-recognition/api")
        .build();
    print(this.options.access_token);
  }

  @override
  void initState() {
    // TODO: implement initState
    getOptions();
    super.initState();
  }

  void visualRecognitionUrl() async {
    VisualRecognition visualRecognition = new VisualRecognition(
        iamOptions: this.options, language: Language.ENGLISH);
    ClassifiedImages classifiedImages =
        await visualRecognition.classifyImageUrl(this.url);
    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getClasses()[0]
        .class_name);
    setState(() {
      _text = classifiedImages.getImages()[0].getClassifiers()[0].toString();
      _text2 = classifiedImages
          .getImages()[0]
          .getClassifiers()[0]
          .getClasses()[0]
          .class_name;
    });
  }

  void visualRecognitionFile() async {
    VisualRecognition visualRecognition = new VisualRecognition(
        iamOptions: this.options, language: Language.ENGLISH);
    ClassifiedImages classifiedImages =
        await visualRecognition.classifyImageFile(_image.path);

    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getClasses()[0]
        .class_name);
    setState(() {
      _text = classifiedImages.getImages()[0].getClassifiers()[0].toString();
      _text2 = classifiedImages
          .getImages()[0]
          .getClassifiers()[0]
          .getClasses()[0]
          .class_name;
    });
  }

  Future getPhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
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
