// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The platform interface for Firebase Auth.
///
/// The types of this platform interface do not depend on Flutter anymore and
/// live in `firebase_auth_common`, so that platform implementations can be
/// used outside of Flutter. They are re-exported here to keep this package the
/// single entry point for Flutter users. Only the `MethodChannel` based
/// implementation and the generated messages remain in this package, and
/// [registerMethodChannelInstances] exposes registering them.
library;

export 'package:firebase_auth_common/firebase_auth_common.dart';

export 'src/method_channel/default_instances.dart'
    show registerMethodChannelInstances;
