
import 'package:device_information/device_information.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../constant/constants.dart';
import '../utils/shared_pref.dart';
import "package:carrier_info_v3/carrier_info.dart";

import '../view/home.dart';
import '../widgets/snackbar_widget.dart';

class HomeController extends GetxController{
  TextEditingController serverUrlCon = TextEditingController();
  //Device Log
  RxList deviceLog                 = [].obs;
  //Device Info
  dynamic deviceId                 = ''.obs;
  RxString deviceName              = ''.obs;
  RxString platformVersion         = ''.obs;
  RxString imeiNo                  = ''.obs;
  RxString modelName               = ''.obs;
  RxString manufacturer            = ''.obs;
  RxString productName             = ''.obs;
  RxString cpuType                 = ''.obs;
  RxString hardware                = ''.obs;
  RxString identifier              = ''.obs;
  //wifi name
  RxString wifiname                = ''.obs;
  RxString disconnectedWifiname    = ''.obs;
  //Socket client
  late Socket socket; // Define a Socket instance
  RxBool isSocketServerConnected   = false.obs;
  RxString receivedDataFromServer  = ''.obs;
  //carrier info
  CarrierData? carrierInfo;

  bool popStatus = false;
  dynamic phoneNumber;

  List<Map<String,dynamic>> wifiList= [
    {
      "ssid":"JJ",
      "priority":"high",
    },
    {
      "ssid":"Miracle",
      "priority":"mid",
    },
    {
      "ssid":"TP-LINK_EF33_5G",
      "priority":"low",
    },
  ]; 

  //Carrier Info
  getCarrierInfo() async {
    carrierInfo = await CarrierInfo.all;
  }

  //Device Info
  getDeviceInfo()async{
    try {
      platformVersion.value         = await DeviceInformation.platformVersion;
      deviceName.value              = await DeviceInformation.deviceName;
      imeiNo.value                  = await DeviceInformation.deviceIMEINumber;
      modelName.value               = await DeviceInformation.deviceModel;
      manufacturer.value            = await DeviceInformation.deviceManufacturer;
      productName.value             = await DeviceInformation.productName;
      cpuType.value                 = await DeviceInformation.cpuName;
      hardware.value                = await DeviceInformation.hardware;
    } on PlatformException {
      platformVersion.value = 'Failed to get platform version.';
    }
  }

