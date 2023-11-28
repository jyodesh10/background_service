import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class InternetController extends GetxController{
  Rx<ConnectivityResult> connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize connectivity check
    checkInternetAvailability();
    // Subscribe to the connectivity stream
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      connectionStatus.value = result;
      update();
    });
  }
  
  Future<void> checkInternetAvailability() async {
    // Initial connection status
    final result = await Connectivity().checkConnectivity();
    connectionStatus.value = result;
    // log(result.toString());
    update();
  }
}

