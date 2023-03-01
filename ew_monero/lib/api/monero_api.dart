import 'dart:ffi';
import 'dart:io';

final DynamicLibrary moneroApi = Platform.isAndroid
    ? DynamicLibrary.open("libew_monero.so")
    : DynamicLibrary.open("ew_monero.framework/ew_monero");