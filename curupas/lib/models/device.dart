import 'package:cloud_firestore/cloud_firestore.dart';

class CurupaDevice {
  String device;
  String manufacturer;
  String brand;
  String hardware;
  String model;

  CurupaDevice();

  factory CurupaDevice.fromJson(Map<String, Object> doc) {
    CurupaDevice curupaDevice = new CurupaDevice();

    String device = doc["device"];
    String manufacturer = doc["manufacturer"];
    String brand = doc["brand"];
    String hardware = doc["hardware"];
    String model = doc["model"];

    curupaDevice.device = device;
    curupaDevice.manufacturer = manufacturer;
    curupaDevice.brand = brand;
    curupaDevice.hardware = hardware;
    curupaDevice.model = model;
    return curupaDevice;
  }

  factory CurupaDevice.fromDocument(DocumentSnapshot doc) {
    return CurupaDevice.fromJson(doc.data());
  }
}
