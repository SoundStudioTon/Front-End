import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('약관 확인', style: GoogleFonts.inter(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '집중도 분석을 위한 얼굴 이미지 수집 및 이용 약관',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. 수집하는 얼굴 이미지 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- 학습 중 실시간으로 촬영되는 사용자의 얼굴 이미지\n'
                      '- 얼굴 인식 및 분석을 위한 특징점 데이터\n'
                      '- 집중도 분석 결과 데이터',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '2. 이미지 수집 목적',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- 실시간 집중도 분석 서비스 제공\n'
                      '- 집중도 분석 알고리즘 개선\n'
                      '- 학습 패턴 분석 및 맞춤형 피드백 제공\n'
                      '- 서비스 품질 향상',
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '주의사항',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '- 수집된 얼굴 이미지는 집중도 분석 목적으로만 사용됩니다\n'
                            '- 얼굴 이미지는 분석 후 즉시 삭제되며 별도 저장되지 않습니다\n'
                            '- 분석된 데이터는 암호화되어 안전하게 보관됩니다\n'
                            '- 서비스 이용 종료 시 모든 관련 데이터는 즉시 파기됩니다\n'
                            '- 다른 사용자의 얼굴을 촬영하거나 등록하는 것은 금지됩니다',
                            style: TextStyle(
                              color: Colors.orange[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
