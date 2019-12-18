import 'package:flutter/material.dart';

abstract class MyRoute extends StatefulWidget {

  const MyRoute();

  Widget buildMyRouteContent(BuildContext context);

  @override
  State<StatefulWidget> createState() => _MyRouteState();
}

class _MyRouteState extends State<MyRoute> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ML Kit")
      ),
      body: widget.buildMyRouteContent(context),
    );
  }


}