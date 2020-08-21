import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/services/textToSpeech.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';
//import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'package:path_provider/path_provider.dart';

class ScreenTextToSpeech extends StatefulWidget {
  ScreenTextToSpeech({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ScreenTextToSpeech createState() => new _ScreenTextToSpeech();
}

class _ScreenTextToSpeech extends State<ScreenTextToSpeech> {
  IamOptions options;
  String text;
  String result = "";
  AudioPlayer audioPlugin = AudioPlayer();
  String mp3Uri;
  TextToSpeech service;
  Voice voiceSelected;
  bool _progressBarActive=false;

  Future<Null> getOptions() async {
    this.options = await IamOptions(
            iamApiKey: "KUpKqB-87u2FfIT1ESOXcnrDKT2DeeiN1r_NQrqfxIh1",
            url:
                "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/2374e602-5e10-4219-b492-a7e9b85a372b")
        .build();
    print(this.options.accessToken);
  }

  void textToSpeech() async {
    service.setVoice(voiceSelected.name);
    Uint8List bi = await service.toSpeech(text);
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/demo.mp3');
    await tempFile.writeAsBytes(bi);
    mp3Uri = tempFile.uri.toString();
    //rint('finished loading, uri=$mp3Uri');
    _playSound();
  }

  void _playSound() async {
    if (mp3Uri != null) {
      int result = await audioPlugin.play(mp3Uri, isLocal: false);
      //print(result);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
  }

  List<DropdownMenuItem<Voice>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Voice>> items = List();
    for (Voice listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.description),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Voice>> _dropdownMenuItems;

  void initial() async {
    setState(() {
      _progressBarActive = true;
    });
    await getOptions();
    service = new TextToSpeech(iamOptions: this.options);
    List<Voice> listVoice = await service.getListVoices();
    print(listVoice);
    setState(() {
      _dropdownMenuItems = buildDropDownMenuItems(listVoice);
      voiceSelected = _dropdownMenuItems[0].value;
      _progressBarActive=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IBM Watson Text to Speech"),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(

            child: _progressBarActive == true?const CircularProgressIndicator():new Container(),
          ),
          new Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(bottom:5.0,left: 10.0,right: 10.0),
            child: Text("Select Language:",style: TextStyle(fontSize: 20.0),),
          ),
          new Container(
            margin: const EdgeInsets.only(bottom:10.0,left: 10.0,right: 10.0),
            child: DropdownButton<Voice>(
                isExpanded: true,
                value: voiceSelected,
                items: _dropdownMenuItems,
                onChanged: (value) {
                  setState(() {
                    voiceSelected = value;
                  });
                }),
          ),
          new Container(
            margin: const EdgeInsets.all(10.0),
            child: new TextField(
              decoration: new InputDecoration(
                labelText: "Enter Your Text",
              ),
              onChanged: (String value) {
                //this.text = value;
                setState(() {
                  text = value;
                });
              },
            ),
          ),

          new Container(
            margin: const EdgeInsets.all(10.0),
            child: new RaisedButton(
              child: const Text('Speech'),
              color: Theme.of(context).accentColor,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: textToSpeech,
            ),
          ),
          //new Text("result: $result")
        ],
      ),
    );
  }
}
