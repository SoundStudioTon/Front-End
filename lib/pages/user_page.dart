import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

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
                                '○○○님',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'example@gmail.com',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '010-1234-1234',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
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
                      // Action for changing password
                    },
                  ),
                  ListTile(
                    title: Text('알림 설정'),
                    onTap: () {
                      // Action for notification settings
                    },
                  ),
                  Divider(),

                  ListTile(
                    title: Text('문의하기'),
                    onTap: () {
                      // Action for contacting
                    },
                  ),
                  ListTile(
                    title: Text('로그아웃'),
                    onTap: () {
                      // Action for logout
                    },
                  ),
                  ListTile(
                    title: Text('회원 탈퇴'),
                    onTap: () {
                      // Action for account deletion
                    },
                  ),
                  ListTile(
                    title: Text('약관 확인'),
                    onTap: () {
                      // Action for terms confirmation
                    },
                  ),
                ],
              ),
            );
          },
        ));
  }
}
