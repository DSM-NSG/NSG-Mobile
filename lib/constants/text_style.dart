import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';

class NsgTextStyle {
  /// header
  static const TextStyle header1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600
  );

  static const TextStyle header2 = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600
  );

  static const TextStyle header3 = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600
  );

  static const TextStyle header4 = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600
  );

  ///body
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400
  );

  static const TextStyle body2 = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400
  );

  static const TextStyle body3 = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400
  );

  static const TextStyle body4 = TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w400
  );
}

const TextStyle defaultTextStyle = TextStyle(
  color: NsgColor.black800,
  fontFamily: 'LINESeedKR',
);