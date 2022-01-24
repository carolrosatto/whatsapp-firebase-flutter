// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/models/logged_user.dart';
import 'package:whatsapp_firebase/screens/home.dart';
import 'package:whatsapp_firebase/screens/login.dart';
import 'package:whatsapp_firebase/screens/message.dart';

class Routes {
  static Route<dynamic> createRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Login());
      case "/login":
        return MaterialPageRoute(builder: (_) => Login());
      case "/home":
        return MaterialPageRoute(builder: (_) => Home());
      case "/messages":
        return MaterialPageRoute(builder: (_) => Message(args as LoggedUser));
    }
    return _routeError();
  }

  static Route<dynamic> _routeError() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
