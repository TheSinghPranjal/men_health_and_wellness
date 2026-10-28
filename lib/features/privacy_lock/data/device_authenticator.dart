import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/logging/app_logger.dart';

abstract interface class DeviceAuthenticator {
  /// True when the device has biometrics or a passcode the app can use.
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

/// Uses the platform's biometric or device-passcode prompt. The app never
/// sees or stores biometric data or the passcode itself.
class LocalDeviceAuthenticator implements DeviceAuthenticator {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e, s) {
      AppLogger.error('lock.support_check_failed', e, s);
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } on PlatformException catch (e, s) {
      AppLogger.error('lock.authenticate_failed', e, s);
      return false;
    } on LocalAuthException catch (e, s) {
      AppLogger.error('lock.authenticate_failed', e, s);
      return false;
    }
  }
}

final deviceAuthenticatorProvider = Provider<DeviceAuthenticator>((ref) => LocalDeviceAuthenticator());
