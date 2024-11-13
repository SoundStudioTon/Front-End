import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_studio/network/noise_services.dart';
import 'package:sound_studio/network/user_services.dart';
import 'package:sound_studio/pages/graph_page.dart';
import 'package:sound_studio/pages/main_page.dart';
import 'package:sound_studio/pages/notification_page.dart';
import 'package:sound_studio/pages/user_page.dart';
import 'package:sound_studio/screens/difficulty_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool hasTakenTest = false;
  bool isLoading = true;

  final ValueNotifier<int> pageIndex = ValueNotifier(0);

  void _onNavigationItemSelected(index) {
    pageIndex.value = index;
  }

  final pages = const [
    MainPage(),
    GraphPage(),
    NotificationPage(),
    UserPage(),
  ];

  final actions = const [];

  @override
  void initState() {
    super.initState();
    _checkIfTestTaken();
  }

  Future<void> _checkIfTestTaken() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      print(accessToken);
      final hasNoiseData = await checkUserNoiseData(accessToken);

      print('NoiseData = $hasNoiseData');
      setState(() {
        hasTakenTest = hasNoiseData;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
      appBar: isLoading
          ? null
          : hasTakenTest
              ? _customAppBar()
              : null,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return hasTakenTest
                    ? _buildMainDashboard()
                    : _buildTestPrompt(
                        constraints.maxWidth, constraints.maxHeight);
              },
            ),
      bottomNavigationBar: isLoading
          ? null
          : hasTakenTest
              ? _BottomNavigationBar(onItemSelected: _onNavigationItemSelected)
              : null,
    );
  }

  _customAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            'SOUND STUDIO',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      leadingWidth: 150,
    );
  }

  Widget _buildMainDashboard() {
    return ValueListenableBuilder(
      valueListenable: pageIndex,
      builder: (context, value, child) {
        return pages[value];
      },
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

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({super.key, required this.onItemSelected});

  final ValueChanged<int> onItemSelected;

  @override
  State<_BottomNavigationBar> createState() => __BottomNavigationBarState();
}

class __BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;

  void handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Card(
      color: (brightness == Brightness.light) ? Colors.transparent : null,
      elevation: 0,
      margin: EdgeInsets.all(0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavigationBarItem(
              index: 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              isSelected: (selectedIndex == 0),
              onTap: handleItemSelected,
            ),
            _NavigationBarItem(
              index: 1,
              icon: CupertinoIcons.graph_square,
              selectedIcon: CupertinoIcons.graph_square_fill,
              isSelected: (selectedIndex == 1),
              onTap: handleItemSelected,
            ),
            _NavigationBarItem(
                index: 2,
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications,
                isSelected: (selectedIndex == 2),
                onTap: handleItemSelected),
            _NavigationBarItem(
                index: 3,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                isSelected: (selectedIndex == 3),
                onTap: handleItemSelected)
          ],
        ),
        top: false,
        bottom: true,
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem(
      {super.key,
      required this.index,
      required this.icon,
      required this.selectedIcon,
      required this.isSelected,
      required this.onTap});

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 34,
            ),
            const SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }
}
