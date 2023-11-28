import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:unique_identifier/unique_identifier.dart';
import '../app_config/styles.dart';
import '../constant/constants.dart';
import '../controller/audio_controller.dart';
import '../controller/home_controller.dart';
import '../controller/internet_controller.dart';
import '../utils/shared_pref.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController homeCon = Get.put(HomeController());
  final AudioController audioCon = Get.put(AudioController());
  final InternetController internetCon = Get.put(InternetController());
  //Unique Identifier
  String _identifier = 'Unknown';
  //Headset
  late String savedNum;
  HeadsetState? _headsetState;
  final headsetPlugin = HeadsetEvent();
  final numberCon = TextEditingController();

  // Moved to homeController
  // dynamic phoneNumber;
  // bool popStatus = false;

  @override
  void initState() {
    super.initState();
    homeCon.getDeviceInfo();//Device Info
    homeCon.getStoredSocketUrl();//Get Socket Url From SP
    homeCon.getCarrierInfo();//Sim/Carrier Info
    initialize(); // Initilize headset Settings
  }

  String mobileNumber = '';

  initialize() async{
    checkForStoredNumber();
    checkHeadsetConnectionStatus();
    initUniqueIdentifierState();
  }

  Future<void> initUniqueIdentifierState() async {
    String identifier;
    try {
      identifier = (await UniqueIdentifier.serial)!;
    } on PlatformException {
      identifier = 'identifierError'.tr;
    }
    if (!mounted) return;
    setState(() {
      _identifier = identifier;
    });
  }

  // Check for Headphone Status
  Future checkHeadsetConnectionStatus() async{
    headsetPlugin.requestPermission();
    var currentStatus = await headsetPlugin.getCurrentState;
    setState(() {
      _headsetState = currentStatus;
    });
    headsetPlugin.setListener((val) async{
      _headsetState = val;
      if(await SharedPref.read(AppConstant.justOpenedAppKey, defaultValue: "") == false){
        if(_headsetState == HeadsetState.DISCONNECT){
          // audioCon.warningSound1(true,true);

          if(homeCon.wifiList.map((e) => e['ssid']).toList().contains(homeCon.wifiname.value)){
            if(homeCon.wifiList.where((element) => element["ssid"].toString()==homeCon.wifiname.value).map((e) => e['priority']).toList().contains("high")){
              audioCon.warningSound1(true,true);
              callNumber();
            } else if (homeCon.wifiList.where((element) => element["ssid"].toString()==homeCon.wifiname.value).map((e) => e['priority']).toList().contains("mid")) {
              Future.delayed(const Duration(seconds: 10),() {
                audioCon.warningSound1(true,true);
                callNumber();
              });
            } else {
              Future.delayed(const Duration(seconds: 5),() {
                audioCon.warningSound1(true,true);
                callNumber();
              });
            }
          }
        }
        else{
          audioCon.warningSound1(false,false);
        }
        homeCon.setAuxStatusLocalLog(_headsetState);
      }
      homeCon.sendHttpRequestToServer(val);  
      await SharedPref.write(AppConstant.justOpenedAppKey, false);
      setState(() {});
    });
  }

  // Check if a number is stored or not
  checkForStoredNumber() async{
    //Check if phone number is empty
    var checkNo = await getStoredNumber();
    if(checkNo == null || checkNo == ""){
      homeCon.popStatus = false;
      showPopUp();
    } else{
      homeCon.popStatus = true;
    }
    setState(() {});
  }

  @override
  void dispose() {
    numberCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder:(_){
        return GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: yellow,
              automaticallyImplyLeading: false,
              elevation: 0,
              toolbarHeight: 70,
              flexibleSpace: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Settings Button
                    Positioned(
                      left: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Get.to(()=>const SettingsScreen());
                        }
                      ),
                    ),
                    // Title And Identifier Text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4.0),
                        Text('appbarTitle'.tr,style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4.0),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _identifier,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  //Home Main Contents
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        //Headset Connection Status
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height*0.28,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _headsetState==HeadsetState.CONNECT?deepPurpleAccent:red, //change color as per alert warnings
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height*0.28,
                            decoration: BoxDecoration(
                              color: deepPurpleAccent,
                              borderRadius: BorderRadius.circular(20.0)
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -40.0,
                                  right: 10.0,
                                  child: Icon(
                                    _headsetState==HeadsetState.CONNECT?Icons.notifications_off_outlined:Icons.notifications_active,
                                    size: 40,
                                    color: _headsetState==HeadsetState.CONNECT?white:red,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(),
                                      Icon(
                                        Icons.headset,
                                        size: 50,
                                        color: _headsetState == HeadsetState.CONNECT
                                        ? yellow
                                        : red,
                                      ),
                                      Text(auxStatusText(_headsetState), style: const TextStyle(fontSize: 20,color: white)),          
                                      const SizedBox(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        //Wifi Connection Status
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height*0.25,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16.0),
                          decoration: const BoxDecoration(
                            color: deepBlue, //change color as per alert warnings
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height*0.25,
                            decoration: BoxDecoration(
                              color: deepBlue,
                              borderRadius: BorderRadius.circular(20.0)
                            ),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(),
                                  Icon(
                                    Icons.wifi,
                                    size: 50,
                                    color: homeCon.wifiname.value==''?red:yellow,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('connecting'.tr, style: const TextStyle(fontSize: 24,color: white)),
                                      Text(homeCon.wifiname.value, style: const TextStyle(fontSize: 18,color: white)),
                                    ],
                                  ),
                                  const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //Connection Logs History
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    homeCon.deviceLog.clear();
                                  });
                                },
                                child: Text(
                                  'deviceHistory'.tr,
                                  style: const TextStyle(
                                    color:black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  )
                                )
                              ),
                              const Divider(),
                              ListView.builder(
                                itemCount: homeCon.deviceLog.length,
                                shrinkWrap: true,
                                reverse: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  return Text(homeCon.deviceLog[index]);
                                }
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height:40)
                        //Other test settings Moved to Settings_screen and variables to homeController
                        // Padding(
                        //   padding: const EdgeInsets.only(top:300),
                        //   child: Column(
                        //     children: [
                        //       // Server Url TextField
                        //       Obx(() => 
                        //         Container(
                        //           padding: const EdgeInsets.symmetric(horizontal:20.0),
                        //           child: TextField(
                        //             style: Theme.of(context).textTheme.bodyLarge,
                        //             controller: homeCon.serverUrlCon,
                        //             decoration: InputDecoration(
                        //               border: OutlineInputBorder(
                        //                 borderRadius: BorderRadius.circular(10.0),
                        //               ),
                        //               focusedBorder: OutlineInputBorder(
                        //                 borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        //                 borderRadius: BorderRadius.circular(10.0),
                        //               ),
                        //               filled: true,
                        //               enabled: homeCon.isSocketServerConnected.value?false:true,
                        //               fillColor: Theme.of(context).colorScheme.background,
                        //               hintText: 'Enter Socket Server Url',
                        //               hintStyle: const TextStyle(color: Colors.grey),
                        //               suffixIcon: IconButton(
                        //                 icon: const Icon(Icons.close),
                        //                 onPressed: (){
                        //                   if(!homeCon.isSocketServerConnected.value){
                        //                     homeCon.serverUrlCon.clear();
                        //                   }
                        //                 },
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       Obx(()=>
                        //         Padding(
                        //           padding: EdgeInsets.symmetric(horizontal:20.0,vertical: homeCon.isSocketServerConnected.value?10.0:0.0),
                        //           child: Text(homeCon.receivedDataFromServer.value,textAlign: TextAlign.center),
                        //         ),
                        //       ),
                        //       Obx(() => 
                        //         //Connect To Server
                        //         OutlinedButton(
                        //           onPressed:(){
                        //             if(homeCon.serverUrlCon.text.trim()==""){
                        //               showSnackbar('Enter Server URL to connect to.');
                        //             }
                        //             else if(homeCon.isSocketServerConnected.value){
                        //               homeCon.disconnectFromSocketServer(context);
                        //             }
                        //             else{
                        //               homeCon.connectToSocketServer(context);
                        //             }
                        //           },
                        //           style: ButtonStyle(
                        //             padding: MaterialStateProperty.all(const EdgeInsets.all(16.0)), // Adjust padding for height
                        //             backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                        //               if (states.contains(MaterialState.pressed)) {
                        //                 return homeCon.isSocketServerConnected.value?Colors.lightGreen:Colors.lightBlue; // Color when pressed
                        //               }
                        //               return homeCon.isSocketServerConnected.value?Colors.green:Colors.blue; // Default color
                        //             }),
                        //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        //               RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(8.0), // Adjust border radius
                        //               ),
                        //             ),
                        //           ),
                        //           child: Text(
                        //             homeCon.isSocketServerConnected.value?'Connected':'Connect To Server',
                        //             style: const TextStyle(
                        //               color: Colors.white, // Text color
                        //             ),
                        //           )
                        //         ),
                        //       ),
                        //       const SizedBox(height: 20),
                        //       // Change Number
                        //       ElevatedButton(
                        //         child: const Text("Change Number"),
                        //         onPressed: (){
                        //           showPopUp();
                        //         },
                        //       ),
                        //       const SizedBox(height: 20),
                        //       // Test Call
                        //       ElevatedButton(
                        //         child: const Text("Test Stored Number"),
                        //         onPressed: (){
                        //           callNumber();
                        //         },
                        //       ),
                        //       const SizedBox(height: 20),
                        //       // Wifi Page
                        //       ElevatedButton(
                        //         child: const Text("Wifi"),
                        //         onPressed: (){
                        //           Get.back();
                        //         },
                        //       ),
                        //       const SizedBox(height: 20),
                        //       Obx(()=>
                        //         Text('Device Information Package == > ${homeCon.imeiNo.value}',style: const TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 10)),
                        //       ),
                        //       Text('Unique Identifier Package == > $_identifier',style: const TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 10)),
                        //       const Text("Carrier Info"),
                        //       Text(homeCon.carrierInfo.toString().replaceAll(RegExp(r','), '\n').replaceAll('(', '').replaceAll(')', '').replaceAll('CarrierData', '')),
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  //Server Not Connected Message
                  Obx(()=>
                    homeCon.isSocketServerConnected.value
                    ? const SizedBox()
                    : Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: red,
                        ),
                        alignment: Alignment.center,
                        child: Text('notConnectedServerMsg'.tr,style: const TextStyle(color: white)),
                      ),
                    )
                  ),
                  //No Internet Message
                  GetBuilder<InternetController>(
                    init: InternetController(),
                    builder:(_){
                      internetCon.checkInternetAvailability();
                      return internetCon.connectionStatus.value != ConnectivityResult.none
                      ? const SizedBox()
                      : Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: red,
                          ),
                          alignment: Alignment.center,
                          child: Text('noInternetMsg'.tr,style: const TextStyle(color: white)),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  //Store number
  Future<void> storeNumber(String number) async {
    await SharedPref.write(AppConstant.storedPhoneKey, number);
  }

  //Get Stored Number
  getStoredNumber() async {
    final String? storedNumber = await SharedPref.read(AppConstant.storedPhoneKey, defaultValue: "");
    return storedNumber;
  }

  //Call number
  //Set The number here
  callNumber() async{
    var contact = await getStoredNumber();
    AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.CALL',
      data: 'tel:${contact ?? "9863021878"}',
    );
    await intent.launch();
  }

  //Show Pop Up
  showPopUp() async{
    var checkNumber = await getStoredNumber();
    if(checkNumber == null || checkNumber == ""){
      homeCon.popStatus = false;
      // ignore: use_build_context_synchronously
      return showDialog(
        context: context,
        builder: (context){
          return WillPopScope(
            onWillPop: ()async => homeCon.popStatus,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              title: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('popUpTitle'.tr, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                      const SizedBox(height: 20,),
                      Container(
                        height: 60,
                        width: 200,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: grey,
                              offset: Offset(0, 5),
                              blurRadius: 5
                            )
                          ]
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: InputBorder.none,
                            labelText: "hintText1".tr,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val){
                            homeCon.phoneNumber = val;
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Save Contact to Shared prefrence
                      ElevatedButton(
                        onPressed: () {
                          if(homeCon.phoneNumber != "" && homeCon.phoneNumber!=null){
                            setState(() {
                              storeNumber(homeCon.phoneNumber);
                              homeCon.popStatus = true;
                            });
                            Navigator.pop(context);
                          } else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 1000),
                                backgroundColor: red.withOpacity(0.9),
                                dismissDirection: DismissDirection.up,
                                margin: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height - 100,
                                  right: 20,
                                  left: 20
                                ),
                                behavior: SnackBarBehavior.floating,
                                content: Text("snackbarMsg1".tr, style: const TextStyle(color: Colors.white),),
                              )
                            );
                          }
                        }, 
                        child: Text('Save'.tr)
                      ),
                    ],
                  ),
                ),
              )
            ),
          );
        },
      );
    } else{
      homeCon.popStatus = true;
      // ignore: use_build_context_synchronously
      return showDialog(
        context: context, 
        builder: (context){
          return WillPopScope(
            onWillPop: ()async => homeCon.popStatus,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              title: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("popUpTitle".tr, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      Text("${'prevContact'.tr}${checkNumber ?? {'noData'.tr}}", style: const TextStyle(fontSize: 12), textAlign: TextAlign.center,),
                      Container(
                        height: 60,
                        width: 200,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: grey,
                              offset: Offset(0, 5),
                              blurRadius: 5
                            )
                          ]
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: InputBorder.none,
                            labelText: "hintText1".tr,
                          ),
                          onChanged: (val){
                            homeCon.phoneNumber = val;
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Save Contact to Shared prefrence
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog<bool>(
                            context: context,
                            builder: (context) => WillPopScope(
                              onWillPop: () async=> false,
                              child: AlertDialog(
                                title: Text("restartAppMsg".tr),
                                actions: [
                                  TextButton(
                                    onPressed: () async{
                                      // final service = FlutterBackgroundService();
                                      // var isRunning = await service.isRunning();
                                      // if (isRunning) {
                                      //   service.invoke("stopService");
                                      //   text = 'Start Service';
                                      // } else {
                                      //   service.startService();
                                      //   text = 'Stop Service';
                                      // }
                                      //Save Number and pop
                                      if(homeCon.phoneNumber != "" && homeCon.phoneNumber!=null){
                                        setState(() {
                                          storeNumber(homeCon.phoneNumber);
                                          homeCon.popStatus = true;
                                        });
                                        SystemNavigator.pop();
                                      } else{
                                        setState(() {
                                          storeNumber(checkNumber);
                                          homeCon.popStatus = true;
                                        });
                                        SystemNavigator.pop();
                                      }
                                    },
                                    child: Text("ok".tr)
                                  ),
                                ],
                              ),
                            )
                          );
                        }, 
                        child: Text("save".tr)
                      ),
                    ],
                  ),
                ),
              )
            ),
          );
        },
      );
    }
  }

  auxStatusText(state){
    if(state==HeadsetState.CONNECT){
      return "auxConnected".tr;
    }
    else if(state == HeadsetState.DISCONNECT){
      return "auxDisconnected".tr;
    }
    else{
      return "auxDisconnected".tr;
    }
  }
}