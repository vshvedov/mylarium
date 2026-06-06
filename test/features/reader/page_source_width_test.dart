import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/komga/models/page_dto.dart';
import 'package:mylarium/features/reader/komga_page_source.dart';

void main() {
  KomgaPageSource source() => KomgaPageSource(
        api: KomgaApi(Dio()),
        sourceId: 's',
        bookId: 'b',
        pages: const [PageDto(number: 1, fileName: 'p1')],
        cacheWidth: 1000,
      );

  test('imageProviderAt overrides the decode width', () {
    final p = source().imageProviderAt(0, 4096) as KomgaPageImageProvider;
    expect(p.cacheWidth, 4096);
  });

  test('imageProvider uses the source default width', () {
    final p = source().imageProvider(0) as KomgaPageImageProvider;
    expect(p.cacheWidth, 1000);
  });

  test('imageProviderAt with null decodes at native (no width)', () {
    final p = source().imageProviderAt(0, null) as KomgaPageImageProvider;
    expect(p.cacheWidth, isNull);
  });

  test('providers at different widths are not cache-equal', () {
    final s = source();
    expect(s.imageProviderAt(0, 1000) == s.imageProviderAt(0, 4096), isFalse);
    expect(s.imageProviderAt(0, 4096) == s.imageProviderAt(0, 4096), isTrue);
  });
}
