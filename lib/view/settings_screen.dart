import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../app_config/styles.dart';
import '../constant/constants.dart';
import '../controller/home_controller.dart';
import '../utils/shared_pref.dart';
import '../widgets/snackbar_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HomeController homeCon = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                //Server Url TextField
                Obx(() => 
                  TextField(
                    style: Theme.of(context).textTheme.bodyLarge,
                    controller: homeCon.serverUrlCon,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: blue, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      enabled: homeCon.isSocketServerConnected.value?false:true,
                      fillColor: Theme.of(context).colorScheme.background,
                      hintText: 'Enter Socket Server Url',
                      hintStyle: const TextStyle(color: grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: (){
                          if(!homeCon.isSocketServerConnected.value){
                            homeCon.serverUrlCon.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                //Server Returned Data
                Obx(()=>
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:20.0,vertical: homeCon.isSocketServerConnected.value?10.0:0.0),
                    child: Text(homeCon.receivedDataFromServer.value,textAlign: TextAlign.center),
                  ),
                ),
                //Server Connect Disconnect Button
                Obx(() => 
                  //Connect To Server
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed:(){
                        if(homeCon.serverUrlCon.text.trim()==""){
                          showSnackbar('Enter Server URL to connect to.');
                        }
                        else if(homeCon.isSocketServerConnected.value){
                          homeCon.disconnectFromSocketServer(context);
                        }
                        else{
                          homeCon.connectToSocketServer(context);
                        }
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.all(16.0)), // Adjust padding for height
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return homeCon.isSocketServerConnected.value?green:blue; // Color when pressed
                          }
                          return homeCon.isSocketServerConnected.value?green:blue; // Default color
                        }),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Adjust border radius
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.cable,color: homeCon.isSocketServerConnected.value?red:green),
                          const SizedBox(width: 10),
                          Text(
                            homeCon.isSocketServerConnected.value?'CONNECTED':'CONNECT TO SERVER',
                            style: const TextStyle(
                              color: white, // Text color
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                //Change Number
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text("Change Stored Number"),
                    onPressed: (){
                      showPopUp();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                //Test Call
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      ),
                    ),
                    child: const Text("Test Call Stored Number"),
                    onPressed: (){
                      callNumber();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                //Wifi Page
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      ),
                    ),
                    child: const Text("Wifi Settings"),
                    onPressed: (){
                      Get.back();
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Carrier Info",style: TextStyle(fontSize: 25)),
                const SizedBox(height: 20),
                Text(homeCon.carrierInfo.toString().replaceAll(RegExp(r','),'\n').replaceAll('(', '').replaceAll(')', '').replaceAll('CarrierData', '').trim()),
              ],
            ),
          )
        ) 
      ),
    );
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

  //Get Stored Number
  getStoredNumber() async {
    final String? storedNumber = await SharedPref.read(AppConstant.storedPhoneKey, defaultValue: "");
    return storedNumber;
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
                      const Text("Enter a Contact that you want to call", style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 223, 223, 223),
                              offset: Offset(0, 5),
                              blurRadius: 5
                            )
                          ]
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            labelText: "Enter a contact",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val){
                            homeCon.phoneNumber = val;
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 20,),
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
                                backgroundColor: Colors.red.withOpacity(0.9),
                                dismissDirection: DismissDirection.up,
                                margin: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height - 100,
                                  right: 20,
                                  left: 20),
                                behavior: SnackBarBehavior.floating,
                                content: const Text("Please Enter a Contact First.", style: TextStyle(color: Colors.white),),
                              )
                            );
                          }
                        }, 
                        child: const Text("Save")
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
                      const Text("Enter a Contact that you want to call", style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                      const SizedBox(height: 20,),
                      Text("Prev Contact: ${checkNumber ?? "No Data"}", style: const TextStyle(fontSize: 12), textAlign: TextAlign.center,),
                      Container(
                        height: 60,
                        width: 200,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 223, 223, 223),
                              offset: Offset(0, 5),
                              blurRadius: 5
                            )
                          ]
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            labelText: "Enter a contact",
                          ),
                          onChanged: (val){
                            homeCon.phoneNumber = val;
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 20,),
                      //Save Contact to Shared prefrence
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog<bool>(
                            context: context,
                            builder: (context) => WillPopScope(
                              onWillPop: () async=> false,
                              child: AlertDialog(
                                title: const Text("You will need to restart the App to change the contact."),
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
                                    child: const Text("OK")
                                  ),
                                ],
                              ),
                            )
                          );
                        }, 
                        child: const Text("Save")
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

  //Store number
  Future<void> storeNumber(String number) async {
    await SharedPref.write(AppConstant.storedPhoneKey, number);
  }
}