import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Please authenticate to access your wallet'}) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    }
  }
}
