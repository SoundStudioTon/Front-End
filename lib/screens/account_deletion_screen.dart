import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({Key? key}) : super(key: key);

  @override
  _AccountDeletionScreenState createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  bool _confirmDeletion = false;
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 탈퇴', style: GoogleFonts.inter(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '회원 탈퇴 시 주의사항',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '- 모든 학습 데이터가 즉시 삭제됩니다\n'
                      '- 삭제된 데이터는 복구할 수 없습니다\n'
                      '- 집중도 분석 결과와 통계가 모두 삭제됩니다\n'
                      '- 등록된 개인정보는 즉시 파기됩니다',
                      style: TextStyle(
                        color: Colors.red[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('위의 주의사항을 모두 읽었으며 동의합니다'),
              value: _confirmDeletion,
              onChanged: (bool? value) {
                setState(() {
                  _confirmDeletion = value ?? false;
                });
              },
              activeColor: Colors.red,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_confirmDeletion
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('회원 탈퇴 확인'),
                            content: Text('정말로 탈퇴하시겠습니까?\n이 작업은 취소할 수 없습니다.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // 회원 탈퇴 로직 구현
                                },
                                child: Text(
                                  '탈퇴',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('회원 탈퇴'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
