Building
========

iOS
---


```sh
flutter doctor
```

Si arroja problemas resolverlos, actualizar cocoapods siempre.

```sh
flutter clean
cd ios
pod install
pod update
flutter build ios --release
```
