import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '약관 확인',
          style: GoogleFonts.jua(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '집중도 분석을 위한 얼굴 이미지\n수집 및 이용 약관',
                  style: GoogleFonts.jua(
                    fontSize: 22,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32),
                _buildSection(
                  '1. 수집하는 얼굴 이미지 정보',
                  [
                    '학습 중 실시간으로 촬영되는 사용자의 얼굴 이미지',
                    '얼굴 인식 및 분석을 위한 특징점 데이터',
                    '집중도 분석 결과 데이터',
                  ],
                ),
                SizedBox(height: 32),
                _buildSection(
                  '2. 이미지 수집 목적',
                  [
                    '실시간 집중도 분석 서비스 제공',
                    '집중도 분석 알고리즘 개선',
                    '학습 패턴 분석 및 맞춤형 피드백 제공',
                    '서비스 품질 향상',
                  ],
                ),
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 12),
                          Text(
                            '주의사항',
                            style: GoogleFonts.jua(
                              fontSize: 18,
                              color: Colors.orange[900],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ...[
                        '수집된 얼굴 이미지는 집중도 분석 목적으로만 사용됩니다',
                        '얼굴 이미지는 분석 후 즉시 삭제되며 별도 저장되지 않습니다',
                        '분석된 데이터는 암호화되어 안전하게 보관됩니다',
                        '서비스 이용 종료 시 모든 관련 데이터는 즉시 파기됩니다',
                        '다른 사용자의 얼굴을 촬영하거나 등록하는 것은 금지됩니다',
                      ].map((text) => _buildWarningItem(text)).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.jua(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: GoogleFonts.jua(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.jua(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: Colors.orange[900],
              fontSize: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.jua(
                fontSize: 15,
                height: 1.4,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
