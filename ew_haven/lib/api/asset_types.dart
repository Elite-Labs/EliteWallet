import 'dart:ffi';
import 'package:ew_haven/api/convert_utf8_to_string.dart';
import 'package:ew_haven/api/signatures.dart';
import 'package:ew_haven/api/types.dart';
import 'package:ew_haven/api/haven_api.dart';
import 'package:ffi/ffi.dart';

final assetTypesSizeNative = havenApi
    .lookup<NativeFunction<account_size>>('asset_types_size')
    .asFunction<SubaddressSize>();

final getAssetTypesNative = havenApi
    .lookup<NativeFunction<asset_types>>('asset_types')
    .asFunction<AssetTypes>();

List<String> getAssetTypes() {
  List<String> assetTypes = <String>[];
  Pointer<Pointer<Utf8>> assetTypePointers = getAssetTypesNative();
  Pointer<Utf8> assetpointer = assetTypePointers.elementAt(0)[0];
  String asset = convertUTF8ToString(pointer: assetpointer);

  return assetTypes;
}
