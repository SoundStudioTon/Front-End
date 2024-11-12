import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_studio/network/user_services.dart';
import 'package:sound_studio/screens/difficulty_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool hasTakenTest = false;

  @override
  void initState() {
    super.initState();
    _checkIfTestTaken();
    print(hasTakenTest);
  }

  Future<void> _checkIfTestTaken() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      print(accessToken);
      final hasNoiseData = await checkUserNoiseData(accessToken);

      print(hasNoiseData);
      if (hasNoiseData) {
        hasTakenTest = true;
      } else {
        hasTakenTest = false;
      }
    }
  }

  Future<void> _setTestTaken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasTakenTest', true);
    setState(() {
      hasTakenTest = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: hasTakenTest ? Colors.white : Colors.grey,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return hasTakenTest
                ? _buildMainDashboard()
                : _buildTestPrompt(constraints.maxWidth, constraints.maxHeight);
          },
        ));
  }

  Widget _buildMainDashboard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '오늘의 집중도 확인',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 10),
        CircleAvatar(
          radius: 50,
          child: Text(
            '68',
            style: TextStyle(fontSize: 40),
          ),
        ),
        SizedBox(height: 20),
        Text(
          '총 학습시간',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '8시간 33분',
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _setTestTaken,
          child: Text('소음 테스트 다시 진행하기'),
        ),
      ],
    );
  }

  Widget _buildTestPrompt(width, height) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height * 0.1,
            ),
            Text(
              '저희 앱에 처음으로 로그인하셨습니다\n앱 사용을 위해 아래의 테스트를 진행해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.05),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DifficultyScreen(),
                    ));
              },
              child: Text(
                '소음테스트 진행하기',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                  padding: EdgeInsets.symmetric(
                      vertical: height * 0.02, horizontal: width * 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  )),
            ),
            SizedBox(
              height: height * 0.1,
            )
          ],
        ),
      ),
    );
  }
}
