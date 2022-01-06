import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled/pages/home_page.dart';
import 'package:untitled/pages/zport_register_page.dart';


class AuthPage extends StatefulWidget {

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  PageController _controller = PageController();

  OutlineInputBorder _border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xff428EFF), width: 1)
  );

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  late String _account_id;
  late String _password;

  final String _url = "http://ec2-13-125-142-191.ap-northeast-2.compute.amazonaws.com:3000/api/auth/token";

  Future<void> validateAndPost() async {
    final form = _formKey.currentState;
    if (form!.validate()){
      form.save();
      var data = {
        "account_id" : _account_id,
        "password" : _password,
      };
      var body = json.encode(data);
      http.Response _res = await http.post(Uri.parse(_url), headers: {"Content-Type": "application/json"}, body: body);
      if(_res.statusCode == 200) {
        Get.offAll(HomePage());
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text("로그인 실패"),
              content: new Text("아이디 또는 비밀번호를 다시 확인해주세요"),
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
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(32),
            children: [
              Container(
                height: 400,
                child: PageView(
                  controller: _controller,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Image.asset('assets/image/auth_1.png'),
                          SizedBox(height: 40),
                          Text(
                            '대학생들을 위한\n맞춤형 네트워킹 플랫폼',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff428EFF),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '나와 비슷한 학생들은 지금\n어떤 활동을 하고 있는지 확인해 보세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff686868),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Image.asset('assets/image/auth_2.png'),
                          Text(
                            '나만의 포트폴리오를 만들고\n멋진 팀에 합류해 봐요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff428EFF),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '나만의 포트폴리오를 작성하고,\n함께 할 팀에 어필해 보세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff686868),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Image.asset('assets/image/auth_3.png'),
                          SizedBox(height: 20),
                          Text(
                            '대학생들을 위한\n전문적인 네트워킹 플랫폼',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff428EFF),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '지포트에서 나를 준비하고,\n더 넓은 세상으로 출발하세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff686868),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotColor: Color(0xffEFF2FB),
                      activeDotColor: Color(0xff428EFF),
                      expansionFactor: 2.5,
                      dotWidth: 8.0,
                      dotHeight: 8.0
                    ),
                ),
              ),

              SizedBox(height: 80),

              FlatButton(
                onPressed: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)
                      ),
                      context: context,
                      builder: (context){
                    return Container(
                      padding: EdgeInsets.all(32),
                      //color: Colors.white,
                      height: 355,
                      child: ListView(
                        children: [
                          SizedBox(height: 25),
                          FlatButton(
                            onPressed: (){},
                            child: Text('카카오 계정으로 가입',style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                            color: Color(0xffFAE64C),
                            minWidth: 380,
                            padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)
                              )
                          ),
                          SizedBox(height: 12),
                          FlatButton(
                              onPressed: (){},
                              child: Text('Facebook 계정으로 가입',style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                              color: Color(0xff3A81EB),
                              minWidth: 380,
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)
                              )
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('또는',style: TextStyle(fontSize: 12,color: Colors.black45,letterSpacing: 5.0)),
                            ],
                          ),
                          SizedBox(height: 12),
                          OutlineButton(
                              onPressed: (){
                                Get.to(ZportRegisterPage());
                              },
                              child: Text('Zport 계정으로 가입',style: TextStyle(fontSize: 18,color: Color(0xff428EFF),fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                              color: Colors.white,
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              borderSide: BorderSide(color: Color(0xff428EFF), width: 1)
                          )
                        ],
                      ),
                    );
                  });
                },
                child: Text('회원가입',style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                color: Color(0xff428EFF),
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)
                ),
              ),

              SizedBox(height: 12),

              OutlineButton(
                onPressed: (){

                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)
                      ),
                      context: context,
                      builder: (context){
                        return Container(
                          padding: EdgeInsets.all(32),
                          height: 355,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(height: 25),
                                _account_id_BuildTextFormField("ID", "아이디를 입력하세요", _idController),
                                SizedBox(height: 12),
                                _password_BuildTextFormField("Password", "비밀번호를 입력하세요", _passwordController),
                                SizedBox(height: 40),
                                FlatButton(
                                  onPressed: (){
                                    validateAndPost();
                                  },
                                  child: Text('로그인',style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                                  color: Color(0xff428EFF),
                                  minWidth: 380,
                                  padding: EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)
                                  )
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Text('로그인',style: TextStyle(fontSize: 18,color: Color(0xff428EFF),fontWeight: FontWeight.bold,letterSpacing: 1.5)),
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)
                ),
                  borderSide: BorderSide(color: Color(0xff428EFF), width: 1)
              ),


            ],
          ),
        ),
      ),
    );

  }
  TextFormField _account_id_BuildTextFormField(String hintText, String validatorText, TextEditingController controller) {
    return TextFormField(
      inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9]|[a-z]|[A-Z]'))],
                                decoration: InputDecoration(
                                  hintText: hintText,
                                  border: _border,
                                  enabledBorder: _border,
                                  focusedBorder: _border,
                                ),
                                controller: controller,
                                validator: (text){
                                  if(text==null || text.isEmpty){
                                    return validatorText;
                                  }
                                  return null;
                                },
                                onSaved: (text){
                                  _account_id = text!;
                                },
                              );
  }
  TextFormField _password_BuildTextFormField(String hintText, String validatorText, TextEditingController controller) {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
      ),
      controller: controller,
      validator: (text){
        if(text==null || text.isEmpty){
          return validatorText;
        }
        return null;
      },
      onSaved: (text){
        _password = text!;
      },
    );
  }
}
