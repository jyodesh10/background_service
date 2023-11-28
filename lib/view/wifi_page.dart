// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'background_service_page.dart';

class WifiPage extends StatefulWidget {
  const WifiPage({super.key});

  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  List<WifiNetwork> wifiList = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadWifiList();
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

  TextEditingController password =TextEditingController();

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children:
              List.generate(wifiList.length, (index) => ListTile(
                title: 
                Text(wifiList[index].ssid.toString()),
                onTap: () {
                  showDialog(
                    context: context, 
                    builder: (context) => 
                      AlertDialog(
                        title: Text(wifiList[index].ssid.toString()),
                        content: Column(
                          children: [
                            TextField(
                              controller: password,
                            ),
                            MaterialButton(
                              onPressed: () {
                                WiFiForIoTPlugin.connect(wifiList[index].ssid.toString(), password: password.text.trim(), security: NetworkSecurity.WPA).whenComplete(() => Navigator.pop(context));
                              } ,
                              child: const Text('Connect'),
                            )
                          ],
                        ),
                      )
                  );
                },
              ))
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          loadWifiList();
        });
      }),
    );
  }
}