// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_common/firebase_auth_common.dart';

import 'method_channel_firebase_auth.dart';
import 'method_channel_multi_factor.dart';

/// Registers the `MethodChannel` implementations as the default platform
/// instances.
///
/// `firebase_auth_platform_interface` cannot register them itself, because the
/// platform interfaces have to stay usable without a Flutter dependency. This
/// is therefore called by `firebase_auth` before the first usage of the
/// Firebase Auth API, as well as by the test utilities of this package.
///
/// Instances which are already registered are left untouched, so that
/// implementations registering themselves, such as `firebase_auth_web` from
/// its `registerWith` method, keep precedence.
void registerMethodChannelInstances() {
  if (!FirebaseAuthPlatform.isRegistered) {
    FirebaseAuthPlatform.instance = MethodChannelFirebaseAuth.instance;
  }

  if (!PhoneMultiFactorGeneratorPlatform.isRegistered) {
    PhoneMultiFactorGeneratorPlatform.instance =
        MethodChannelPhoneMultiFactorGenerator();
  }

  if (!TotpMultiFactorGeneratorPlatform.isRegistered) {
    TotpMultiFactorGeneratorPlatform.instance =
        MethodChannelTotpMultiFactorGenerator();
  }
}
