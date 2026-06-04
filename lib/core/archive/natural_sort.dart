/// Natural ("alphanum") comparison so page entries like `page2.jpg` sort before
/// `page10.jpg`. Case-insensitive; splits each string into alternating non-digit
/// and digit runs, comparing digit runs numerically (leading zeros ignored, then
/// run length as a tie-break) and text runs by lowercased code units. Stable and
/// locale-independent.
int naturalCompare(String a, String b) {
  final sa = a.toLowerCase();
  final sb = b.toLowerCase();
  var i = 0, j = 0;
  while (i < sa.length && j < sb.length) {
    final ca = sa.codeUnitAt(i);
    final cb = sb.codeUnitAt(j);
    final da = _isDigit(ca);
    final db = _isDigit(cb);

    if (da && db) {
      // Compare two digit runs numerically.
      final startA = i, startB = j;
      while (i < sa.length && _isDigit(sa.codeUnitAt(i))) {
        i++;
      }
      while (j < sb.length && _isDigit(sb.codeUnitAt(j))) {
        j++;
      }
      final runA = _stripLeadingZeros(sa.substring(startA, i));
      final runB = _stripLeadingZeros(sb.substring(startB, j));
      if (runA.length != runB.length) return runA.length - runB.length;
      final cmp = runA.compareTo(runB);
      if (cmp != 0) return cmp;
      // Equal numeric value: more leading zeros sorts first (stable).
      final zerosA = (i - startA) - runA.length;
      final zerosB = (j - startB) - runB.length;
      if (zerosA != zerosB) return zerosA - zerosB;
    } else if (da != db) {
      // Digits sort before non-digits.
      return da ? -1 : 1;
    } else {
      if (ca != cb) return ca - cb;
      i++;
      j++;
    }
  }
  return (sa.length - i) - (sb.length - j);
}

bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

String _stripLeadingZeros(String s) {
  var k = 0;
  while (k < s.length - 1 && s.codeUnitAt(k) == 0x30) {
    k++;
  }
  return s.substring(k);
}
