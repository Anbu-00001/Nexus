import 'package:flutter_test/flutter_test.dart';
import 'package:nexus/services/api_client.dart';

void main() {
  test('QueryResult.fromJson maps the /query payload', () {
    final j = {
      'title': 'Root cause: valve-induced cavitation',
      'answer': 'Valve V-22 held a partial-closed position...',
      'confidence': 0.81,
      'prediction': {
        'asset': 'Pump P-101',
        'probability': 0.74,
        'window': 'next 3–5 weeks',
        'driver': 'same V-22 → cavitation signature re-emerging since 02 Jun.',
      },
    };
    final r = QueryResult.fromJson(j);
    expect(r.title, contains('cavitation'));
    expect(r.confidence, 0.81);
    expect(r.prediction.probability, 0.74);
    expect(r.prediction.asset, 'Pump P-101');
    expect(r.prediction.window, 'next 3–5 weeks');
    expect(r.live, isTrue);
  });

  test('integer probability is coerced to double', () {
    final j = {
      'title': 't',
      'answer': 'a',
      'prediction': {
        'asset': 'P-101',
        'probability': 1, // int from JSON
        'window': 'w',
        'driver': 'd',
      },
    };
    final r = QueryResult.fromJson(j);
    expect(r.prediction.probability, 1.0);
    expect(r.confidence, 0.0); // missing → default
  });
}
