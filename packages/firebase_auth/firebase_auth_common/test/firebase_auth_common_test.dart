// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_common/firebase_auth_common.dart';
import 'package:firebase_core_common/firebase_core_common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseAuthPlatform', () {
    test('is not registered by default', () {
      expect(FirebaseAuthPlatform.isRegistered, isFalse);
      expect(PhoneMultiFactorGeneratorPlatform.isRegistered, isFalse);
      expect(TotpMultiFactorGeneratorPlatform.isRegistered, isFalse);
    });

    test('throws until an implementation is registered', () {
      expect(
        () => FirebaseAuthPlatform.instance,
        throwsA(
          isA<FirebaseException>().having(
            (error) => error.code,
            'code',
            'no-platform-implementation',
          ),
        ),
      );
      expect(
        () => PhoneMultiFactorGeneratorPlatform.instance,
        throwsA(isA<FirebaseException>()),
      );
      expect(
        () => TotpMultiFactorGeneratorPlatform.instance,
        throwsA(isA<FirebaseException>()),
      );
    });

    test('can be set to a platform implementation', () {
      FirebaseAuthPlatform.instance = _TestFirebaseAuthPlatform();

      expect(FirebaseAuthPlatform.isRegistered, isTrue);
      expect(FirebaseAuthPlatform.instance, isA<_TestFirebaseAuthPlatform>());
    });
  });

  group('$FirebaseAuthException', () {
    test('exposes its code and message', () {
      final exception = _TestFirebaseAuthException(code: 'no-app');

      expect(exception.code, 'no-app');
      expect(exception.plugin, 'firebase_auth');
    });
  });
}

class _TestFirebaseAuthPlatform extends FirebaseAuthPlatform {}

class _TestFirebaseAuthException extends FirebaseAuthException {
  _TestFirebaseAuthException({required super.code});
}
