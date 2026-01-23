class BleConsts {
  static const String namePrefix = 'BabyGuardian-';

  static const String svcUuid = "12345678-1234-1234-1234-1234567890ab";
  static const String infoUuid = "12345678-1234-1234-1234-1234567890ac"; // READ deviceId
  static const String configUuid = "12345678-1234-1234-1234-1234567890ad"; // WRITE ssid|pass
  static const String statusUuid = "12345678-1234-1234-1234-1234567890ae"; // NOTIFY status

  static const int stIdle = 0;
  static const int stReceived = 1;
  static const int stWifiConnecting = 2;
  static const int stWifiOk = 3;
  static const int stWifiFail = 4;
}
