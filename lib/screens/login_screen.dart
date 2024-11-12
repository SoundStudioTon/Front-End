import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/network/user_services.dart';
import 'package:sound_studio/screens/main_screen.dart';
import 'package:sound_studio/screens/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight;
          double screenWidth = constraints.maxWidth;

          return Column(
            children: [
              SizedBox(
                height: screenHeight * 0.15,
              ),
              Center(
                child: Text(
                  'SOUND STUDIO',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 50,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.1,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.2, right: screenWidth * 0.2),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.025,
                      horizontal: screenWidth * 0.02,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.2, right: screenWidth * 0.2),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.025,
                      horizontal: screenWidth * 0.02,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              ElevatedButton(
                onPressed: () async {
                  final loginResponse = await login(
                      emailController.text, passwordController.text);

                  print(loginResponse);
                  if (loginResponse == true) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(),
                        ));
                  } else {
                    Fluttertoast.showToast(
                        msg: '이메일 또는 비밀번호를 다시 확인해주세요.',
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        fontSize: 16.0,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM);
                  }
                },
                child: Text(
                  '로그인',
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(screenWidth * 0.61, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ));
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.black),
                  )),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  socialLoginButton('assets/google_login_icon.png',
                      screenWidth * 0.07, screenWidth * 0.07),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  socialLoginButton('assets/kakao_login_icon.png',
                      screenWidth * 0.07, screenWidth * 0.07),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  socialLoginButton('assets/naver_login_icon.png',
                      screenWidth * 0.07, screenWidth * 0.07),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget socialLoginButton(
          String imageURL, double buttonWidth, double buttonHeight) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          // 카카오 로그인을 위한 메소드
          onTap: () {
            // 버튼을 눌렀을 때 실행되는 함수
          },
          child: Ink(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imageURL),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(3), // 둥근 모서리 설정
            ),
            width: buttonWidth, // 이미지의 가로 크기
            height: buttonHeight, // 이미지의 세로 크기
          ),
        ),
      );
}
