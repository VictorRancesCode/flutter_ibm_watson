
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

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
        iamApiKey: "fr8sBBKkjZidQJij6HWaetAWAvzfdXmSrKZoHGF8LB",
        url:
        "https://gateway-syd.watsonplatform.net/language-translator/api")
        .build();
    print(this.options.accessToken);
  }

  void languageTranslator() async {
    //await getOptions();
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
