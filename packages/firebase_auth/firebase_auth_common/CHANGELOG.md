## 0.1.0

- Initial release.
- Pure Dart types and platform interfaces extracted from
  `firebase_auth_platform_interface`, so that Firebase Auth platform
  implementations can be consumed outside of Flutter.
- `FirebaseAuthPlatform.instance`, `PhoneMultiFactorGeneratorPlatform.instance`
  and `TotpMultiFactorGeneratorPlatform.instance` no longer default to their
  `MethodChannel` implementation: implementations must register themselves
  (`FirebaseAuthWeb` does so from `registerWith`, `firebase_auth` does so for
  Flutter) and `isRegistered` allows checking whether that happened.
