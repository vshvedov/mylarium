import 'dart:typed_data';

/// Archive container formats Mylarium can read. Extension filters are UX-only;
/// the real format is decided by these magic bytes (CLAUDE.md imports rule).
enum ArchiveFormat { zip, rar, unknown }

/// Sniffs the container format from the leading bytes of an archive.
///
/// ZIP (CBZ): `PK\x03\x04` (local file header), or the empty/spanned variants
/// `PK\x05\x06` / `PK\x07\x08`. RAR (CBR): `Rar!\x1a\x07` (RAR4 and RAR5 share
/// this 7-byte signature prefix).
ArchiveFormat sniffArchiveFormat(Uint8List head) {
  if (_startsWith(head, const [0x50, 0x4B, 0x03, 0x04]) ||
      _startsWith(head, const [0x50, 0x4B, 0x05, 0x06]) ||
      _startsWith(head, const [0x50, 0x4B, 0x07, 0x08])) {
    return ArchiveFormat.zip;
  }
  if (_startsWith(head, const [0x52, 0x61, 0x72, 0x21, 0x1A, 0x07])) {
    return ArchiveFormat.rar;
  }
  return ArchiveFormat.unknown;
}

bool _startsWith(Uint8List data, List<int> sig) {
  if (data.length < sig.length) return false;
  for (var i = 0; i < sig.length; i++) {
    if (data[i] != sig[i]) return false;
  }
  return true;
}

const _imageExtensions = {
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'avif',
  'bmp',
};

/// Whether [entryName] is a page image (by extension), excluding directories,
/// macOS resource forks, and dotfiles.
bool isImageEntry(String entryName) {
  if (entryName.endsWith('/')) return false;
  final base = entryName.split('/').last;
  if (base.isEmpty || base.startsWith('.')) return false;
  if (entryName.startsWith('__MACOSX/')) return false;
  final dot = base.lastIndexOf('.');
  if (dot < 0) return false;
  return _imageExtensions.contains(base.substring(dot + 1).toLowerCase());
}
