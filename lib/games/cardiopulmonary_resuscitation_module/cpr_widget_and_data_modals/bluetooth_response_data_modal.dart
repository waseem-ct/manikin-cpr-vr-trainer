class BluetoothResponseDataModal {
  int cprValue; // CPR compression value
  int leftCompression; // Incorrect compression left
  int rightCompression; // Incorrect compression right
  double airBlowValue; // Air blow value

  BluetoothResponseDataModal({required this.cprValue, required this.leftCompression, required this.rightCompression, required this.airBlowValue});
  // Add a [] operator
  dynamic operator [](String key) {
    switch (key) {
      case 'leftCompression':
        return leftCompression;
      case 'rightCompression':
        return rightCompression;
      case 'cprValue':
        return cprValue;
      default:
        throw ArgumentError('Invalid key: $key');
    }
  }
}