  //Connect To Socket Server
  connectToSocketServer(context, {bool isWifi = false}) async {
    final serverUrl = await getStoredSocketUrl();
    storeSocketUrl(serverUrl);
    // Connect to the Socket.io server
    socket = io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.off('connect');
    socket.on('connect', (_) {
      if (kDebugMode) {
        print('Connected to the server');
      }
      // You can emit events here or handle other actions upon connection.
      isSocketServerConnected.value = true;
      showSnackbar('Connected to server');
      if (isWifi) {
        sendWifiLogToServer(wifiname.value, disconnectedWifiname.value);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(),));
      }
    });
    socket.on('connect_error', (data) {
      if (kDebugMode) {
        print('Connection error: $data');
      }
      // Handle the connection error here.
      isSocketServerConnected.value = false;
      showSnackbar('Connection error: $data');
      socket.close();
    });
    // Handle incoming data
    socket.on('serverEvent', (data) {
      // Process the data as needed
      if (kDebugMode) {
        print("Received: $data");
      }
      receivedDataFromServer.value = data.toString();
    });
    socket.on('plugInStatus', (data) {
      // Process the data as needed
      if (kDebugMode) {
        print("------------PluggedIN$data ------------");
      }
      showSnackbar('Plugged In: $data');
    });
    socket.on('plugOutStatus', (data) {
      // Process the data as needed
      if (kDebugMode) {
        print("------------PluggedOut$data ------------");
      }
      showSnackbar('Plugged Out: $data');
    });

    socket.on('wifiStatus',(data) {
      if (kDebugMode) {
        print('--------------------WIFI Status$data--------------------');
      }
      showSnackbar('WifiSatats: $data');
    },);

    socket.connect();
  }

  //Disconnect From Socket Server
  disconnectFromSocketServer(context){
    socket.off('disconnect');
    socket.on('disconnect',(_){
      if (kDebugMode) {
        print('Disconnected from the server');
      }
      isSocketServerConnected.value = false;
      receivedDataFromServer.value = '';
      showSnackbar('Disconnected from server');
    });
    socket.close();
  }
  
  //Store SocketServerUrl
  Future<void> storeSocketUrl(String url) async {
    await SharedPref.write(AppConstant.socketServerUrlKey, url);
  }

  //Get Stored Socket Url
  getStoredSocketUrl() async {
    final String? storedSocketUrl = await SharedPref.read(AppConstant.socketServerUrlKey, defaultValue: "");
    if(storedSocketUrl==null||storedSocketUrl==""){
      serverUrlCon.text='http://localhost:7000/';
      return serverUrlCon.text;
    }
    else{
      serverUrlCon.text = storedSocketUrl;
      return serverUrlCon.text;
    }   
  }

  //Send Data to Node Server from flutter socket client
  void sendHttpRequestToServer(deviceStatus) async {
    if(isSocketServerConnected.value){
      String serverUrl = serverUrlCon.text.trim();
      // Create a JSON object with the message and device name
      final jsonData = {
        "notification_type": "pluggedIn", 
        "message": "Device plugged out successful", 
        "device_id": 1, 
        "device_code": imeiNo.toString(), 
        "device_name": deviceName.toString(), 
        "access_point_id": 1, 
        "access_point_code": "", 
        "access_point_name": "", 
        "building_id": 1, 
        "building_code": "", 
        "building_name": "", 
        "area_id": 1, 
        "area_code": "", 
        "area_name": "", 
        "floor": "3", 
        "danger_area_type": "", 
        "alert_type": "", 
        "active_user_id": 1, 
        "active_user_name": "", 
        "publish_flg": 1, 
        "created_at": "2023-11-29 18:18:34", 
        "updated_at": "2023-11-29 18:18:34"
      };
      socket.emit('wifiLogData', jsonData);
      // if (kDebugMode) {
      //   print(deviceStatus);
      // }
      // final url = Uri.parse("$serverUrl?$jsonData");
      // final response = await http.get(url);
      // if (response.statusCode == 200) {
      //   if (kDebugMode) {
      //     print('HTTP Request Success');
      //     print('Response data: ${response.body}');
      //   }
      //   // Handle the response as needed
      // } else {
      //   if (kDebugMode) {
      //     print('HTTP Request Failed');
      //   }
      // }
    }
  }

  void sendWifiLogToServer(wifi, disconnectedWifi) async {
    if(isSocketServerConnected.value){
      String serverUrl = await getStoredSocketUrl(); 
      // serverUrlCon.text.trim();
      // Create a JSON object with the message and device name
      final jsonData = {
        // "Wifi Connected To" : wifi,
        // "Wifi Disconnected From" : disconnectedWifi,
        // "deviceName"  : deviceName,
        // "imeiNo"      : imeiNo,
        // "modelName"   : modelName,
        // "manufacturer": manufacturer,
        // "Datetime"    : DateTime.now(),
        // // "Carrier Info": carrierInfo.toString().replaceAll('(', '').replaceAll(')', '').replaceAll('CarrierData', ''),
        // "carrierName" : carrierInfo!.carrierName.toString(),
        // "cid" : carrierInfo!.cid.toString(),
        // "isoCountryCode" : carrierInfo!.isoCountryCode.toString(),
        // "lac" : carrierInfo!.lac.toString(),
        // "mobileCountryCode" : carrierInfo!.mobileCountryCode.toString(),
        // "mobilenetworkCode" : carrierInfo!.mobileNetworkCode.toString(),
        // "mobileNetworkOperator" : carrierInfo!.mobileNetworkOperator.toString(),
        // "networkgeneration" : carrierInfo!.networkGeneration.toString(),
        // "radiotype" : carrierInfo!.radioType.toString(),
        // "allowsVOIP" : carrierInfo!.allowsVOIP.toString(),
        "linked_state":'connected',
        "linked_state_datetime": "",
        "device_id": "",
        "device_code": "",
        "device_name": "",
        "access_point_id": "",
        "access_point_code": "",
        "access_point_name": "",
        "building_id": "",
        "building_code": "",
        "building_name": "",
        "area_id": "",
        "area_code": "",
        "area_name": "",
        "floor": "",
        "danger_area_type": "",
        "alert_type": "",
        "active_user_id": "",
        "active_user_name": "",
        "publish_flg": 1,
        "created_at": "",
        "updated_at": ""
      };
      socket.emit('wifiLogData', jsonData);
      // if (kDebugMode) {
      //   print(wifi);
      // }
      // final url = Uri.parse('$serverUrl/api/v1/forecast?count=$jsonData');
      // final response = await http.get(url);
      // if (response.statusCode == 200) {
      //   if (kDebugMode) {
      //     print('HTTP Request Success');
      //     print('Response data: ${response.body}');
      //   }
      //   // Handle the response as needed
      // } else {
      //   if (kDebugMode) {
      //     print('HTTP Request Failed');
      //   }
      // }
    }
    // sendWifiLogToServer(wifi,disconnectedWifi);
  }

  //Add Log To Device Log List Aux Headset Status Change
  void setAuxStatusLocalLog(status){
    DateTime time;
    String log;
    time = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(time);
    if(status == HeadsetState.CONNECT){
      log = "$formattedTime [Connected] AUX Connected";
      deviceLog.add(log);
    }
    else if(status == HeadsetState.DISCONNECT){
      log = "$formattedTime [Disconnected] AUX Disconnected";
      deviceLog.add(log);
    }
  }

  //Add Log To Device Log List Network Change
  void setNetworkChangeLog(wifi,disconnectedWifi){
    DateTime time;
    String connectedLog;
    String disconnectedLog;
    time = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(time);
    connectedLog = "$formattedTime [Connected] $wifi";
    deviceLog.add(connectedLog);
    disconnectedLog = "$formattedTime [Disconnected] $disconnectedWifi";
    deviceLog.add(disconnectedLog);
  }
}