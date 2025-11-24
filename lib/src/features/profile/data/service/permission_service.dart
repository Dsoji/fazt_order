import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling app permissions (camera, storage, notifications)
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request camera permission
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestCameraPermission({bool showDialog = true}) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isLimited) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied && showDialog) {
      await _showPermissionDeniedDialog('Camera');
    }

    return false;
  }

  /// Request storage permission
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestStoragePermission({bool showDialog = true}) async {
    // For Android 13+ (API 33+), use photos permission
    // For older Android versions, use storage permission

    // Try photos permission first (Android 13+)
    PermissionStatus photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) {
      return true;
    }

    if (photosStatus.isDenied || photosStatus.isLimited) {
      final result = await Permission.photos.request();
      if (result.isGranted) {
        return true;
      }
    }

    // Try storage permission (older Android versions)
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return true;
    }

    if (storageStatus.isDenied) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      }
    }

    // Handle permanently denied for either permission
    if ((photosStatus.isPermanentlyDenied ||
            storageStatus.isPermanentlyDenied) &&
        showDialog) {
      await _showPermissionDeniedDialog('Storage');
    }

    return false;
  }

  /// Request notification permission
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestNotificationPermission({bool showDialog = true}) async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied && showDialog) {
      await _showPermissionDeniedDialog('Notifications');
    }

    return false;
  }

  /// Request all permissions (camera, storage, notification)
  /// Returns a map with permission status
  Future<Map<String, bool>> requestAllPermissions(
      {bool showDialog = true}) async {
    return {
      'camera': await requestCameraPermission(showDialog: showDialog),
      'storage': await requestStoragePermission(showDialog: showDialog),
      'notification':
          await requestNotificationPermission(showDialog: showDialog),
    };
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    return (await Permission.camera.status).isGranted;
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    // Check photos permission first
    if ((await Permission.photos.status).isGranted) {
      return true;
    }
    // Check storage permission
    return (await Permission.storage.status).isGranted;
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    return (await Permission.notification.status).isGranted;
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Show dialog when permission is permanently denied
  Future<void> _showPermissionDeniedDialog(String permissionName) async {
    // This requires a BuildContext, so we'll need to handle it in the UI layer
    debugPrint('$permissionName permission is permanently denied');
  }

  /// Show permission dialog with custom message
  /// This method should be called from a context where you have access to BuildContext
  static Future<void> showPermissionDeniedDialog(
    BuildContext context,
    String permissionName,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          '$permissionName permission is required to use this feature. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Request permission with dialog support
  Future<bool> requestPermissionWithDialog(
    BuildContext context,
    String permissionName,
    Permission permission,
  ) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      if (result.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied || await permission.isPermanentlyDenied) {
      await showPermissionDeniedDialog(context, permissionName);
    }

    return false;
  }
}
