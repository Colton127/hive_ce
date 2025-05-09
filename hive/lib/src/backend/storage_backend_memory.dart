import 'dart:typed_data';

import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/backend/storage_backend.dart';
import 'package:hive_ce/src/binary/frame.dart';
import 'package:hive_ce/src/binary/frame_helper.dart';
import 'package:hive_ce/src/box/keystore.dart';

/// In-memory Storage backend
class StorageBackendMemory extends StorageBackend {
  final HiveCipher? _cipher;

  final FrameHelper _frameHelper;

  Uint8List? _bytes;

  /// Not part of public API
  StorageBackendMemory(Uint8List? bytes, this._cipher)
      : _bytes = bytes,
        _frameHelper = FrameHelper();

  @override
  String? get path => null;

  @override
  var supportsCompaction = false;

  @override
  Future<void> initialize(
    TypeRegistry registry,
    Keystore? keystore,
    bool lazy, {
    bool isolated = false,
  }) {
    final recoveryOffset = _frameHelper.framesFromBytes(
      _bytes!, // Initialized at constructor and nulled after initialization
      keystore,
      registry,
      _cipher,
    );

    if (recoveryOffset != -1) {
      throw HiveError('Wrong checksum in bytes. Box may be corrupted.');
    }

    _bytes = null;

    return Future.value();
  }

  @override
  Future<dynamic> readValue(Frame frame, {bool verbatim = false}) {
    throw UnsupportedError('This operation is unsupported for memory boxes.');
  }

  @override
  Future<void> writeFrames(List<Frame> frames, {bool verbatim = false}) =>
      Future.value();

  @override
  Future<List<Frame>> compact(Iterable<Frame> frames) {
    throw UnsupportedError('This operation is unsupported for memory boxes.');
  }

  @override
  Future<void> clear() => Future.value();

  @override
  Future<void> close() => Future.value();

  @override
  Future<void> deleteFromDisk() {
    throw UnsupportedError('This operation is unsupported for memory boxes.');
  }

  @override
  Future<void> flush() => Future.value();
}
