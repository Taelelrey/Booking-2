import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/service.dart';

class Queues with ChangeNotifier {
  FirebaseDatabase database = FirebaseDatabase.instance;
  final Map<String, Map<String, int>> userServices = {};
  Map<String, int> serviceValueList = {};
  String authErrorResponse = "";

  void joinQueue(int serviceTime, int totalTime, List<String> services) {
    final databaseReference = database.ref().child("/users_services");

    databaseReference.push().set(
      {
        FirebaseAuth.instance.currentUser!.uid: {
          "username": FirebaseAuth.instance.currentUser!.displayName,
          "services": services,
          "travel_time": serviceTime,
          "service_time": totalTime,
          "total_Service_time": serviceTime + totalTime,
          "dateCreated": DateTime.now().toIso8601String(),
        },
      },
    );
    notifyListeners();
  }

  retrieveUserDetails() async {
    // Reference to the database
    final userServicesRef = database.ref().child("/users_services");

    //Retrieve data through a DatabaseEvent
    final userServ = await userServicesRef.once();

    //Get the data values from the Database Event and cast as a Map
    final retUserServ = userServ.snapshot.value as Map;

    // Create another map from the previous map.
    //This allows us to add integer keys for easy searching
    int i = 0;
    final fUserServ = {
      for (var element in retUserServ.values) i++: element as Map
    };

    // Extract the needed values from the map
    for (int i = 0; i < fUserServ.length; i++) {
      final el = fUserServ[i]!;
      // log(el.keys.first.toString());
      for (int j = 0; j < el.length; j++) {
        final ml = el.values.toList().toList();
        final vl = ml.first;
        userServices.putIfAbsent(
            vl['dateCreated'], () => {vl['username']: vl['service_time']});
      }
    }
    // log(userServices.toString());
    notifyListeners();
    return userServices;
  }

  postServices(List<Service> serviceList) {
    final databaseReference = database.ref().child("/admin_services");

    databaseReference.child("my_services").set(
      {
        "Oil_Change": {
          "service_name": serviceList[0].name,
          "mins": serviceList[0].hrs * 60 + serviceList[0].mins
        },
        "Tires": {
          "service_name": serviceList[1].name,
          "mins": serviceList[1].hrs * 60 + serviceList[1].mins
        },
        "Service": {
          "service_name": serviceList[2].name,
          "mins": serviceList[2].hrs * 60 + serviceList[2].mins
        },
        "Paint": {
          "service_name": serviceList[3].name,
          "mins": serviceList[3].hrs * 60 + serviceList[3].mins
        },
      },
    );
    notifyListeners();
  }

  fetchServiceValues() async {
    final databaseReference = database.ref().child("/admin_services");
    final prevDb = await databaseReference.once();
    final retPrevDb = prevDb.snapshot.value as Map;
    final fPrevDb = retPrevDb.values.first as Map;
    serviceValueList.clear();
    for (int i = 0; i < fPrevDb.values.length; i++) {
      final xs = fPrevDb.values.elementAt(i) as Map;
      log(xs.values.elementAt(0).toString());
      for (int j = 0; j < xs.length; j++) {
        serviceValueList.putIfAbsent(
            xs.values.elementAt(1), () => xs.values.elementAt(0));
      }
    }
    notifyListeners();
  }
}
