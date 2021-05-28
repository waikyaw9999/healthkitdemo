import 'package:flutter/material.dart';
import 'dart:async';
import 'package:health_kit/health_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var total = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Health Kit'),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                child: Text("Get Yesterday's Step count"),
                onPressed: () async {
                  getYesterdayStep();
                },
              ),
              Text(total.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> readPermissionsForHealthKit() async {
    try {
      final responses = await HealthKit.hasPermissions([DataType.STEP_COUNT]);

      if (!responses) {
        final value = await HealthKit.requestPermissions([DataType.STEP_COUNT]);

        return value;
      } else {
        return true;
      }
    } on UnsupportedException catch (e) {
      // thrown in case e.dataType is unsupported
      print(e);
      return false;
    }
  }

  void getYesterdayStep() async {
    var permissionsGiven = await readPermissionsForHealthKit();

    if (permissionsGiven) {
      var current = DateTime.now();

      var dateFrom = DateTime.now().subtract(Duration(
        hours: current.hour + 24,
        minutes: current.minute,
        seconds: current.second,
      ));
      var dateTo = dateFrom.add(Duration(
        hours: 23,
        minutes: 59,
        seconds: 59,
      ));

      print('dateFrom: $dateFrom');
      print('dateTo: $dateTo');

      try {
        var results = await HealthKit.read(
          DataType.STEP_COUNT,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
        if (results != null) {
          for (var result in results) {
            total += result.value;
          }
        }
        setState(() {});
        print('value: $total');
      } on Exception catch (ex) {
        print('Exception in getYesterdayStep: $ex');
      }
    }
  }
}