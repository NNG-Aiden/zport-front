import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/pages/auth_page.dart';
import 'package:untitled/pages/landing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: 'Pretendard'),
      home: LandingPage(),
    );
  }
}

