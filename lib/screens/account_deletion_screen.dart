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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '회원 탈퇴',
          style: GoogleFonts.jua(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_rounded,
                            color: Colors.red[900], size: 24),
                        SizedBox(width: 12),
                        Text(
                          '회원 탈퇴 시 주의사항',
                          style: GoogleFonts.jua(
                            fontSize: 20,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildWarningText('모든 학습 데이터가 즉시 삭제됩니다'),
                    _buildWarningText('삭제된 데이터는 복구할 수 없습니다'),
                    _buildWarningText('집중도 분석 결과와 통계가 모두 삭제됩니다'),
                    _buildWarningText('등록된 개인정보는 즉시 파기됩니다'),
                  ],
                ),
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.jua(fontSize: 16),
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  labelStyle: GoogleFonts.jua(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red[900]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              SizedBox(height: 24),
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.grey[400],
                ),
                child: CheckboxListTile(
                  title: Text(
                    '위의 주의사항을 모두 읽었으며 동의합니다',
                    style: GoogleFonts.jua(fontSize: 15),
                  ),
                  value: _confirmDeletion,
                  onChanged: (bool? value) {
                    setState(() {
                      _confirmDeletion = value ?? false;
                    });
                  },
                  activeColor: Colors.red[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: !_confirmDeletion
                      ? null
                      : () => _showDeleteConfirmDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    '회원 탈퇴',
                    style: GoogleFonts.jua(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: Colors.red[900],
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.jua(
                fontSize: 15,
                color: Colors.red[900],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '회원 탈퇴 확인',
          style: GoogleFonts.jua(fontSize: 20),
        ),
        content: Text(
          '정말로 탈퇴하시겠습니까?\n이 작업은 취소할 수 없습니다.',
          style: GoogleFonts.jua(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.jua(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // 회원 탈퇴 로직 구현
            },
            child: Text(
              '탈퇴',
              style: GoogleFonts.jua(
                color: Colors.red[900],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
