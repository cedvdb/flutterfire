# firebase_auth_common

Pure Dart shared types and platform interfaces used by
[`firebase_auth`](https://pub.dev/packages/firebase_auth) and its platform
implementations.

This package contains no Flutter dependency and never imports `package:flutter/*`
(neither directly nor transitively). It exists so that platform implementations
such as [`firebase_auth_web`](https://pub.dev/packages/firebase_auth_web) can be
used outside of Flutter, for example in pure Dart web applications.

It is not intended to be used directly by end users. The Flutter facing API is
exposed by `firebase_auth`, and `firebase_auth_platform_interface` re-exports
this package for backwards compatibility.
