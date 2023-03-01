import 'dart:ffi';
import 'dart:io';

final DynamicLibrary havenApi = Platform.isAndroid
    ? DynamicLibrary.open("libew_haven.so")
    : DynamicLibrary.open("ew_haven.framework/ew_haven");