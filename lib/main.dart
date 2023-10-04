import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// void main() => runApp(MyApp());

class TimerController extends GetxController {
  bool isStart = false;
  late String hourString;
  late String minuteString;
  late String secondString;

  int hour = 0;
  int minute = 0;
  int second = 0;
  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    // GetStorage'ten verileri al
    final box = GetStorage();
    secondString = box.read('secondString') ?? '00';
    minuteString = box.read('minuteString') ?? '00';
    hourString = box.read('hourString') ?? '00';
  }

  void startTime() {
    isStart = true;
    update(); // Timer başlatıldığında, stateleri güncelle
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      startSecond();
    });
  }

  void pauseTime() {
    isStart = false;
    update(); // Timer durdurulduğunda, stateleri güncelle
    timer.cancel();
  }

  void startSecond() {
    if (second < 59) {
      second++;
      secondString = second.toString().padLeft(2, '0');
    } else {
      startMinute();
    }
    update(); // Saniye değiştiğinde, state'i güncelle
  }

  void startMinute() {
    if (minute < 59) {
      second = 0;
      secondString = '00';
      minute++;

      minuteString = minute.toString().padLeft(2, '0');
    } else {
      startHour();
    }
    update(); // Dakika değiştiğinde, state'i güncelle
  }

  void startHour() {
    minute = 0;
    second = 0;
    minuteString = '00';
    secondString = '00';
    hour++;

    hourString = hour.toString().padLeft(2, '0');
    update(); // Saat değiştiğinde, state'i güncelle
  }

  @override
  void onClose() {
    // TimerController kapatıldığında, GetStorage'a verileri kaydet
    final box = GetStorage();
    box.write('secondString', secondString);
    box.write('minuteString', minuteString);
    box.write('hourString', hourString);
    super.onClose();
  }
}

class TimerApp extends StatelessWidget {
  final TimerController _controller = Get.put(TimerController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Timer App'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                      '${_controller.hourString}:${_controller.minuteString}:${_controller.secondString}',
                      style: TextStyle(fontSize: 40),
                    )),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _controller.isStart
                      ? _controller.pauseTime
                      : _controller.startTime,
                  child: Text(_controller.isStart ? 'Pause' : 'Start'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondPage()),
                    );
                  },
                  child: Text('Go to Second Page'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Back'),
        ),
      ),
    );
  }
}

void main() async {
  await GetStorage.init();
  runApp(TimerApp());
}
