import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;
  final TextStyle textStyle;
  final Alignment textAlignment;
  final EdgeInsets textPadding;
  final String fontFamily;

  const CustomButton({
    Key? key,
    required this.text,
    required this.imagePath,
    required this.onPressed,

    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.textAlignment = Alignment.center,
    this.textPadding = EdgeInsets.zero,

    this.fontFamily = 'RetroGaming',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width + 300;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              width: screenWidth * 0.1,
              height: screenHeight * 0.08,
              fit: BoxFit.fill,
            ),
            Container(
              //alignment: Alignment.center, // Ensure text is centered
              //padding: EdgeInsets.zero, // Remove unnecessary padding
              alignment: textAlignment,
              padding: textPadding,
              child: Text(
                text,
                style: textStyle.copyWith(fontFamily: fontFamily),
                textAlign: TextAlign.center,
              ),
            ),

          ],
        ),
      ),
    );
  }
}