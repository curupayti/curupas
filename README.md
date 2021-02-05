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
flutter build ios --no-tree-shake-icons
```

Wifi Debugging
=========

```sh
adb tcpip 5555
adb connect 192.168.137.112
```
