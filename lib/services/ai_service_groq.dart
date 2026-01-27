//this fiel has service of ai to use api of groq
//we use api from groq to generate widget quotes or notes

import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  static const String _baseUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  // TODO: Replace with your own Groq API key
  // Get one free at: https://console.groq.com/keys
  final String _apiKey = "YOUR_GROQ_API_KEY_HERE";

  Future<List<String>> fetchQuotes(String userRequest) async {
    final prompt =
        """
Your goal is to provide punchy, impactful, and deeply human quotes.
User request: $userRequest
- LENGTH: Short and punchy. Max 100 characters preferred.
- FORMAT: Generate 10 quotes, each on a new line. No numbering, no dashes.

""";

    try {
      print('🔄 Making API request...');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.4,
          "max_tokens": 600,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] ?? '';

        return text
            .toString()
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch quotes: $e');
    }
  }
}
