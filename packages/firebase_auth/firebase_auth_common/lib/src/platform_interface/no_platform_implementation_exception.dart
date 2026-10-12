// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_common/firebase_core_common.dart';

/// The exception thrown when a platform interface of this package is read
/// before an implementation has registered itself.
FirebaseException noPlatformImplementationException(String platformInterface) {
  return FirebaseException(
    plugin: 'firebase_auth',
    code: 'no-platform-implementation',
    message: 'No Firebase Auth implementation has been registered for '
        '`$platformInterface`.\n\nIf you are using Flutter, this usually means '
        'that the platform you are running on is not supported, or that the '
        'Firebase Auth API has not been used yet.\n\nIf you are not using '
        'Flutter, register your implementation manually, for example by '
        'calling `FirebaseAuthWeb.registerWith(null)` on web.',
  );
}
