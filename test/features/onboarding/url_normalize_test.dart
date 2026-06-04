import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/onboarding/onboarding_controller.dart';

void main() {
  test('defaults to https when no scheme is given', () {
    expect(normalizeServerUrl('komga.example.com').toString(),
        'https://komga.example.com');
  });

  test('keeps an explicit http scheme (LAN self-hosting)', () {
    expect(normalizeServerUrl('http://192.168.1.10:25600').toString(),
        'http://192.168.1.10:25600');
  });

  test('strips trailing slashes', () {
    expect(normalizeServerUrl('https://komga.example.com/').toString(),
        'https://komga.example.com');
  });

  test('strips a trailing /api/v1 the user may have pasted', () {
    expect(normalizeServerUrl('https://komga.example.com/api/v1').toString(),
        'https://komga.example.com');
  });

  test('preserves a reverse-proxy path prefix', () {
    expect(normalizeServerUrl('https://host.example.com/komga').toString(),
        'https://host.example.com/komga');
  });

  test('rejects empty and unusable input', () {
    expect(normalizeServerUrl(''), isNull);
    expect(normalizeServerUrl('   '), isNull);
    expect(normalizeServerUrl('ftp://host'), isNull);
  });
}
