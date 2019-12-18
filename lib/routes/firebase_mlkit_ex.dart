import 'dart:io';
import 'dart:math';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart' show kTransparentImage;
import 'package:flutter/material.dart';
import '../my_route.dart';

class MLKitExample extends MyRoute {

  const MLKitExample();

  @override
  Widget buildMyRouteContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MLKitDemoPage(),
    );
  }
}

class MLKitDemoPage extends StatefulWidget {

  @override
  _MLKitDemoPageState createState() => _MLKitDemoPageState();
}

class _MLKitDemoPageState extends State<MLKitDemoPage> {

  File _imageFile;
  String _mlResult = 'no result';



  Future<bool> _pickImage() async {

    setState(() => this._imageFile = null);

    final File imageFile = await showDialog<File>(
      context: context,
      builder: (ctx) => SimpleDialog(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take picture'),
                onTap: () async {
                  final File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
                  Navigator.pop(ctx, imageFile);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Pick from gallery'),
                onTap: () async {
                  try {
                    final File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
                    Navigator.pop(ctx, imageFile);
                  } catch (e) {
                    print(e);
                    Navigator.pop(ctx, null);
                  }
                },
              ),
            ],
          ),
    );
    if (imageFile == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Please pick one image first.')),
      );
      return false;
    }
    setState(() => this._imageFile = imageFile);
    print('picked image: ${this._imageFile}');
    return true;
  }



  Future<Null> _imageLabelling() async {

    setState(() => this._mlResult = 'no result');

    if (await _pickImage() == false) {
      return;
    }

    String result = '';

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(this._imageFile);
    final LabelDetector labelDetector = FirebaseVision.instance.labelDetector();
    final List<Label> labels = await labelDetector.detectInImage(visionImage);

    result += 'Detected ${labels.length} labels.\n';

    for (Label label in labels) {

      final String text = label.label;
      final double confidence = label.confidence;
      result += '\nLabel: $text, confidence is ${confidence.toStringAsFixed(3)}';
    }

    if (result.length > 0) {
      setState(() => this._mlResult = result);
    }
  }



  Future<Null> _textOcr() async {

    setState(() => this._mlResult = 'no result');

    if (await _pickImage() == false) {
      return;
    }

    String result = '';

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(this._imageFile);
    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);

    result += 'Detected ${visionText.blocks.length} text blocks.\n';

    for (TextBlock block in visionText.blocks) {
      final Rectangle<int> boundingBox = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;

      result += '\nText block:\n '
          'bounding box = $boundingBox\n '
          'corner points = $cornerPoints\n '
          'text = $text';
    }

    if (result.length > 0) {
      setState(() => this._mlResult = result);
    }
  }


  Future<Null> _faceDetect() async {

    setState(() => this._mlResult = 'no result');

    if (await _pickImage() == false) {
      return;
    }

    String result = '';

    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    );

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(this._imageFile);



    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(options);
    final List<Face> faces = await faceDetector.detectInImage(visionImage);


    result += 'Detected ${faces.length} faces.\n';

    for (Face face in faces) {
      final Rectangle<int> boundingBox = face.boundingBox;
      final double rotY = face.headEulerAngleY;
      final double rotZ = face.headEulerAngleZ;

      result += '\n# Face:\n '
          'bounding box = $boundingBox\n '
          'head is rotated to the right digrees = $rotY\n '
          'head is tilted sideways = $rotZ\n ';
      final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
      if (leftEar != null) {
        final Point<double> leftEarPos = leftEar.position;
        result += 'left ear position = $leftEarPos\n ';
      }
      if (face.smilingProbability != null) {
        final double smileProb = face.smilingProbability;
        result += 'smile probability = ${smileProb.toStringAsFixed(3)}\n ';
      }
      if (face.trackingId != null) {
        final int id = face.trackingId;
        result += 'tracking id = $id\n ';
      }
    }
    if (result.length > 0) {
      setState(() => this._mlResult = result);
    }
  }



  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        this._imageFile == null
            ? Placeholder(
                fallbackHeight: 200.0,
              )
            : FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: FileImage(this._imageFile),
                // Image.file(, fit: BoxFit.contain),
              ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ButtonBar(
            children: <Widget>[
              RaisedButton(
                child: Text('Image Labelling'),
                onPressed: this._imageLabelling,
              ),
              RaisedButton(
                child: Text('Text OCR'),
                onPressed: this._textOcr,
              ),
              RaisedButton(
                child: Text('Face Detection'),
                onPressed: this._faceDetect,
              ),
            ],
          ),
        ),
        Divider(),
        Text('Result:', style: Theme.of(context).textTheme.subtitle),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            this._mlResult,
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
