import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/source/models/page_dto.dart';
import 'package:mylarium/features/reader/online_page_source.dart';

void main() {
  OnlinePageSource source() => OnlinePageSource(
        api: KomgaApi(Dio()),
        sourceId: 's',
        bookId: 'b',
        pages: const [PageDto(number: 1, fileName: 'p1')],
        cacheWidth: 1000,
      );

  test('imageProviderAt overrides the decode width', () {
    final p = source().imageProviderAt(0, 4096) as OnlineImageProvider;
    expect(p.cacheWidth, 4096);
  });

  test('imageProvider uses the source default width', () {
    final p = source().imageProvider(0) as OnlineImageProvider;
    expect(p.cacheWidth, 1000);
  });

  test('imageProviderAt with null decodes at native (no width)', () {
    final p = source().imageProviderAt(0, null) as OnlineImageProvider;
    expect(p.cacheWidth, isNull);
  });

  test('providers at different widths are not cache-equal', () {
    final s = source();
    expect(s.imageProviderAt(0, 1000) == s.imageProviderAt(0, 4096), isFalse);
    expect(s.imageProviderAt(0, 4096) == s.imageProviderAt(0, 4096), isTrue);
  });
}
