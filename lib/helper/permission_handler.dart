import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionType { success, denied, permanentlyDenied }

class Utils {
  Utils._();

  static final I = Utils._();

  Future<PermissionType> requestPermissionCamera() async {
    Permission permission = Permission.camera;

    if (Platform.isIOS) return PermissionType.success;

    final status = await permission.request();

    if (status == PermissionStatus.granted) {
      return PermissionType.success;
    }

    if (status == PermissionStatus.denied) {
      return PermissionType.denied;
    }

    return PermissionType.permanentlyDenied;
  }

  Future<PermissionType> requestPermissionStorage() async {
    Permission permissionStorage = Permission.storage;

    if (Platform.isIOS) {
      permissionStorage = Permission.storage;
    } else if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();

      final info = await deviceInfo.androidInfo;

      final osVersion = info.version.sdkInt;

      if (osVersion >= 33) {
        permissionStorage = Permission.photos;
      } else {
        permissionStorage = Permission.storage;
      }
    }

    final status = await permissionStorage.request();

    if (status == PermissionStatus.granted) {
      return PermissionType.success;
    }

    if (status == PermissionStatus.denied) {
      return PermissionType.denied;
    }

    return PermissionType.permanentlyDenied;
  }
}
