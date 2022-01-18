// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/screens/home_desktop.dart';
import 'package:whatsapp_firebase/screens/home_mobile.dart';
import 'package:whatsapp_firebase/utils/responsive.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      desktop: HomeDesktop(),
      mobile: HomeMobile(),
    );
  }
}
