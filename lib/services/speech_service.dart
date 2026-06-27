import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// On-device streaming speech-to-text via sherpa-onnx (a quantized streaming
/// Zipformer) fed by the device microphone.
///
/// Everything is demo-safe: if the mic permission is denied or the model fails
/// to load, [start] returns null and the Voice screen falls back to its
/// scripted transcript, so the demo never hard-stops.
class SpeechService {
  static const int _sampleRate = 16000;
  static const _assets = [
    'assets/models/asr/encoder.onnx',
    'assets/models/asr/decoder.onnx',
    'assets/models/asr/joiner.onnx',
    'assets/models/asr/tokens.txt',
  ];

  final _recorder = AudioRecorder();
  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;
  StreamSubscription<Uint8List>? _sub;
  bool _ready = false;

  bool get isReady => _ready;

  Future<bool> _ensureInit() async {
    if (_ready) return true;
    try {
      sherpa.initBindings();
      final enc = await _copyAsset(_assets[0]);
      final dec = await _copyAsset(_assets[1]);
      final joi = await _copyAsset(_assets[2]);
      final tok = await _copyAsset(_assets[3]);
      final config = sherpa.OnlineRecognizerConfig(
        feat: const sherpa.FeatureConfig(sampleRate: _sampleRate, featureDim: 80),
        model: sherpa.OnlineModelConfig(
          transducer: sherpa.OnlineTransducerModelConfig(
              encoder: enc, decoder: dec, joiner: joi),
          tokens: tok,
          numThreads: 2,
          debug: false,
        ),
        enableEndpoint: true,
      );
      _recognizer = sherpa.OnlineRecognizer(config);
      _stream = _recognizer!.createStream();
      _ready = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// sherpa needs real file paths, so bundle assets are copied to the app dir.
  Future<String> _copyAsset(String assetPath) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/${assetPath.split('/').last}');
    if (!await file.exists()) {
      final data = await rootBundle.load(assetPath);
      await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true);
    }
    return file.path;
  }

  /// Begins capture and emits a growing transcript. Returns null if it can't
  /// start (permission denied or model unavailable).
  Future<Stream<String>?> start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return null;
    if (!await _ensureInit()) return null;
    if (!await _recorder.hasPermission()) return null;

    final controller = StreamController<String>();
    var committed = '';

    final pcm = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
    ));

    _sub = pcm.listen((data) {
      final rec = _recognizer, st = _stream;
      if (rec == null || st == null) return;
      st.acceptWaveform(samples: _toFloat32(data), sampleRate: _sampleRate);
      while (rec.isReady(st)) {
        rec.decode(st);
      }
      final partial = rec.getResult(st).text;
      final display = '$committed $partial'.trim();
      if (display.isNotEmpty) controller.add(display);
      if (rec.isEndpoint(st)) {
        if (partial.isNotEmpty) committed = '$committed $partial'.trim();
        rec.reset(st);
      }
    }, onError: (_) {}, cancelOnError: false);

    return controller.stream;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    try {
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (_) {/* no plugin (e.g. in tests) */}
  }

  Future<void> dispose() async {
    await stop();
    _stream?.free();
    _recognizer?.free();
    try {
      await _recorder.dispose();
    } catch (_) {/* no plugin (e.g. in tests) */}
    _ready = false;
  }

  Float32List _toFloat32(Uint8List bytes) {
    final n = bytes.length ~/ 2;
    final out = Float32List(n);
    final bd = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length);
    for (var i = 0; i < n; i++) {
      out[i] = bd.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return out;
  }
}
