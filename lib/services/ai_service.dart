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

        // For debugging: debugPrint("MODEL REPLIED: ${data['modelUsed']}");

        // Extract content from ai response structure
        String fullText = data['choices']?[0]?['message']?['content'] ?? "";

        if (fullText.isEmpty) return ["No quotes found."];

        // Smart cleanup: Remove list-style numbering (1., 2), 3-) but preserve natural content
        List<String> quotesList = fullText
            .split('\n')
            .map((s) => s.trim())
            .map(
              (s) => s.replaceAll(RegExp(r'^\d+[\.\)\-]\s+'), ''),
            ) // Smarter regex
            .where((s) => s.isNotEmpty)
            .toList();

        // Multi-tier filtering strategy: Try best quality first, relax if needed
        List<String> validQuotes = [];

        // Cloudflare already filters to 10-80 chars, so we trust that
        validQuotes = quotesList
            .where((q) => q.length >= 10 && q.length <= 95)
            .toList();

        // Fallback: If somehow we got fewer than 10, accept any reasonable quote
        if (validQuotes.length < 10) {
          validQuotes = quotesList.where((q) => q.length >= 10).toList();
        }

        // Take up to 10 quotes, or return what we have
        List<String> finalQuotes = validQuotes.take(10).toList();

        // Safety: Return error if completely empty
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

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AiService {
//   // 1. Updated API Key and Base URL for Mistral
//   static const String _apiKey = "PuUre8GrM3PEGyPiz9aFYmDGBpdutzm8";
//   static const String _baseUrl = "https://api.mistral.ai/v1/chat/completions";

//   Future<List<String>> fetchQuotes(
//     String userRequest, {
//     bool useSearch =
//         false, // NOTE: Mistral does not support native "Google Search"
//   }) async {
//     // 2. Mistral uses "messages" with "system" and "user" roles
//     final List<Map<String, String>> messages = [
//       {
//         "role": "system",
//         "content": """
// Role: Curator of rare, high-quality, authentic wisdom.
// Rules:
// 1. QUANTITY: Always provide exactly 10 quotes.
// 2. LENGTH: Each quote must be 50 to 100 characters.
// 3. STYLE: Authentic and matching the user's vibe.
// 4. FORMAT: No numbers, no bullets. Just the quotes, one per line.
// """,
//       },
//       {
//         "role": "user",
//         "content":
//             "Topic: $userRequest. Give me exactly 10 quotes, each under 100 characters.",
//       },
//     ];

//     try {
//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization':
//               'Bearer $_apiKey', // 3. Mistral requires "Bearer" token
//         },
//         body: jsonEncode({
//           "model":
//               "mistral-small-latest", // 4. Use "mistral-small-latest" or "open-mixtral-8x22b"
//           "messages": messages,
//           "temperature": 0.7,
//           "max_tokens": 1000,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // 5. Mistral response path: data['choices'][0]['message']['content']
//         String fullText = data['choices']?[0]?['message']?['content'] ?? "";

//         if (fullText.isEmpty) return ["No quotes found."];

//         List<String> quotes = fullText
//             .split('\n')
//             .map((s) => s.trim())
//             .map((s) => s.replaceAll(RegExp(r'^[0-9\.\-\*\s]+'), ''))
//             .where((s) => s.length > 15)
//             .toList();

//         return quotes.take(10).toList();
//       } else {
//         // Handle 429 specifically for your testing
//         if (response.statusCode == 429) {
//           return ["Limit reached. Try again in 1 minute."];
//         }
//         return ["Error: ${response.statusCode}"];
//       }
//     } catch (e) {
//       return ["Connection Error: $e"];
//     }
//   }
// }
