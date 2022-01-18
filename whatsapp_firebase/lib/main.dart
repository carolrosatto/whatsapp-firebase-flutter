import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/routes.dart';

void main() {
  runApp(const MaterialApp(
    title: "Whatsapp Web",
    debugShowCheckedModeBanner: false,
    //home: Login(),
    initialRoute: "/",
    onGenerateRoute: Routes.createRoute,
  ));
}
