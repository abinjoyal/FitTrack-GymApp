
import 'package:flutter/material.dart';

Widget buildSectionTitle(BuildContext context, String text) {

  final Size size = MediaQuery.of(context).size;

  return Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: size.width * 0.045,
      height: 0.8,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildParagraph(BuildContext context, String text) {

  final Size size = MediaQuery.of(context).size;

  return Padding(
    padding: EdgeInsets.only(
      left: size.width * 0.035,
      top: size.height * 0.01,
      bottom: size.height * 0.01,
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white70,
        fontSize: size.width * 0.038,
        height: 1.6,
      ),
    ),
  );
}

Widget buildBullet(BuildContext context, String text) {

  final Size size = MediaQuery.of(context).size;

  return Padding(
    padding: EdgeInsets.only(
      left: size.width * 0.035,
      top: size.height * 0.007,
      bottom: size.height * 0.007,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: EdgeInsets.only(top: size.height * 0.008),
          child: Container(
            height: size.width * 0.015,
            width: size.width * 0.015,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
        ),

        SizedBox(width: size.width * 0.025),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
              fontSize: size.width * 0.038,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildCard({
  required BuildContext context,
  required String title,
  required Widget child,
}) {

  final Size size = MediaQuery.of(context).size;

  return Container(
    padding: EdgeInsets.all(size.width * 0.05),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [

        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: size.width * 0.04,
          ),
        ),

        SizedBox(height: size.height * 0.02),

        child,
      ],
    ),
  );
}
