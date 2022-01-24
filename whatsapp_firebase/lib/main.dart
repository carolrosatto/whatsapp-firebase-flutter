import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/routes.dart';
import 'package:whatsapp_firebase/utils/color_pallet.dart';

void main() {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  String initialUrl = "/";
  if (firebaseUser != null) {
    initialUrl = "/home";
  }

  runApp(MaterialApp(
    theme: ThemeData(
        colorScheme: ThemeData().colorScheme.copyWith(
            primary: ColorPalette.primaryColor,
            secondary: ColorPalette.accentColor)),
    title: "Whatsapp Web",
    debugShowCheckedModeBanner: false,
    //home: Login(),
    initialRoute: "/",
    onGenerateRoute: Routes.createRoute,
  ));
}
