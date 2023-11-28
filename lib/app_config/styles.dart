import 'package:flutter/material.dart';

// ----- Colors -----
const black            = Color(0xFF2C2C2C);
const white            = Color(0xFFFFFFFF);
const yellow           = Colors.yellow;
const deepPurpleAccent = Color(0xFF424685);
const deepBlue         = Color(0xFF292D4E);
const red              = Colors.red;
const green            = Colors.green;
const blue             = Colors.blue;
const grey             = Colors.grey;

// ----- Fonts -----
h1([color]) => TextStyle(
  fontFamily: 'NotoSansJP',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: color ?? black,
  height: 1.5,
);