import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class AppImageCache {
  AppImageCache._();

  static final AppImageCache instance = AppImageCache._();

  static const int _maxMemoryEntries = 32;
  static const int _maxDiskEntries = 128;

  final LinkedHashMap<String, Uint8List> _memoryCache = LinkedHashMap<String, Uint8List>();
  Directory? _cacheDir;
  bool _pruneRunning = false;

  Future<Uint8List?> getBytes(String url) async {
    final String normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) {
      return null;
    }

    final Uint8List? memoryBytes = _memoryCache[normalizedUrl];
    if (memoryBytes != null) {
      _touchMemory(normalizedUrl, memoryBytes);
      return memoryBytes;
    }

    final File cacheFile = await _getCacheFile(normalizedUrl);
    if (await cacheFile.exists()) {
      try {
        final Uint8List bytes = await cacheFile.readAsBytes();
        _rememberMemory(normalizedUrl, bytes);
        return bytes;
      } catch (e) {
        debugPrint('AppImageCache read cache failed: $e');
      }
    }

    HttpClient? client;
    try {
      client = HttpClient();
      client.autoUncompress = true;
      final HttpClientRequest request = await client.getUrl(Uri.parse(normalizedUrl));
      request.followRedirects = true;
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await cacheFile.writeAsBytes(bytes, flush: true);
      _rememberMemory(normalizedUrl, bytes);
      unawaited(_pruneDiskCache());
      return bytes;
    } catch (e) {
      debugPrint('AppImageCache download failed: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  void clearMemoryCache() {
    _memoryCache.clear();
  }

  Future<void> clearDiskCache() async {
    final Directory? dir = _cacheDir;
    if (dir == null || !await dir.exists()) {
      return;
    }
    try {
      final List<FileSystemEntity> entities = await dir.list().toList();
      for (final FileSystemEntity entity in entities) {
        if (entity is File) {
          await entity.delete().catchError((_) {});
        }
      }
    } catch (e) {
      debugPrint('AppImageCache clear disk failed: $e');
    }
  }

  Future<void> prefetch(String url) async {
    await getBytes(url);
  }

  Future<File> _getCacheFile(String url) async {
    final Directory dir = await _ensureCacheDir();
    final String fileName = sha1.convert(utf8.encode(url)).toString();
    return File('${dir.path}${Platform.pathSeparator}$fileName.img');
  }

  Future<Directory> _ensureCacheDir() async {
    final Directory? current = _cacheDir;
    if (current != null) {
      return current;
    }
    final Directory dir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}go_api_image_cache',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    unawaited(_pruneDiskCache());
    return dir;
  }

  void _rememberMemory(String key, Uint8List bytes) {
    _memoryCache.remove(key);
    _memoryCache[key] = bytes;
    while (_memoryCache.length > _maxMemoryEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
  }

  void _touchMemory(String key, Uint8List bytes) {
    _memoryCache.remove(key);
    _memoryCache[key] = bytes;
  }

  Future<void> _pruneDiskCache() async {
    if (_pruneRunning) {
      return;
    }
    _pruneRunning = true;
    try {
      final Directory dir = await _ensureCacheDir();
      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<File> files = entities.whereType<File>().toList();
      if (files.length <= _maxDiskEntries) {
        return;
      }
      files.sort((left, right) {
        final DateTime leftTime = left.lastModifiedSync();
        final DateTime rightTime = right.lastModifiedSync();
        return leftTime.compareTo(rightTime);
      });
      final int removeCount = files.length - _maxDiskEntries;
      for (int i = 0; i < removeCount; i++) {
        await files[i].delete().catchError((_) {});
      }
    } catch (e) {
      debugPrint('AppImageCache prune failed: $e');
    } finally {
      _pruneRunning = false;
    }
  }
}
