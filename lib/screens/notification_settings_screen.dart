import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _soundNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 설정', style: GoogleFonts.jua(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '알림 유형',
              style: GoogleFonts.jua(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          SwitchListTile(
            title: Text('이메일 알림'),
            subtitle: Text('중요 업데이트 및 알림을 이메일로 받기'),
            value: _emailNotifications,
            onChanged: (bool value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('푸시 알림'),
            subtitle: Text('앱 푸시 알림 받기'),
            value: _pushNotifications,
            onChanged: (bool value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('소리 알림'),
            subtitle: Text('알림 소리 설정'),
            value: _soundNotifications,
            onChanged: (bool value) {
              setState(() {
                _soundNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
