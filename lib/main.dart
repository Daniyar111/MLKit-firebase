import 'package:flutter/material.dart';
import 'package:ml_kit_example/routes/firebase_mlkit_ex.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter ML',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MLKitExample(),
      ),
    );
