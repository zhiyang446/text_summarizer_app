import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _openAIKey =
      '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';
  static const String _openAIEndpoint = 'https://api.openai.com/v1/completions';

  static Future<String> summarizeWithOpenAI({
    required inputText,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_openAIEndpoint),
        headers: {
          'Content-Type': 'application/json;charset=utf-8',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: utf8.encode(
          jsonEncode({
            "model": "text-davinci-003",
            "prompt": inputText,
            "max_tokens": 1024,
            "temperature": 1,
            "top_p": 1,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final String generatedSummary = data['choices'][0]['text'] as String;
        return generatedSummary;
      } else {
        print('OpenAI API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to summarize with OpenAI');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Failed to summarize with OpenAI');
    }
  }
}
