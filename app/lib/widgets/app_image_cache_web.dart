class AppImageCache {
  AppImageCache._();

  static final AppImageCache instance = AppImageCache._();

  Future<void> prefetch(String url) async {}

  void clearMemoryCache() {}

  Future<void> clearDiskCache() async {}
}
