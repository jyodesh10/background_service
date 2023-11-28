import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'wifi_page.dart';

class BackgroundServicePage extends StatefulWidget {
  const BackgroundServicePage({super.key});

  @override
  State<BackgroundServicePage> createState() => _BackgroundServicePageState();
}

class _BackgroundServicePageState extends State<BackgroundServicePage> {
  String text = "Stop Service"; 
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
          actions: [
            Builder(builder: (context) => 
              ElevatedButton(
                child: const Text("Wifi"),
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => const WifiPage(),));
                },
              ),
            )
          ],
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsForeground");
              },
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsBackground");
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke("stopService");
                } else {
                  service.startService();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.play_arrow),
        ),
      );
  }
}