import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static initializePermission() async{
    await requestNearbyPermission();
    await requestLocationPermission();
    await requestNotificationPermission();
    await requestPhonePermission();
  }

  // Request for Nearby permission
  static requestNearbyPermission() async {
    var status = await Permission.bluetoothAdvertise.request();
    if (status.isGranted) {
      // Phone permission granted
      debugPrint("Nearby permission granted.");
    } else {
      if (status.isDenied) {
        // Phone permission denied
        debugPrint("Nearby permission denied.");
      } else if (status.isPermanentlyDenied) {
        // Phone permission permanently denied
        debugPrint("Nearby permission permanently denied. You should open app settings to grant it.");
      }
    }
  }

  // Request for Notification permission
  static  requestNotificationPermission() async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      // Notification permission granted
      debugPrint("Notification permission granted.");
    } else {
      if (status.isDenied) {
        // Notification permission denied
        debugPrint("Notification permission denied.");
      } else if (status.isPermanentlyDenied) {
        // Notification permission permanently denied
        debugPrint("Notification permission permanently denied. You should open app settings to grant it.");
      }
    }
  }

  // Request for Phone permission
  static requestPhonePermission() async {
    var status = await Permission.phone.request();
    if (status.isGranted) {
      // Phone permission granted
      debugPrint("Phone permission granted.");
    } else {
      if (status.isDenied) {
        // Phone permission denied
        debugPrint("Phone permission denied.");
      } else if (status.isPermanentlyDenied) {
        // Phone permission permanently denied
        debugPrint("Phone permission permanently denied. You should open app settings to grant it.");
      }
    }
  }


  // Request for Loacation permission
  static requestLocationPermission() async {
    var status = await Permission.locationAlways.request();
    if (status.isGranted) {
      // Phone permission granted
      debugPrint("Loacation permission granted.");
    } else {
      if (status.isDenied) {
        // Phone permission denied
        debugPrint("Loacation permission denied.");
      } else if (status.isPermanentlyDenied) {
        // Phone permission permanently denied
        debugPrint("Loacation permission permanently denied. You should open app settings to grant it.");
      }
    }
  }

}