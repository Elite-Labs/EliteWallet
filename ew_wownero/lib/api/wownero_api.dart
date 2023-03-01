import 'dart:ffi';
import 'dart:io';

final DynamicLibrary wowneroApi = Platform.isAndroid
    ? DynamicLibrary.open("libew_wownero.so")
    : DynamicLibrary.open("ew_wownero.framework/ew_wownero");