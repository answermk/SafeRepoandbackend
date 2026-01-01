import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_manager.dart';

/// AI Chat Service
/// Handles AI-powered chat conversations for support
class AIChatService {
  /// Send a message to the AI chat and get a response
  /// 
  /// [message] - The user's message
  /// [conversationHistory] - Previous messages in the conversation for context
  /// Returns a map with 'success', 'response', and optionally 'error'
  static Future<Map<String, dynamic>> sendMessage(
    String message, {
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication required. Please log in.',
        };
      }

      // Build conversation context from history
      String conversationContext = '';
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        conversationContext = conversationHistory
            .take(10) // Last 10 messages for context
            .map((msg) {
          final isUser = msg['isUser'] == true;
          final content = msg['message'] ?? msg['content'] ?? '';
          return isUser ? 'User: $content' : 'Assistant: $content';
        }).join('\n');
      }

      // Build the prompt with context
      String fullPrompt = message;
      if (conversationContext.isNotEmpty) {
        fullPrompt = '''Previous conversation:
$conversationContext

Current user message: $message

Please provide a helpful response as a Safe Report support assistant. Be concise, friendly, and professional.''';
      } else {
        fullPrompt = '''You are a helpful Safe Report support assistant. A user is asking: "$message"

Please provide a helpful, concise, and professional response. Safe Report is a crime prevention and reporting app that helps users report incidents, connect with watch groups, and stay safe in their communities.''';
      }

      // Use the dedicated chat endpoint (accessible to all authenticated users)
      var url = Uri.parse('${AppConfig.apiBaseUrl}/ai/chat');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message, // Send the user's message directly
          'conversationHistory': conversationHistory, // Include context if needed
        }),
      );

      // Fallback to test-gemini if chat endpoint doesn't exist yet
      if (response.statusCode == 404) {
        print('⚠️ Chat endpoint not found, falling back to test-gemini');
        url = Uri.parse('${AppConfig.apiBaseUrl}/ai/test-gemini');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'prompt': fullPrompt,
          }),
        );
      }

      print('🤖 AI Chat Response Status: ${response.statusCode}');
      print('🤖 AI Chat Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extract the AI response - handle different response formats
        String aiResponse = '';
        
        // Try response first (from chat endpoint)
        if (responseData['response'] != null) {
          if (responseData['response'] is String) {
            aiResponse = responseData['response'];
          } else if (responseData['response'] is Map) {
            final responseObj = responseData['response'];
            aiResponse = responseObj['summary'] ?? 
                        responseObj['content'] ?? 
                        responseObj.toString();
          }
        }
        // Try geminiResponse (from test-gemini endpoint fallback)
        else if (responseData['geminiResponse'] != null) {
          aiResponse = responseData['geminiResponse'];
        }
        // Try other possible fields
        else if (responseData['message'] != null) {
          aiResponse = responseData['message'];
        } else if (responseData['summary'] != null) {
          aiResponse = responseData['summary'];
        } else {
          // Fallback: try to extract from any text field
          aiResponse = responseData.toString();
        }

        // Clean up the response
        aiResponse = aiResponse.trim();
        if (aiResponse.isEmpty) {
          aiResponse = 'I apologize, but I couldn\'t generate a response. Please try again.';
        }

        return {
          'success': true,
          'response': aiResponse,
          'service': responseData['service'] ?? 'unknown',
        };
      } else {
        // Try to parse error message
        String errorMessage = 'Failed to get AI response';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? 
                        errorData['message'] ?? 
                        errorMessage;
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
              ? response.body 
              : 'Server error: ${response.statusCode}';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ AI Chat Error: $e');
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Check if AI service is available
  static Future<Map<String, dynamic>> checkAIServiceStatus() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        return {
          'success': false,
          'available': false,
          'error': 'Authentication required',
        };
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/ai/status');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'available': data['available'] ?? false,
          'currentService': data['currentService'] ?? 'unknown',
        };
      } else {
        return {
          'success': false,
          'available': false,
          'error': 'Failed to check AI service status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'available': false,
        'error': e.toString(),
      };
    }
  }
}

