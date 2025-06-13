import 'package:string_similarity/string_similarity.dart';
import 'password_storage.dart';

class SimilarityMatcher {
  static Future<MapEntry<String, String>?> findClosestMatch(
    String input,
  ) async {
    final allPasswords = await PasswordStorage.getAllPasswords();
    if (allPasswords.isEmpty) return null;

    final bestMatch = allPasswords.entries.reduce((a, b) {
      final aScore = StringSimilarity.compareTwoStrings(input, a.key);
      final bScore = StringSimilarity.compareTwoStrings(input, b.key);
      return aScore > bScore ? a : b;
    });

    // Optional: Add threshold to avoid incorrect matches
    final score = StringSimilarity.compareTwoStrings(input, bestMatch.key);
    if (score < 0.3) return null;

    return bestMatch;
  }
}
