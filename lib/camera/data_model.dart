import 'dart:typed_data';

import 'package:ffi_zxing/ffi_zxing_bindings_generated.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

class ScanRequest {
  final int id;
  final Uint8List imageBytes;
  final int width;
  final int height;
  final int cropSize;

  ScanRequest(
      {required this.id,
      required this.imageBytes,
      required this.width,
      required this.height,
      required this.cropSize});
}

class ScanResponse {
  final int id;

  final CodeResult codeResult;

  ScanResponse({required this.id, required this.codeResult});
}

extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Char> allocatePointer() {
    final Pointer<Int8> blob = calloc<Int8>(length);
    final Int8List blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);

    return blob.cast<Char>();
  }
}

extension Code on CodeResult {
  String get textString => text.cast<Utf8>().toDartString();
}
