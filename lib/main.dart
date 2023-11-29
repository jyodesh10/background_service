import 'dart:async';
import 'package:background_service_test/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_config/app_translations.dart';
import 'constant/constants.dart';
import 'services/background_services.dart';
import 'services/permission_services.dart';
import 'utils/shared_pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPref.init();
  await initializeService();
  await PermissionManager.initializePermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SharedPref.write(AppConstant.socketServerUrlKey, "http://192.168.1.117:7000/");
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'title'.tr,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      translations: AppTranslations(),
      locale: const Locale('ja', 'JP'),
      fallbackLocale: const Locale('ja', 'JP'),
      home: const SlpashScreen()
    );
  }
}

