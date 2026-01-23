class BindDeviceRequest {
  final String deviceId; // "esp32-..."

  BindDeviceRequest({required this.deviceId});

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
      };
}
