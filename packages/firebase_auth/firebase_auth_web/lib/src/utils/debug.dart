// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Whether the application is running in debug mode.
///
/// Equivalent of `kDebugMode` of `package:flutter/foundation.dart`, which
/// cannot be imported here as this package has to keep working without a
/// Flutter dependency.
// ignore: do_not_use_environment
const bool _kReleaseMode = bool.fromEnvironment('dart.vm.product');

// ignore: do_not_use_environment
const bool _kProfileMode = bool.fromEnvironment('dart.vm.profile');

const bool kDebugMode = !_kReleaseMode && !_kProfileMode;
