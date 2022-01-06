import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/pages/auth_page.dart';

class LandingPage extends StatefulWidget {

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    Timer(Duration(seconds: 5),(){
      Get.offAll(AuthPage());
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Color(0xff428EFF),
          ),
          CircularProgressIndicator(
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
