import 'api_client.dart';

class AssistantMessage {
  final String role; // "user" | "assistant"
  final String content;
  AssistantMessage(this.role, this.content);
}

class AssistantService {
  final _dio = ApiClient.instance.dio;

  Future<String> send(String message, List<AssistantMessage> history) async {
    final res = await _dio.post('/api/assistant/chat', data: {
      'message': message,
      'history': history.map((m) => {'role': m.role, 'content': m.content}).toList(),
    });
    return res.data['reply'] as String;
  }
}
