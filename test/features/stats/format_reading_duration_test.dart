import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/stats/stats_models.dart';

void main() {
  test('under a minute reads "<1 min", never a zero-hours decimal', () {
    expect(formatReadingDuration(Duration.zero), '<1 min');
    expect(formatReadingDuration(const Duration(seconds: 30)), '<1 min');
    expect(formatReadingDuration(const Duration(seconds: 59)), '<1 min');
  });

  test('under an hour reads whole minutes', () {
    expect(formatReadingDuration(const Duration(minutes: 1)), '1 min');
    expect(formatReadingDuration(const Duration(minutes: 24)), '24 min');
    expect(formatReadingDuration(const Duration(minutes: 59)), '59 min');
    // Partial minutes truncate (59m59s is still under the hour).
    expect(
      formatReadingDuration(const Duration(minutes: 59, seconds: 59)),
      '59 min',
    );
  });

  test('from an hour up reads one-decimal hours', () {
    expect(formatReadingDuration(const Duration(minutes: 60)), '1.0 h');
    expect(formatReadingDuration(const Duration(minutes: 90)), '1.5 h');
    expect(formatReadingDuration(const Duration(hours: 10)), '10.0 h');
  });
}
