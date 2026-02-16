import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _workerUrl =
      "https://quote-api-proxy.salehthecoder.workers.dev";

  Future<List<String>> fetchQuotes(
    String userRequest, {
    bool useDeepMode = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userRequest": userRequest,
          "useDeepMode": useDeepMode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract content from ai response structure
        String fullText = data['choices']?[0]?['message']?['content'] ?? "";

        if (fullText.isEmpty) return ["No quotes found."];

        // Smart cleanup: Remove list-style numbering (1., 2), 3-) but preserve natural content
        List<String> quotesList = fullText
            .split('\n')
            .map((s) => s.trim())
            .map((s) => s.replaceAll(RegExp(r'^\d+[\.)\-]\s+'), ''))
            .where((s) => s.isNotEmpty)
            .toList();

        // Multi-tier filtering strategy
        List<String> validQuotes = quotesList
            .where((q) => q.length >= 10 && q.length <= 95)
            .toList();

        // Fallback: accept any reasonable quote
        if (validQuotes.length < 10) {
          validQuotes = quotesList.where((q) => q.length >= 10).toList();
        }

        List<String> finalQuotes = validQuotes.take(10).toList();

        return finalQuotes.isEmpty
            ? ["Unable to generate quotes. Try a different topic."]
            : finalQuotes;
      } else {
        return ["Error: ${response.statusCode}"];
      }
    } catch (e) {
      return ["Connection Error. Please check internet."];
    }
  }
}
