import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';

import 'home_page.dart';


class ZportRegisterPage extends StatefulWidget {
  const ZportRegisterPage({Key? key}) : super(key: key);

  @override
  _ZportRegisterPageState createState() => _ZportRegisterPageState();
}
class _ZportRegisterPageState extends State<ZportRegisterPage> {

  GlobalKey<FormState> _formKey0 = GlobalKey<FormState>();
  bool isButtonActive = false;
  late TextEditingController _controller;

  @override
  void initState(){
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final isButtonActive = _controller.text.isNotEmpty;
      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  late String? _data;
  Future<void> validateAndGetTo() async {
    final form = _formKey0.currentState;
    if (form!.validate()){
      form.save();
      var data = {
        "name" : _data
      };
      Get.to(ZportRegisterPage2(), transition: Transition.rightToLeft, arguments: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Container(
                    alignment: Alignment.center,
                      width: 55,
                      height: 27,
                      decoration: BoxDecoration(
                        borderRadius : BorderRadius.circular(29),
                        color : Color.fromRGBO(239, 242, 251, 1),
                      ),
                    child: Text(
                      "1/4",
                        style: TextStyle(
                          fontSize: 16,
                            fontWeight: FontWeight.bold,
                          color: Color(0xff428EFF),
                            letterSpacing: 1
                        )
                    ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 16),
                      Text("지포트에서 쓰일\n이름을 입력해 주세요",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      SizedBox(height: 30),
                      Form(
                        key: _formKey0,
                        child: TextFormField(
                          style: TextStyle(fontSize: 20),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[ㄱ-ㅎ|가-힣|ㆍ|ᆢ]'))],
                          controller: _controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "이름 입력",
                            hintStyle: TextStyle(
                                color: Colors.black26,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                            onSaved: (text){
                              _data = text!;
                            },
                        ),
                      ),
                      Divider(thickness: 2,),
                      SizedBox(height: 320),
                      FlatButton(
                          onPressed: isButtonActive? () {
                            validateAndGetTo();
                          }:null,
                          color: Color(0xff428EFF),
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          disabledColor: Color.fromRGBO(239, 242, 251, 1),
                          disabledTextColor: Colors.black26,
                          textColor: Colors.white,
                          child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZportRegisterPage2 extends StatefulWidget {
  const ZportRegisterPage2({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage2State createState() => _ZportRegisterPage2State();
}
class _ZportRegisterPage2State extends State<ZportRegisterPage2> {

  var data = Get.arguments;
  String? body;
  GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  bool isButtonActive = false;
  late TextEditingController _controller;
  late TextEditingController _phoneNumberController = TextEditingController();
  final String _url = "http://ec2-13-125-142-191.ap-northeast-2.compute.amazonaws.com:3000/api/auth/number/";
  bool _enabled = true;
  late Timer _timer;

  @override
  void initState(){
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final isButtonActive = (_controller.text.length==5);
      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  late String? _data;
  late String? _phoneAuth;
  Future<void> validateAndGetAuthNumber() async {
    final form = _formKey1.currentState;
    if (form!.validate()){
      form.save();
      if (_data!.length == 11) {
        http.Response _getRes = await http.get(Uri.parse('$_url'+'$_data'));
        body = _getRes.body;
        if(_getRes.statusCode == 200) {
          setState(() {
            _enabled = false;
          });
          dialog("인증번호 전송","인증번호가 발송되었습니다");
          _timer = Timer(Duration(seconds: 180),(){
            dialog("인증 실패","시간이 초과되었습니다");
            setState(() {
              _enabled = true;
            });
            _controller.clear();
          });
        } else {
          dialog("인증번호 전송실패","이미 가입되어있는 전화번호입니다");
        }
      } else {
        dialog("인증번호 전송실패","전화번호를 정확히 입력해주세요");
      }
    }
  }

  Future<void> validateAndGetTo() async {
    final form = _formKey2.currentState;
    if (form!.validate()){
      form.save();
      if(jsonDecode(body!)['number'].toString() == _phoneAuth){
        data["phone"] = _data;
        Get.to(ZportRegisterPage3(), transition: Transition.rightToLeft, arguments: data);
        _timer.cancel();
      }else{
        dialog("인증 실패","인증번호가 일치하지 않습니다");
      }
    }
  }

  void dialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("닫기"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Container(
                  alignment: Alignment.center,
                  width: 55,
                  height: 27,
                  decoration: BoxDecoration(
                    borderRadius : BorderRadius.circular(29),
                    color : Color.fromRGBO(239, 242, 251, 1),
                  ),
                  child: Text(
                      "2/4",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff428EFF),
                          letterSpacing: 1
                      )
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 16),
                      Text("휴대전화 번호를\n입력해 주세요",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      SizedBox(height: 30),
                      Form(
                        key: _formKey1,
                        child: Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                style: TextStyle(fontSize: 20),
                                keyboardType: TextInputType.number,
                                inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9]')),LengthLimitingTextInputFormatter(11)],
                                controller: _phoneNumberController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: " - 없이 숫자 11자리 입력",
                                  hintStyle: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onSaved: (text){
                                  _data = text!;
                                },
                                enabled: _enabled,
                              ),
                            ),
                            OutlineButton(onPressed: (){
                              validateAndGetAuthNumber();
                            },
                                child: Text("인증번호", style: TextStyle(color: Color(0xff428EFF),),),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)
                                ),
                                borderSide: BorderSide(color: Color(0xff428EFF), width: 1.2),
                            )
                          ],
                        ),
                      ),
                      Divider(thickness: 2,),
                      AnimatedContainer(
                        height: _enabled?0:80,
                        duration: Duration(milliseconds: 0),
                        child: Column(
                          children: [
                            Form(
                              key: _formKey2,
                              child: TextFormField(
                                style: TextStyle(fontSize: 20),
                                keyboardType: TextInputType.number,
                                inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9]')),LengthLimitingTextInputFormatter(5)],
                                controller: _controller,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "인증번호 입력",
                                  hintStyle: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onSaved: (text){
                                  _phoneAuth = text!;
                                },
                              ),
                            ),
                            Divider(thickness: 2,),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        height: _enabled?320:240,
                        duration: Duration(milliseconds: 0),
                          child: SizedBox(height: 240)
                      ),
                      FlatButton(
                        onPressed: isButtonActive? () {
                          validateAndGetTo();
                        }:null,
                        color: Color(0xff428EFF),
                        padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                        ),
                        disabledColor: Color.fromRGBO(239, 242, 251, 1),
                        disabledTextColor: Colors.black26,
                        textColor: Colors.white,
                        child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZportRegisterPage3 extends StatefulWidget {
  const ZportRegisterPage3({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage3State createState() => _ZportRegisterPage3State();
}
class _ZportRegisterPage3State extends State<ZportRegisterPage3> {

  var data = Get.arguments;
  GlobalKey<FormState> _formKey0 = GlobalKey<FormState>();
  bool isButtonActive = false;
  late TextEditingController _controller;
  int? month;
  int? day;

  @override
  void initState(){
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      if (_controller.text.length==6) {
        month = int.parse(_controller.text.substring(2,4));
        day = int.parse(_controller.text.substring(4));
        final isButtonActive = (month!<=12 && day!<=31);
        setState(() {
          this.isButtonActive = isButtonActive;
        });
      }
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  late String? _data;
  Future<void> validateAndGetTo() async {
    final form = _formKey0.currentState;
    if (form!.validate()){
      form.save();
      data["birth"] = _data;
      Get.to(ZportRegisterPage4(), transition: Transition.rightToLeft, arguments: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Container(
                  alignment: Alignment.center,
                  width: 55,
                  height: 27,
                  decoration: BoxDecoration(
                    borderRadius : BorderRadius.circular(29),
                    color : Color.fromRGBO(239, 242, 251, 1),
                  ),
                  child: Text(
                      "3/4",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff428EFF),
                          letterSpacing: 1
                      )
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 16),
                      Text("생년월일을\n입력해 주세요",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      SizedBox(height: 30),
                      Form(
                        key: _formKey0,
                        child: TextFormField(
                          style: TextStyle(fontSize: 20),
                          keyboardType: TextInputType.number,
                          inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9]')),LengthLimitingTextInputFormatter(6)],
                          controller: _controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "생년월일 6자리",
                            hintStyle: TextStyle(
                              color: Colors.black26,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onSaved: (text){
                            _data = text!;
                          },
                        ),
                      ),
                      Divider(thickness: 2,),
                      SizedBox(height: 320),
                      FlatButton(
                        onPressed: isButtonActive? () {
                          validateAndGetTo();
                        }:null,
                        color: Color(0xff428EFF),
                        padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                        ),
                        disabledColor: Color.fromRGBO(239, 242, 251, 1),
                        disabledTextColor: Colors.black26,
                        textColor: Colors.white,
                        child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZportRegisterPage4 extends StatefulWidget {
  const ZportRegisterPage4({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage4State createState() => _ZportRegisterPage4State();
}
class CheckValidate{
  String? validatePassword(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '비밀번호를 입력하세요.';
    }else {
      String pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,16}$';
      RegExp regExp = new RegExp(pattern);
      if(!regExp.hasMatch(value)){
        focusNode.requestFocus();
        return '특수문자, 대소문자, 숫자 포함 8자 이상 16자 이내로 입력하세요.';
      }else{
        return null;
      }
    }
  }
}
class _ZportRegisterPage4State extends State<ZportRegisterPage4> {

  var data = Get.arguments;
  String? body;
  GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  bool isButtonActive = false;
  late TextEditingController _controller;
  late TextEditingController _accountIdController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  final String _url = "http://ec2-13-125-142-191.ap-northeast-2.compute.amazonaws.com:3000/api/auth/exist/";
  bool _enabled = true;

  FocusNode _passwordFocus = new FocusNode();

  @override
  void initState(){
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
        final isButtonActive = (_controller.text.length==_passwordController.text.length);
        setState(() {
          this.isButtonActive = isButtonActive;
        });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  late String? _account_id;
  late String? _password;
  late String? _cPassword;
  Future<void> validateAndGetExist() async {
    final form = _formKey3.currentState;
    if (form!.validate()){
      form.save();
        http.Response _getRes = await http.get(Uri.parse('$_url'+'$_account_id'));
        if(_getRes.statusCode == 200) {
          dialog("알림","사용가능한 아이디입니다");
          setState(() {
            _enabled = false;
          });
        } else {
          dialog("알림","이미 가입되어있는 아이디입니다");
        }
    }
  }

  Future<void> validateAndGetTo() async {
    final form = _formKey2.currentState;
    if (form!.validate()){
      form.save();
      if(_password == _cPassword){
        data["account_id"] = _account_id;
        data["password"] = _password;
        Get.to(ZportRegisterPage5(), transition: Transition.rightToLeft, arguments: data);
      }else{
        dialog("알림","비밀번호가 일치하지 않습니다");
      }
    }
  }

  void dialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("닫기"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Container(
                  alignment: Alignment.center,
                  width: 55,
                  height: 27,
                  decoration: BoxDecoration(
                    borderRadius : BorderRadius.circular(29),
                    color : Color.fromRGBO(239, 242, 251, 1),
                  ),
                  child: Text(
                      "4/4",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff428EFF),
                          letterSpacing: 1
                      )
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 16),
                      Text("아이디와 비밀번호를\n입력해 주세요",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      SizedBox(height: 30),
                      Form(
                        key: _formKey3,
                        child: Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                style: TextStyle(fontSize: 20),
                                inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9]|[a-z]|[A-Z]'))],
                                controller: _accountIdController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "아이디",
                                  hintStyle: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onSaved: (text){
                                  _account_id = text!;
                                },
                                enabled: _enabled,
                              ),
                            ),
                            OutlineButton(onPressed: (){
                              validateAndGetExist();
                            },
                              child: Text("중복확인", style: TextStyle(color: Color(0xff428EFF),),),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)
                              ),
                              borderSide: BorderSide(color: Color(0xff428EFF), width: 1.2),
                            )
                          ],
                        ),
                      ),
                      Divider(thickness: 2,),
                      Form(
                        key: _formKey2,
                        child: Column(
                          children: [
                            TextFormField(
                              style: TextStyle(fontSize: 20),
                              obscureText: true,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "비밀번호",
                                hintStyle: TextStyle(
                                  color: Colors.black26,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onSaved: (text){
                                _password = text!;
                              },
                              enabled: !_enabled,
                              focusNode: _passwordFocus,
                              validator: (value) => CheckValidate().validatePassword(_passwordFocus, value!),
                            ),
                            Divider(thickness: 2,),
                            TextFormField(
                              style: TextStyle(fontSize: 20),
                              obscureText: true,
                              controller: _controller,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "비밀번호 확인",
                                hintStyle: TextStyle(
                                  color: Colors.black26,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onSaved: (text){
                                _cPassword = text!;
                              },
                              enabled: !_enabled,
                            ),
                            Divider(thickness: 2,),
                          ],
                        ),
                      ),
                      SizedBox(height: 190),
                      FlatButton(
                        onPressed: isButtonActive? () {
                          _formKey2.currentState!.validate();
                          validateAndGetTo();
                        }:null,
                        color: Color(0xff428EFF),
                        padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                        ),
                        disabledColor: Color.fromRGBO(239, 242, 251, 1),
                        disabledTextColor: Colors.black26,
                        textColor: Colors.white,
                        child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZportRegisterPage5 extends StatelessWidget {

  var data = Get.arguments;
  String name = Get.arguments['name'];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 45),
                Text("반가워요! $name님\n몇 가지 정보를 물어볼게요",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )
                ),
                SizedBox(height: 20),
                Text("지포트를 더 알차게 사용하기 위해\n몇 가지 정보를 더 물어볼게요",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff636363),
                    )
                ),
                SizedBox(height: 107),
                Center(child: Image.asset('assets/image/register_1.png',)),
                Center(
                  child: FlatButton(
                    minWidth: 344,
                    onPressed: () {
                      Get.to(ZportRegisterPage6(), transition: Transition.rightToLeft, arguments: data);
                    },
                    color: Color(0xff428EFF),
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    textColor: Colors.white,
                    child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZportRegisterPage6 extends StatefulWidget {
  const ZportRegisterPage6({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage6State createState() => _ZportRegisterPage6State();
}
class _ZportRegisterPage6State extends State<ZportRegisterPage6> {

  var data = Get.arguments;
  GlobalKey<FormState> _formKey0 = GlobalKey<FormState>();
  bool isButtonActive = false;
  late TextEditingController _controller;
  bool _isfocused = false;

  final String _url = "http://ec2-13-125-142-191.ap-northeast-2.compute.amazonaws.com:3000/api/auth/university";
  List _allUniv = [];
  List _foundUniv = [];
  var _gotUniv;

  Future<void> init() async {
    http.Response _getRes = await http.get(Uri.parse(_url));
    _gotUniv = jsonDecode(utf8.decode(_getRes.bodyBytes));
    _gotUniv = _gotUniv["university_data"];
    for (int i=0; i<_gotUniv.length; i++){
      _allUniv.add(_gotUniv[i]["university_name"]);
    }
  }

  @override
  void initState(){
    init();
    _foundUniv = _allUniv;
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final isButtonActive = (_allUniv.contains(_controller.text));
      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }


  List results = [];
  void _runFilter(String enteredKeyword) {
    if (_isfocused) {
      if (enteredKeyword.isEmpty) {
        results = _allUniv;
      } else {
        results = _allUniv.where(
                (univ) => univ.toLowerCase().contains(enteredKeyword.toLowerCase())
        ).toList();
      }
    }
    setState(() {
      _foundUniv = results;
    });
  }

  late String? _data;
  Future<void> validateAndGetTo() async {
    final form = _formKey0.currentState;
    if (form!.validate()){
      form.save();
      data["college"] = _data;
      data["major_List"] = (_gotUniv[_allUniv.indexOf(_data)]["major_name"]).toString();
      Get.to(ZportRegisterPage7(), transition: Transition.rightToLeft, arguments: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Container(
                  alignment: Alignment.center,
                  width: 55,
                  height: 27,
                  decoration: BoxDecoration(
                    borderRadius : BorderRadius.circular(29),
                    color : Color.fromRGBO(239, 242, 251, 1),
                  ),
                  child: Text(
                      "1/5",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff428EFF),
                          letterSpacing: 1
                      )
                  ),
                ),
                SizedBox(height: 16),
                Text("어느 대학교를 다니셨나요?\n동문을 찾아드려요",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )
                ),
                SizedBox(height: 30),
                Form(
                  key: _formKey0,
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if(hasFocus) {
                        _isfocused = true;
                        results = _allUniv;
                      }
                    },
                    child: TextFormField(
                      onChanged: (value) => _runFilter(value),
                      style: TextStyle(fontSize: 20),
                      controller: _controller,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: _controller.clear,
                          icon: Icon(Icons.clear, size: 18,),
                        ),
                        border: InputBorder.none,
                        hintText: "대학교 입력",
                        hintStyle: TextStyle(
                          color: Colors.black26,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSaved: (text){
                        _data = text!;
                      },
                    ),
                  ),
                ),
                Divider(thickness: 2,color: _isfocused? Color(0xff428EFF) : Color.fromRGBO(239, 242, 251, 1),),
                Expanded(child: _isfocused?
                (_allUniv.contains(_controller.text)?
                 SizedBox(height: 1): _buildListView())
                    :SizedBox(height: 1)),
                SizedBox(height: 40),
                buildFlatButton(),
                SizedBox(height: 60)
              ],
            ),
          ),
        ),
      ),
    );
  }


  ListView _buildListView() {
    return ListView.builder(
                itemCount: _foundUniv.length,
                itemBuilder: (context, index) =>
                    ListTile(
                        title: Text(_foundUniv[index]),
                      onTap: () {
                          _controller.text = _foundUniv[index];
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          currentFocus.unfocus();
                      },
                    )
              );
  }

  FlatButton buildFlatButton() {
    return FlatButton(
      minWidth: 344,
      onPressed: isButtonActive? () {
        validateAndGetTo();
      }:null,
      color: Color(0xff428EFF),
      padding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
      ),
      disabledColor: Color.fromRGBO(239, 242, 251, 1),
      disabledTextColor: Colors.black26,
      textColor: Colors.white,
      child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
    );
  }
}

class ZportRegisterPage7 extends StatefulWidget {
  const ZportRegisterPage7({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage7State createState() => _ZportRegisterPage7State();
}
class _ZportRegisterPage7State extends State<ZportRegisterPage7> {

  var data = Get.arguments;
  GlobalKey<FormState> _formKey0 = GlobalKey<FormState>();
  bool isButtonActive = false;
  late TextEditingController _controller;
  bool _isfocused = false;

  List _all = [];
  List _found = [];

  List<String> grades = [];

  String dropdownValue = '21학번';

  Future<void> init() async {
    for(int i=21; i>=0; i--){
      if(i<10){
        grades.add("0"+"$i"+"학번");
      }else{grades.add("$i"+"학번");}
    }
    var _got = data["major_List"].substring(1,data["major_List"].length-1).split(', ');
    for (int i=0; i<_got.length; i++){
      _all.add(_got[i]);
    }
  }

  @override
  void initState(){
    init();
    _found = _all;
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final isButtonActive = (_all.contains(_controller.text));
      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }


  List results = [];
  void _runFilter(String enteredKeyword) {
    if (_isfocused) {
      if (enteredKeyword.isEmpty) {
        results = _all;
      } else {
        results = _all.where(
                (univ) => univ.toLowerCase().contains(enteredKeyword.toLowerCase())
        ).toList();
      }
    }
    setState(() {
      _found = results;
    });
  }

  late String? _data;
  Future<void> validateAndGetTo() async {
    final form = _formKey0.currentState;
    if (form!.validate()){
      form.save();
      data.remove("major_List");
      data["major"] = _data;
      data["grade"] = dropdownValue;
      print(data);
      Get.to(ZportRegisterPage9(), transition: Transition.rightToLeft, arguments: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    width: 55,
                    height: 27,
                    decoration: BoxDecoration(
                      borderRadius : BorderRadius.circular(29),
                      color : Color.fromRGBO(239, 242, 251, 1),
                    ),
                    child: Text(
                        "2/5",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff428EFF),
                            letterSpacing: 1
                        )
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("전공과 학번을 알려주시면\n맞춤 정보를 제공해요",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                  SizedBox(height: 30),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if(hasFocus) {
                        _isfocused = true;
                        results = _all;
                      }
                    },
                    child: TextFormField(
                      onChanged: (value) => _runFilter(value),
                      style: TextStyle(fontSize: 20),
                      controller: _controller,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: _controller.clear,
                          icon: Icon(Icons.clear, size: 18,),
                        ),
                        border: InputBorder.none,
                        hintText: "전공 입력",
                        hintStyle: TextStyle(
                          color: Colors.black26,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSaved: (text){
                        _data = text!;
                      },
                    ),
                  ),
                  Divider(thickness: 2,color: _isfocused? Color(0xff428EFF) : Color.fromRGBO(239, 242, 251, 1),),
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          height: _isfocused?
                          (_all.contains(_controller.text)? 0 : 270)
                              :0,
                          duration: Duration(milliseconds: 0),
                          child: Expanded(child: _buildListView(),),
                        ),
                        AnimatedContainer(
                          height: _all.contains(_controller.text)? 200 : 0,
                          duration: Duration(milliseconds: 0),
                          child: Column(
                            children: [
                          DropdownButton2<String>(
                            buttonPadding: const EdgeInsets.only(right: 11),
                            dropdownMaxHeight: 230,
                            scrollbarAlwaysShow: true,
                            underline: Container(height: 0),
                          value: dropdownValue,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w300,),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: grades.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                              Divider(thickness: 2,color: Color(0xff428EFF),),
                              Expanded(child: SizedBox(height: 1,)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  buildFlatButton(),
                  SizedBox(height: 60)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  ListView _buildListView() {
    return ListView.builder(
        itemCount: _found.length,
        itemBuilder: (context, index) =>
            ListTile(
              title: Text(_found[index]),
              onTap: () {
                _controller.text = _found[index];
                FocusScopeNode currentFocus = FocusScope.of(context);
                currentFocus.unfocus();
              },
            )
    );
  }

  FlatButton buildFlatButton() {
    return FlatButton(
      minWidth: 344,
      onPressed: isButtonActive? () {
        validateAndGetTo();
      }:null,
      color: Color(0xff428EFF),
      padding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
      ),
      disabledColor: Color.fromRGBO(239, 242, 251, 1),
      disabledTextColor: Colors.black26,
      textColor: Colors.white,
      child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
    );
  }
}

class ZportRegisterPage8 extends StatefulWidget {
  const ZportRegisterPage8({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage8State createState() => _ZportRegisterPage8State();
}
class _ZportRegisterPage8State extends State<ZportRegisterPage8> {

  var data = Get.arguments;
  GlobalKey<FormState> _formKey0 = GlobalKey<FormState>();
  bool isButtonActive = false;
  late TextEditingController _controller;
  late TextEditingController _siController;
  bool _isfocused = false;
  bool _isSiFocused = false;

  final String _url = "https://grpc-proxy-server-mkvo6j4wsq-du.a.run.app/v1/regcodes?regcode_pattern=*00000000";
  List _all = [];
  List _found = [];
  var _got;

  List _allSi = [];
  List _foundSi = [];
  var _gotSi;

  Future<void> init() async {
    http.Response _getRes = await http.get(Uri.parse(_url));
    _got = jsonDecode(utf8.decode(_getRes.bodyBytes));
    _got = _got["regcodes"];
    for (int i=0; i<_got.length; i++){
      _all.add(_got[i]["name"]);
    }
  }

  Future<void> initSi() async {
    String _siUrl = (_got[_all.indexOf(_controller.text)]["code"]).toString().substring(0,2);
    _siUrl = "https://grpc-proxy-server-mkvo6j4wsq-du.a.run.app/v1/regcodes?regcode_pattern="+_siUrl+"*000000&is_ignore_zero=true";
    http.Response _getRes = await http.get(Uri.parse(_siUrl));
    _gotSi = jsonDecode(utf8.decode(_getRes.bodyBytes));
    _gotSi = _gotSi["regcodes"];
    _allSi = [];
    for (int i=0; i<_gotSi.length; i++){
      _allSi.add(_gotSi[i]["name"].replaceAll(_controller.text+" ",''));
    }
    _foundSi = _allSi;
  }

  @override
  void initState(){
    init();
    _found = _all;
    super.initState();
    _controller = TextEditingController();
    _siController = TextEditingController();
    _controller.addListener(() {
      if(_all.contains(_controller.text)){
        initSi();
      }
      setState(() {
      });
    });
    _siController.addListener(() {
      final isButtonActive = (_all.contains(_controller.text)&&_allSi.contains(_siController.text));
      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    _siController.dispose();
    super.dispose();
  }


  List results = [];
  void _runFilter(String enteredKeyword) {
    if (_isfocused) {
      if (enteredKeyword.isEmpty) {
        results = _all;
      } else {
        results = _all.where(
                (univ) => univ.toLowerCase().contains(enteredKeyword.toLowerCase())
        ).toList();
      }
    }
    setState(() {
      _found = results;
    });
  }

  List siResults = [];
  void _runSiFilter(String enteredKeyword) {
      if (enteredKeyword.isEmpty) {
        siResults = _allSi;
      } else {
        siResults = _allSi.where(
                (si) => si.toLowerCase().contains(enteredKeyword.toLowerCase())
        ).toList();
      }
    setState(() {
      _foundSi = siResults;
    });
  }

  late String? _data;
  late String? _siData;
  Future<void> validateAndGetTo() async {
    final form = _formKey0.currentState;
    if (form!.validate()){
      form.save();
      data["address"] = "$_data"+" "+"$_siData";
      Get.to(ZportRegisterPage9(), transition: Transition.rightToLeft, arguments: data);
    }
  }

  void clear(){
    _controller.clear();
    _siController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    width: 55,
                    height: 27,
                    decoration: BoxDecoration(
                      borderRadius : BorderRadius.circular(29),
                      color : Color.fromRGBO(239, 242, 251, 1),
                    ),
                    child: Text(
                        "3/5",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff428EFF),
                            letterSpacing: 1
                        )
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("내 동네를 알려주시면\n더 정확한 맞춤 정보를 제공해요",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                  SizedBox(height: 30),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if(hasFocus) {
                        _isfocused = true;
                      }
                    },
                    child: TextFormField(
                      onChanged: (value) => _runFilter(value),
                      style: TextStyle(fontSize: 20),
                      controller: _controller,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: clear,
                          icon: Icon(Icons.clear, size: 18,),
                        ),
                        border: InputBorder.none,
                        hintText: "시 / 도",
                        hintStyle: TextStyle(
                          color: Colors.black26,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSaved: (text){
                        _data = text!;
                      },
                    ),
                  ),
                  Divider(thickness: 2,color: _isfocused? Color(0xff428EFF) : Color.fromRGBO(239, 242, 251, 1),),
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          height: _isfocused?
                          (_all.contains(_controller.text)? 0 : 270)
                              :0,
                          duration: Duration(milliseconds: 0),
                          child: Expanded(child: _buildListView(),),
                        ),
                        AnimatedContainer(
                          height: _all.contains(_controller.text)? 64 : 0,
                          duration: Duration(milliseconds: 0),
                          child: Column(
                            children: [
                              Focus(
                                onFocusChange: (hasSiFocus) {
                                  if(hasSiFocus) {
                                    _isSiFocused = true;
                                  }
                                },
                                child: TextFormField(
                                  onChanged: (value) => _runSiFilter(value),
                                  style: TextStyle(fontSize: 20),
                                  controller: _siController,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: _siController.clear,
                                      icon: Icon(Icons.clear, size: 18,),
                                    ),
                                    border: InputBorder.none,
                                    hintText: "시 / 군 / 구",
                                    hintStyle: TextStyle(
                                      color: Colors.black26,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onSaved: (text){
                                    _siData = text!;
                                  },
                                ),
                              ),
                              Divider(thickness: 2,color: _isSiFocused? Color(0xff428EFF) : Color.fromRGBO(239, 242, 251, 1),),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          height: _all.contains(_controller.text)?
                          (_isSiFocused?
                          (_allSi.contains(_siController.text)? 0:210)
                              :0)
                              :0,
                          duration: Duration(milliseconds: 0),
                          child: Expanded(child: ListView.builder(
                              itemCount: _foundSi.length,
                              itemBuilder: (context, index) =>
                                  ListTile(
                                    title: Text(_foundSi[index]),
                                    onTap: () {
                                      _siController.text = _foundSi[index];
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      currentFocus.unfocus();
                                    },
                                  )
                          )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  buildFlatButton(),
                  SizedBox(height: 60)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  ListView _buildListView() {
    return ListView.builder(
        itemCount: _found.length,
        itemBuilder: (context, index) =>
            ListTile(
              title: Text(_found[index]),
              onTap: () {
                _controller.text = _found[index];
                FocusScopeNode currentFocus = FocusScope.of(context);
                currentFocus.unfocus();
              },
            )
    );
  }

  FlatButton buildFlatButton() {
    return FlatButton(
      minWidth: 344,
      onPressed: isButtonActive? () {
        validateAndGetTo();
      }:null,
      color: Color(0xff428EFF),
      padding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
      ),
      disabledColor: Color.fromRGBO(239, 242, 251, 1),
      disabledTextColor: Colors.black26,
      textColor: Colors.white,
      child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
    );
  }
}

class ZportRegisterPage9 extends StatefulWidget {
  const ZportRegisterPage9({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage9State createState() => _ZportRegisterPage9State();
}
class _ZportRegisterPage9State extends State<ZportRegisterPage9> {

  var data = Get.arguments;
  String name = Get.arguments['name'];
  List labels = ['기획/아이디어','광고/마케팅','디자인','영상/콘텐츠','IT/SW','문학/시나리오','스타트업/창업','금융/경제/투자','봉사활동','뷰티/패션','헬스/스포츠','해외탐방/유학','기타'];
  List selected = [false, false, false, false, false, false, false, false, false, false, false, false, false];
  String _data="";

  Future<void> validateAndGetTo() async {
    for(int i=0; i<selected.length; i++){
      if(selected[i]==true){
        _data = _data+labels[i]+" ";
      }
    }
    _data = _data.substring(0,_data.length-1);
    data["interest_fileds"] = _data;
    Get.to(ZportRegisterPage10(), transition: Transition.rightToLeft, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    width: 55,
                    height: 27,
                    decoration: BoxDecoration(
                      borderRadius : BorderRadius.circular(29),
                      color : Color.fromRGBO(239, 242, 251, 1),
                    ),
                    child: Text(
                        "4/5",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff428EFF),
                            letterSpacing: 1
                        )
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("$name님이 관심있는 분야를\n3가지만 알려주세요",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                  SizedBox(height: 40),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      FilterChip(
                        label: Text(
                            labels[0],
                            style: TextStyle(
                                fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: selected[0]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[0]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[0],
                        onSelected: (bool value) {
                          selected[0] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[1],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[1]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[1]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[1],
                        onSelected: (bool value) {
                          selected[1] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[2],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[2]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[2]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[2],
                        onSelected: (bool value) {
                          selected[2] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[3],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[3]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[3]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[3],
                        onSelected: (bool value) {
                          selected[3] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[4],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[4]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[4]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[4],
                        onSelected: (bool value) {
                          selected[4] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[5],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[5]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[5]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[5],
                        onSelected: (bool value) {
                          selected[5] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[6],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[6]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[6]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[6],
                        onSelected: (bool value) {
                          selected[6] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[7],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[7]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[7]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[7],
                        onSelected: (bool value) {
                          selected[7] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[8],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[8]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[8]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[8],
                        onSelected: (bool value) {
                          selected[8] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[9],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[9]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[9]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[9],
                        onSelected: (bool value) {
                          selected[9] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[10],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[10]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[10]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[10],
                        onSelected: (bool value) {
                          selected[10] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[11],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[11]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[11]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[11],
                        onSelected: (bool value) {
                          selected[11] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[12],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[12]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[12]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[12],
                        onSelected: (bool value) {
                          selected[12] = value;
                          setState(() {
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: SizedBox(height: 10,)
                  ),
                  FlatButton(
                    minWidth: 344,
                    onPressed: selected.where((e) => e==true).length>=3? () {
                      validateAndGetTo();
                    }:null,
                    color: Color(0xff428EFF),
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    disabledColor: Color.fromRGBO(239, 242, 251, 1),
                    disabledTextColor: Colors.black26,
                    textColor: Colors.white,
                    child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                  ),
                  SizedBox(height: 60)
                ],
              )
          ),
        ),
      ),
    );
  }
}

class ZportRegisterPage10 extends StatefulWidget {
  const ZportRegisterPage10({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage10State createState() => _ZportRegisterPage10State();
}
class _ZportRegisterPage10State extends State<ZportRegisterPage10> {

  @override
  void initState() {
    labels = ['마케팅/광고','엔지니어링/설계','개발','영상/콘텐츠','디자인','제조/생산','경영/비즈니스','금융/경제/투자','영업','인사/교육','고객서비스/리테일','홍보/PR','공간 기획/관리','그로스','기타'];
    selected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
    _data="";
    // TODO: implement initState
    super.initState();
  }

  var data = Get.arguments;
  List labels = ['마케팅/광고','엔지니어링/설계','개발','영상/콘텐츠','디자인','제조/생산','경영/비즈니스','금융/경제/투자','영업','인사/교육','고객서비스/리테일','홍보/PR','공간 기획/관리','그로스','기타'];
  List selected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
  String _data="";

  Future<void> validateAndGetTo() async {
    for(int i=0; i<selected.length; i++){
      if(selected[i]==true){
        _data = _data+labels[i]+" ";
      }
    }
    _data = _data.substring(0,_data.length-1);
    data["interest_duty"] = _data;
    print(data);
    Get.to(ZportRegisterPage11(), transition: Transition.rightToLeft, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    width: 55,
                    height: 27,
                    decoration: BoxDecoration(
                      borderRadius : BorderRadius.circular(29),
                      color : Color.fromRGBO(239, 242, 251, 1),
                    ),
                    child: Text(
                        "5/5",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff428EFF),
                            letterSpacing: 1
                        )
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("멋지네요! 관심있는 직무도\n알려줄 수 있을까요?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                  SizedBox(height: 40),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      FilterChip(
                        label: Text(
                            labels[0],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[0]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[0]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[0],
                        onSelected: (bool value) {
                          selected[0] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[1],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[1]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[1]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[1],
                        onSelected: (bool value) {
                          selected[1] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[2],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[2]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[2]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[2],
                        onSelected: (bool value) {
                          selected[2] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[3],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[3]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[3]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[3],
                        onSelected: (bool value) {
                          selected[3] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[4],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[4]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[4]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[4],
                        onSelected: (bool value) {
                          selected[4] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[5],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[5]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[5]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[5],
                        onSelected: (bool value) {
                          selected[5] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[6],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[6]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[6]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[6],
                        onSelected: (bool value) {
                          selected[6] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[7],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[7]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[7]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[7],
                        onSelected: (bool value) {
                          selected[7] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[8],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[8]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[8]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[8],
                        onSelected: (bool value) {
                          selected[8] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[9],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[9]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.only(top: 12,bottom: 12,right: 10,left: 10),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[9]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[9],
                        onSelected: (bool value) {
                          selected[9] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[10],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[10]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.only(top: 12,bottom: 12,right: 10,left: 10),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[10]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[10],
                        onSelected: (bool value) {
                          selected[10] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[11],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[11]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.only(top: 12,bottom: 12,right: 10,left: 10),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[11]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[11],
                        onSelected: (bool value) {
                          selected[11] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[12],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[12]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[12]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[12],
                        onSelected: (bool value) {
                          selected[12] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[13],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[13]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[13]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[13],
                        onSelected: (bool value) {
                          selected[13] = value;
                          setState(() {
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(
                            labels[14],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: selected[14]? Color(0xff428EFF) : Color(0xff9B9B9B)
                            )
                        ),
                        padding: EdgeInsets.all(12),
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: selected[14]? Color(0xff428EFF):Color(0xffEFF2FB), width: 1),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xffF1F7FF),
                        showCheckmark: false,
                        selected: selected[14],
                        onSelected: (bool value) {
                          selected[14] = value;
                          setState(() {
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                      child: SizedBox(height: 10,)
                  ),
                  FlatButton(
                    minWidth: 344,
                    onPressed: selected.where((e) => e==true).length>=3? () {
                      validateAndGetTo();
                    }:null,
                    color: Color(0xff428EFF),
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    disabledColor: Color.fromRGBO(239, 242, 251, 1),
                    disabledTextColor: Colors.black26,
                    textColor: Colors.white,
                    child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                  ),
                  SizedBox(height: 60)
                ],
              )
          ),
        ),
      ),
    );
  }
}

class ZportRegisterPage11 extends StatefulWidget {
  const ZportRegisterPage11({Key? key}) : super(key: key);

  @override
  _ZportRegisterPage11State createState() => _ZportRegisterPage11State();
}
class _ZportRegisterPage11State extends State<ZportRegisterPage11> {

  var datas = Get.arguments;
  List isChecked = [true,true,true];
  final String _url = "http://ec2-13-125-142-191.ap-northeast-2.compute.amazonaws.com:3000/api/auth/users";

  Future<void> validateAndPost() async {
    var data =
      {
        "account_id" : datas["account_id"],
        "password" : datas["password"],
        "name" : datas["name"],
        "birth" : datas["birth"],
        "phone" : datas["phone"],
        "address" : datas["address"].toString(),
        "college" : datas["college"],
        "major" : datas["major"],
        "grade" : datas["grade"],
        "interest_fields" : datas["interest_fields"].toString(),
        "interest_company_type" : " ",
        "interest_duty" : datas["interest_duty"]
      };
    print(data);
    var body = json.encode(data);
    http.Response _res = await http.post(Uri.parse(_url), headers: {"Content-Type": "application/json"}, body: body);
    if(_res.statusCode == 201) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("회원가입 성공"),
            content: new Text("환영합니다. 메인 페이지로 이동합니다."),
            actions: <Widget>[
              new FlatButton(
                child: new Text("닫기"),
                onPressed: () {
                  Navigator.pop(context);
                  Get.offAll(HomePage());
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("회원가입 실패"),
            content: new Text("오류가 발생하였습니다. 다시 시도해주시기 바랍니다."),
            actions: <Widget>[
              new FlatButton(
                child: new Text("닫기"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Text("Welcome",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                        color: Color(0xff428EFF)
                    )
                ),
                SizedBox(height: 18,),
                Text("반가워요!\n앞으로 잘 부탁해요",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                ),
                SizedBox(height: 12,),
                Text("대학생들의 컨설턴트\n지포트와 함께 성장해봐요!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54
                    ),
                  textAlign: TextAlign.center,
                ),
                Expanded(child: Container() ),
                Image.asset('assets/image/register_2.png',),
                Expanded(child: Container() ),
                FlatButton(
                  minWidth: 344,
                  onPressed: () {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)
                      ),
                      context: context,
                      builder: (context){
                        return Container(
                          padding: EdgeInsets.all(24),
                          height: 360,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("지포트 이용약관 동의",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                      Text("자세히 보기",style: TextStyle(fontSize: 14,color: Colors.black54)),
                                    ],
                                  )),
                                  Checkbox(
                                    //shape: CircleBorder(),
                                    //side: BorderSide(color: Color(0xff428EFF)),
                                    //activeColor: Colors.white,
                                    //checkColor: Color(0xff428EFF),
                                    value: isChecked[0],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked[0] = value!;
                                      });
                                    },
                                  )
                                ],
                              ),
                              Expanded(child: Container()),
                              Row(
                                children: [
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("개인정보 수집 및 이용 동의",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                      Text("자세히 보기",style: TextStyle(fontSize: 14,color: Colors.black54)),
                                    ],
                                  )),
                                  Checkbox(
                                    //shape: CircleBorder(),
                                    //side: BorderSide(color: Color(0xff428EFF)),
                                    //activeColor: Colors.white,
                                    //checkColor: Color(0xff428EFF),
                                    value: isChecked[0],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked[0] = value!;
                                      });
                                    },
                                  )
                                ],
                              ),
                              Expanded(child: Container()),
                              Row(
                                children: [
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("위치정보 이용약관(선택)",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                      Text("자세히 보기",style: TextStyle(fontSize: 14,color: Colors.black54)),
                                    ],
                                  )),
                                  Checkbox(
                                    //shape: CircleBorder(),
                                    //side: BorderSide(color: Color(0xff428EFF)),
                                    //activeColor: Colors.white,
                                    //checkColor: Color(0xff428EFF),
                                    value: isChecked[0],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked[0] = value!;
                                      });
                                    },
                                  )
                                ],
                              ),
                              Expanded(child: Container()),
                              FlatButton(
                                // onPressed: isChecked.where((e) => e==true).length==3? () {
                                //   validateAndPost();
                                // }:null,
                                onPressed: (){
                                  validateAndPost();
                                },
                                minWidth: 344,
                                child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                                color: Color(0xff428EFF),
                                padding: EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)
                                ),
                                disabledColor: Color.fromRGBO(239, 242, 251, 1),
                                disabledTextColor: Colors.black26,
                                textColor: Colors.white,
                              ),
                              SizedBox(height: 40)
                            ],
                          ),
                        );
                      }
                    );
                  },
                  color: Color(0xff428EFF),
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)
                  ),
                  disabledColor: Color.fromRGBO(239, 242, 251, 1),
                  disabledTextColor: Colors.black26,
                  textColor: Colors.white,
                  child: Text('다음으로',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                ),
                SizedBox(height: 40)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
