import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showSnackbar(text){
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black45,
    textColor: Colors.white,
    fontSize: 16.0
  );
}