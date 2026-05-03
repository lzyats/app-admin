# 保留 Flutter 与常见反射类，避免发布包混淆后异常
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
