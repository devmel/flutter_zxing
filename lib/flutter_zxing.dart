import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'generated_bindings.dart';

class FlutterZxing {
  static const MethodChannel _channel = MethodChannel('flutter_zxing');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static final bindings = GeneratedBindings(dylib);

  static String zxingVersion() {
    return bindings.zxingVersion().cast<Utf8>().toDartString();
  }

  static CodeResult zxingRead(
      Uint8List bytes, int width, int height, int cropSize) {
    return bindings.zxingRead(bytes.allocatePointer(), width, height, cropSize);
  }

  static EncodeResult zxingEncode(String contents, int width, int height,
      int format, int margin, int eccLevel) {
    var result = bindings.zxingEncode(contents.toNativeUtf8().cast<Int8>(),
        width, height, format, margin, eccLevel);
    return result;
  }
}

// Getting a library that holds needed symbols
DynamicLibrary _openDynamicLibrary() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libflutter_zxing.so');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open("flutter_zxing_windows_plugin.dll");
  }
  return DynamicLibrary.process();
}

DynamicLibrary dylib = _openDynamicLibrary();

extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Int8> allocatePointer() {
    final blob = calloc<Int8>(length);
    final blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob;
  }
}

extension Encode on EncodeResult {
  bool get isValidBool => isValid == 1;
  Uint32List get bytes => data.asTypedList(length);
  String get errorMessage => error.cast<Utf8>().toDartString();
}

extension Code on CodeResult {
  bool get isValidBool => isValid == 1;
  String get textString => text.cast<Utf8>().toDartString();

  String get formatString {
    return CodeFormat.formatName(format);
  }
}

extension CodeFormat on Format {
  static String formatName(int format) => formatNames[format] ?? 'Unknown';
  String get name => formatNames[this] ?? 'Unknown';

  static final formatNames = {
    Format.None: 'None',
    Format.Aztec: 'Aztec',
    Format.Codabar: 'CodaBar',
    Format.Code39: 'Code39',
    Format.Code93: 'Code93',
    Format.Code128: 'Code128',
    Format.DataBar: 'DataBar',
    Format.DataBarExpanded: 'DataBarExpanded',
    Format.DataMatrix: 'DataMatrix',
    Format.EAN8: 'EAN8',
    Format.EAN13: 'EAN13',
    Format.ITF: 'ITF',
    Format.MaxiCode: 'MaxiCode',
    Format.PDF417: 'PDF417',
    Format.QRCode: 'QR Code',
    Format.UPCA: 'UPCA',
    Format.UPCE: 'UPCE',
    Format.OneDCodes: 'OneD',
    Format.TwoDCodes: 'TwoD',
    Format.Any: 'Any',
  };

  static final writerFormats = [
    Format.QRCode,
    Format.DataMatrix,
    Format.Aztec,
    Format.PDF417,
    Format.Codabar,
    Format.Code39,
    Format.Code93,
    Format.Code128,
    Format.EAN8,
    Format.EAN13,
    Format.ITF,
    Format.UPCA,
    Format.UPCE,
    // Format.DataBar,
    // Format.DataBarExpanded,
    // Format.MaxiCode,
  ];
}
