import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/network/user_services.dart';
import 'package:sound_studio/screens/account_deletion_screen.dart';
import 'package:sound_studio/screens/change_password_screen.dart';
import 'package:sound_studio/screens/contact_screen.dart';
import 'package:sound_studio/screens/logout_screen.dart';
import 'package:sound_studio/screens/notification_settings_screen.dart';
import 'package:sound_studio/screens/terms_screen.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  _fetchUserName() async {
    final name = await AuthService.storage.read(key: "userName");
    final _email = await AuthService.storage.read(key: "email");
    print(name);
    setState(() {
      username = name;
      email = _email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Card
                  Card(
                    color: Colors.white,
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${username ?? '사용자'}님',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                email ?? '',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 2),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  Row(children: [
                    Text(
                      '설정',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04),
                    )
                  ]),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  // Settings List
                  ListTile(
                    title: Text('비밀번호 변경하기'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen(),
                          ));
                    },
                  ),
                  ListTile(
                    title: Text('알림 설정'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationSettingsScreen(),
                          ));
                    },
                  ),
                  Divider(),

                  ListTile(
                    title: Text('문의하기'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactScreen(),
                          ));
                    },
                  ),
                  ListTile(
                    title: Text('로그아웃'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogoutScreen(),
                          ));
                    },
                  ),
                  ListTile(
                    title: Text('회원 탈퇴'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountDeletionScreen(),
                          ));
                    },
                  ),
                  ListTile(
                    title: Text('약관 확인'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsScreen(),
                          ));
                    },
                  ),
                ],
              ),
            );
          },
        ));
  }
}
