import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Result of a live causal query from the NEXUS backend.
class QueryResult {
  final String title;
  final String answer;
  final Prediction prediction;
  final double confidence;
  final bool live;

  const QueryResult({
    required this.title,
    required this.answer,
    required this.prediction,
    required this.confidence,
    this.live = true,
  });

  /// Parse the `/query` JSON shape. Kept pure + static so it is unit-testable
  /// without a running server.
  factory QueryResult.fromJson(Map<String, dynamic> j) {
    final p = (j['prediction'] as Map).cast<String, dynamic>();
    return QueryResult(
      title: j['title'] as String,
      answer: j['answer'] as String,
      confidence: (j['confidence'] as num?)?.toDouble() ?? 0.0,
      prediction: Prediction(
        asset: p['asset'] as String,
        probability: (p['probability'] as num).toDouble(),
        window: p['window'] as String,
        driver: p['driver'] as String,
      ),
    );
  }
}

/// Thin client for the NEXUS FastAPI backend.
///
/// Every call is demo-safe: on any failure (server down, timeout, bad payload)
/// it returns `null`/`false` and the UI falls back to its bundled demo data, so
/// a live demo never breaks if the backend isn't running.
class ApiClient {
  /// Override at build time: `--dart-define=NEXUS_API=http://192.168.x.x:8077`
  /// (use the host's LAN IP when running on a physical phone).
  static const base = String.fromEnvironment(
    'NEXUS_API',
    defaultValue: 'http://127.0.0.1:8077',
  );

  final Duration timeout;
  const ApiClient({this.timeout = const Duration(seconds: 15)});

  Future<bool> health() async {
    try {
      final r = await http.get(Uri.parse('$base/health')).timeout(timeout);
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<QueryResult?> query(String question) async {
    try {
      final r = await http
          .post(Uri.parse('$base/query'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'question': question}))
          .timeout(timeout);
      if (r.statusCode != 200) return null;
      return QueryResult.fromJson(
          jsonDecode(r.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Vision-native P&ID Q&A. Sends the rendered drawing + question; returns the
  /// model's located-component answer, or null on any failure.
  Future<String?> visionPid(String question, Uint8List image) async {
    try {
      final req = http.MultipartRequest('POST', Uri.parse('$base/vision/pid'))
        ..fields['question'] = question
        ..files.add(http.MultipartFile.fromBytes('image', image,
            filename: 'pid.png'));
      final streamed = await req.send().timeout(timeout);
      if (streamed.statusCode != 200) return null;
      final j = jsonDecode(await streamed.stream.bytesToString())
          as Map<String, dynamic>;
      return (j['ok'] == true) ? j['answer'] as String : null;
    } catch (_) {
      return null;
    }
  }
}
