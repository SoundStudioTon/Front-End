import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/network/user_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordCheckController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isChecked = false;

  void _handleSignup() async {
    if (_formkey.currentState!.validate() && isChecked) {
      final result = await signup(emailController.text, nicknameController.text,
          passwordController.text);
      if (result) {
        Fluttertoast.showToast(msg: '회원가입이 완료되었습니다');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: '회원가입에 실패하였습니다');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChecked ? '입력 정보를 다시 확인해주세요.' : '이용약관에 동의해주세요.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이메일 검증 정규식
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    @override
    void dispose() {
      emailController.dispose();
      nicknameController.dispose();
      passwordController.dispose();
      passwordCheckController.dispose();
      super.dispose();
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Form(
            key: _formkey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.15),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'SOUND STUDIO',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06), // 간격 조정
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: '이메일',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!emailRegex.hasMatch(value)) {
                        return '올바른 이메일 형식이 아닙니다';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextFormField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      hintText: '닉네임',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '닉네임을 입력해주세요';
                      }
                      if (value.length < 2 || value.length > 10) {
                        return '닉네임은 2-10자 사이여야 합니다';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (value.length < 8) {
                        return '비밀번호는 8자 이상이어야 합니다';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return '숫자를 포함해야 합니다';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextFormField(
                    controller: passwordCheckController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '비밀번호 확인',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 한번 더 입력해주세요';
                      }
                      if (value != passwordController.text) {
                        return '비밀번호가 일치하지 않습니다';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: screenWidth * 0.1,
                        width: screenWidth * 0.1,
                        child: Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                      ),
                      Text('이용약관에 동의합니다'),
                      TextButton(
                        onPressed: () {
                          // 약관 내용 보여주기
                        },
                        child: Text(
                          '(약관 보기)',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton(
                    onPressed: _handleSignup,
                    child: Text(
                      '회원가입',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
