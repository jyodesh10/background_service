// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../controller/home_controller.dart';
import '../widgets/snackbar_widget.dart';
import 'background_service_page.dart';
import 'home.dart';

class WifiPage extends StatefulWidget {
  const WifiPage({super.key});

  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  List<WifiNetwork> wifiList = [];
  bool loading = false;
  String? wifiName = "";
  String? wifiIp = "";
  String? wifiBssid = "";
  int? wifiFreq = 0;
  int? wifiCurrentSt = 0;
  List<Map<String,String>> whiteListed = [
    {"ssid" : "asdsaf", "password": "29199532"},
    {"ssid" : "Miracle Dev", "password": "Miracle@Dev"},
    {"ssid" : "Miracle", "password": "Miracle@2021"},
    {"ssid" : "TP-LINK_EF33_5G", "password": "29199532"},
    {"ssid" : "JJ", "password": "12345678"},
    {"ssid" : "XXSS", "password": "sagin123"},
  ];

  final homeCon = Get.put(HomeController());
  TextEditingController passcon = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeCon.getDeviceInfo();//device info
    homeCon.getStoredSocketUrl();//get socket url from sp
    homeCon.getCarrierInfo();
  }

  fetchAll() async  {
    await getWifiInfo();
    await loadWifiList();
    bool hasSsid = false;
    Map<String,String> data ={};
    for (var i = 0; i < whiteListed.length; i++) {
      if(wifiList.map((e) => e.ssid.toString()).toList().contains(whiteListed[i]['ssid'])) {
        hasSsid = true;
        data = whiteListed[i];
      }
    }

    if(hasSsid) {
      if(whiteListed.where((element) => element['ssid'].toString() == wifiName).isNotEmpty) {
        // bool result = await WiFiForIoTPlugin.connect(
        //   whiteListed[0]['ssid'].toString(), 
        //   joinOnce: true,
        //   password: whiteListed[0]['password'].toString(),
        // );
        // if(result){
        // setState(() {
        //   fetchAll();
        // });
        // }
      } else {
        setState(() {
          passcon.text = data['password'].toString();
          _buildDialog(context, data['ssid'].toString());
        });
      }
    }

    if(whiteListed.map((e) => e['ssid']).contains(wifiName)){
      homeCon.wifiname.value = wifiName.toString();
      Get.to(() => const HomePage());
    }
  }

  Future<List<WifiNetwork>> loadWifiList() async {
    wifiList.clear();
    loading = true;
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      htResultNetwork = <WifiNetwork>[];
    }
    log(htResultNetwork.map((e) => e.ssid).toString());
    wifiList.addAll(htResultNetwork);
    setState(() {
      loading = false;
    });
    return htResultNetwork;
  }

  getWifiInfo() async {
    var status = await Permission.location.request();
    final wifistatus = await WiFiForIoTPlugin.isEnabled();
    if (wifistatus) {
    } else {
      if(context.mounted){
        showSnackbar( "turnOnWifi".tr);
      }
    }
    if(status.isGranted){
      wifiName = await WiFiForIoTPlugin.getSSID();
      wifiIp =  await WiFiForIoTPlugin.getIP();
      wifiFreq = await WiFiForIoTPlugin.getFrequency();
      wifiCurrentSt = await WiFiForIoTPlugin.getCurrentSignalStrength();
      wifiBssid = await WiFiForIoTPlugin.getBSSID();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BackgroundServicePage(),));
          }, icon: const Icon(Icons.backup_table_sharp))
        ],
      ),
      body: _buildWifiView(),
      // SafeArea(
      //   child: SingleChildScrollView(
      //     child: Column(
      //       children:
      //         List.generate(wifiList.length, (index) => ListTile(
      //           title: 
      //           Text(wifiList[index].ssid.toString()),
      //           onTap: () {
      //             showDialog(
      //               context: context, 
      //               builder: (context) => 
      //                 AlertDialog(
      //                   title: Text(wifiList[index].ssid.toString()),
      //                   content: Column(
      //                     children: [
      //                       TextField(
      //                         controller: password,
      //                       ),
      //                       MaterialButton(
      //                         onPressed: () {
      //                           WiFiForIoTPlugin.connect(wifiList[index].ssid.toString(), password: password.text.trim(), security: NetworkSecurity.WPA).whenComplete(() => Navigator.pop(context));
      //                         } ,
      //                         child: const Text('Connect'),
      //                       )
      //                     ],
      //                   ),
      //                 )
      //             );
      //           },
      //         ))
      //     ),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          fetchAll();
        });
      },
      child: const Icon(Icons.refresh),
      ),
    );
  }

  _buildWifiView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //conected 
          GestureDetector(
            onTap: () => Get.to(()=> const HomePage()),
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 15),
              child: Text("Connected To :", style: const TextTheme().bodyMedium,),
            ),
          ),
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(15),
            shape: Border.all(color: Colors.green),
            child: ListTile(
              onTap: () {
              },
              title: Text(wifiName.toString()),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wifiBssid.toString()),
                  Text(wifiIp.toString()),
                  Text(wifiFreq.toString()),
                  Text(wifiCurrentSt.toString()),
                ],
              ),
            ),
          ),
          loading 
          ? const Center(
            child: CircularProgressIndicator(),
          )
          : ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(15),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wifiList.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  if(whiteListed.map((e) => e['ssid']).contains(wifiList[index].ssid.toString())){
                    _buildDialog(context, wifiList[index].ssid.toString());
                  }
                },
                title: Text(wifiList[index].ssid.toString()),
                subtitle: Text(wifiList[index].bssid.toString()),
                leading: Icon(Icons.circle, color: whiteListed.map((e) => e['ssid']).contains(wifiList[index].ssid.toString())? Colors.green : Colors.grey.shade300,),
                trailing: wifiName!.replaceAll(RegExp(r'"'), '') == wifiList[index].ssid.toString() 
                  ? const Text( "Connected", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold ))
                  : Container(
                    width: 1,
                  )
              );
            }, 
          )
        ],
      ),
    );
  }

  void _buildDialog(BuildContext context, String ssid) {
    bool connecting = false;
    showDialog(context: context, 
      barrierDismissible: false,
      builder: (context) => 
      AlertDialog(
        title: Text(ssid.toString(),),
        content: StatefulBuilder(
          builder: (context, setState) => 
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passcon,
                decoration: const InputDecoration(
                  hintText: "Password"
                ),
              ),
              MaterialButton(
                onPressed: () async {                 
                    setState((){
                      connecting=true;
                    }); 
                    bool result = await WiFiForIoTPlugin.connect(
                      ssid.toString(), 
                      // bssid: wifiList[index].bssid.toString(),
                      // isHidden: false,
                      // joinOnce: true,
                      password: passcon.text,
                      security: NetworkSecurity.WPA,
                      // withInternet: true,
                      // timeoutInSeconds: 5  
                    ).whenComplete(() {
                      homeCon.disconnectedWifiname.value = wifiName.toString();
                    });
                    if(result == true){
                      bool wifiusage = await WiFiForIoTPlugin.forceWifiUsage(true);
                      log("Connected To : $ssid");
                      log("wifi usage : $wifiusage");
                      homeCon.wifiname.value = ssid;
                      setState(() {
                        connecting=false;
                        Navigator.pop(context);
                        homeCon.connectToSocketServer(context, isWifi: true);
                        fetchAll();
                      });
                    } else {
                      setState((){
                        connecting=false;
                      });
                      log("Error connecting to $ssid");
                    }
                  passcon.clear();

                },
                color: Colors.green,
                child: Text(connecting ? "Connecting..." : "Connect", style: const TextStyle(color: Colors.white), ),
              )
            ],
          ),
        )
      )
    );
  }
}