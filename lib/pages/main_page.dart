import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/data/concentration_data.dart';
import 'package:sound_studio/network/concentration_services.dart';
import 'package:sound_studio/screens/difficulty_screen.dart';
import 'package:sound_studio/ui/concentration_pie_chart.dart';
import 'package:sound_studio/ui/content_block.dart';
import 'package:sound_studio/ui/scrollable_concentration_chart.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ConcentrationServices concentrationServices = ConcentrationServices();
  bool _isLoading = true;
  List<ConcentrationData> _hourlyData = [];
  double _averageConcentration = 0;
  Duration _totalStudyTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchTodayData();
  }

  Future<void> _fetchTodayData() async {
    try {
      // 오늘 날짜의 데이터 가져오기
      final concentrationResponses =
          await concentrationServices.getDayConcentartionData(DateTime.now());

      // 시간별로 데이터 그룹화
      Map<int, List<ConcentrationResponse>> hourlyGroups = {};

      // 받아온 데이터 그룹화
      for (var response in concentrationResponses) {
        print('response = ${response.date}');
        int hour = response.date.hour;
        print('hour = $hour');
        hourlyGroups.putIfAbsent(hour, () => []);
        hourlyGroups[hour]!.add(response);
      }

      // 24시간에 대한 데이터 생성
      List<ConcentrationData> hourlyConcentrations = [];
      double totalConcentration = 0;
      int validHourCount = 0;
      Duration studyTime = Duration.zero;

      // 모든 시간대(0-23시)에 대해 데이터 생성
      for (int hour = 0; hour < 24; hour++) {
        if (hourlyGroups.containsKey(hour)) {
          var responses = hourlyGroups[hour]!;
          // 0이 아닌 데이터만 필터링
          var validResponses = responses.where((r) => r.value != '0').toList();

          if (validResponses.isNotEmpty) {
            // 집중도 계산
            int concentratedCount =
                validResponses.where((r) => r.value == '집중함').length;
            double concentrationRate =
                (concentratedCount / validResponses.length) * 100;

            totalConcentration += concentrationRate;
            validHourCount++;
            studyTime += Duration(seconds: validResponses.length);

            hourlyConcentrations.add(ConcentrationData(
              hour: hour.toDouble(),
              concentrationRate: concentrationRate,
            ));
          } else {
            // 유효한 데이터가 없는 경우 0으로 설정
            hourlyConcentrations.add(ConcentrationData(
              hour: hour.toDouble(),
              concentrationRate: 0,
            ));
          }
        } else {
          // 해당 시간대의 데이터가 없는 경우 0으로 설정
          hourlyConcentrations.add(ConcentrationData(
            hour: hour.toDouble(),
            concentrationRate: 0,
          ));
        }
      }

      // 평균 집중도 계산 (유효한 데이터가 있는 시간대만 고려)
      double averageConcentration =
          validHourCount > 0 ? totalConcentration / validHourCount : 0;

      setState(() {
        _hourlyData = hourlyConcentrations;
        _averageConcentration = averageConcentration;
        _totalStudyTime = studyTime;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching concentration data: $e');

      List<ConcentrationData> emptyData = List.generate(
        24,
        (hour) => ConcentrationData(
          hour: hour.toDouble(),
          concentrationRate: 0,
        ),
      );

      setState(() {
        _hourlyData = emptyData;
        _averageConcentration = 0;
        _totalStudyTime = Duration.zero;
        _isLoading = false;
      });
    }
  }

  String formatStudyTime() {
    int hours = _totalStudyTime.inHours;
    int minutes = (_totalStudyTime.inMinutes % 60);
    return '${hours}시간 ${minutes}분';
  }

  Widget _buildConcentrationWidget(double screenHeight) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(
        color: Colors.black,
      ));
    }

    // 오늘의 데이터가 전혀 없는 경우 (평균 집중도가 0)
    if (_averageConcentration == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '오늘은 아직 학습을 진행하지 않았습니다!',
              style: GoogleFonts.jua(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '학습을 시작해주세요 😊',
              style: GoogleFonts.jua(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 데이터가 있는 경우 원형 그래프 표시
    return Center(
      child: ConcentrationPieChart(
        percentage: _averageConcentration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double screenHeight = constraints.maxHeight;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.05),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      ContentBlock(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: '오늘의 집중도 확인',
                        widget: SizedBox(
                            height: screenHeight * 0.3 < 250
                                ? 250
                                : screenHeight * 0.3,
                            child: _buildConcentrationWidget(screenHeight)),
                        ratioHeight: 0.45,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ContentBlock(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        ratioHeight: 0.50,
                        title: '시간대별 집중도 그래프',
                        widget: SizedBox(
                          height: screenHeight * 0.4 < 260
                              ? 260
                              : screenHeight * 0.4,
                          child: ScrollableConcentrationChart(
                            data: _hourlyData,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ContentBlock(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: '총 학습 시간',
                        widget: Center(
                          child: Text(
                            formatStudyTime(),
                            style: GoogleFonts.doHyeon(
                              fontSize: screenWidth * 0.1,
                            ),
                          ),
                        ),
                        ratioHeight: 0.4,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DifficultyScreen(),
                            ),
                          );
                        },
                        child: Text(
                          '소음테스트 다시 진행하기',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                            horizontal: screenWidth * 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
