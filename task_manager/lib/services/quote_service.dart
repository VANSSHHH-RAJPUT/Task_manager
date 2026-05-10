import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  final String content;
  final String author;

  Quote({required this.content, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['quote'] ?? json['content'] ?? 'No quote found',
      author: json['author'] ?? 'Unknown',
    );
  }
}

class QuoteService {
  // The primary API required by the assignment
  static const String _primaryUrl = 'https://api.quotable.io/random';
  // Fallback API in case the primary is down (quotable.io has frequent outages)
  static const String _fallbackUrl = 'https://dummyjson.com/quotes/random';

  Future<Quote> getRandomQuote() async {
    try {
      // First attempt: Try the assignment's primary API with a 5-second timeout
      final response = await http.get(Uri.parse(_primaryUrl)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        return Quote.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Primary API failed (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Second attempt: If the primary API is completely offline or times out, fallback to a reliable source
      try {
        final fallbackResponse = await http.get(Uri.parse(_fallbackUrl)).timeout(
          const Duration(seconds: 5),
        );

        if (fallbackResponse.statusCode == 200) {
          return Quote.fromJson(jsonDecode(fallbackResponse.body));
        } else {
          throw Exception('Fallback API failed (Status: ${fallbackResponse.statusCode})');
        }
      } catch (fallbackError) {
        // If both fail, return a default elegant quote instead of crashing the UI
        return Quote(
          content: "The secret of getting ahead is getting started.",
          author: "Mark Twain",
        );
      }
    }
  }
}
