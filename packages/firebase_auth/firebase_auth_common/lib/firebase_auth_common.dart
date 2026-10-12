// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Pure Dart types and platform interfaces for Firebase Auth.
///
/// This library must never import `package:flutter/*` or any library which
/// does, so that Firebase Auth platform implementations (such as
/// `firebase_auth_web`) can be used outside of Flutter, for example in
/// pure Dart web applications.
///
/// `firebase_auth_platform_interface` re-exports this library, so importing
/// that package (directly or through `firebase_auth`) keeps giving access to
/// exactly the same types.
library;

export 'src/action_code_info.dart';
export 'src/action_code_settings.dart';
export 'src/additional_user_info.dart';
export 'src/auth_credential.dart';
export 'src/auth_provider.dart';
export 'src/auth_settings.dart';
export 'src/firebase_auth_exception.dart';
export 'src/firebase_auth_multi_factor_exception.dart';
export 'src/id_token_result.dart';
export 'src/password_policy/password_policy.dart';
export 'src/password_policy/password_policy_api.dart';
export 'src/password_policy/password_policy_impl.dart';
export 'src/password_policy/password_validation_status.dart';
export 'src/pigeon/messages.dart'
    show
        InternalUserDetails,
        InternalUserInfo,
        ActionCodeInfoOperation,
        InternalIdTokenResult;
export 'src/platform_interface/platform_interface_confirmation_result.dart';
export 'src/platform_interface/platform_interface_firebase_auth.dart';
export 'src/platform_interface/platform_interface_multi_factor.dart';
export 'src/platform_interface/platform_interface_recaptcha_verifier_factory.dart';
export 'src/platform_interface/platform_interface_user.dart';
export 'src/platform_interface/platform_interface_user_credential.dart';
export 'src/providers/apple_auth.dart';
export 'src/providers/email_auth.dart';
export 'src/providers/facebook_auth.dart';
export 'src/providers/game_center_auth.dart';
export 'src/providers/github_auth.dart';
export 'src/providers/google_auth.dart';
export 'src/providers/microsoft_auth.dart';
export 'src/providers/oauth.dart';
export 'src/providers/phone_auth.dart';
export 'src/providers/play_games_auth.dart';
export 'src/providers/saml_auth.dart';
export 'src/providers/twitter_auth.dart';
export 'src/providers/yahoo_auth.dart';
export 'src/types.dart';
export 'src/user_info.dart';
export 'src/user_metadata.dart';
