import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentBlock extends StatelessWidget {
  const ContentBlock(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.title,
      required this.widget,
      required this.ratioHeight});
  final String title;
  final Widget widget;
  final double screenHeight;
  final double screenWidth;

  final double ratioHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * ratioHeight,
      width: screenWidth * 0.96,
      decoration: BoxDecoration(
        color: Color.fromARGB(80, 217, 217, 217),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Spacer(),
            widget,
            Spacer(),
          ],
        ),
      ),
    );
  }
}
