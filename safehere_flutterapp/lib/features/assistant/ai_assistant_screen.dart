import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/assistant_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _service = AssistantService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<AssistantMessage> _messages = [
    AssistantMessage('assistant', "Hi, I'm your SafeHer AI safety assistant. Ask me about safer routes, "
        "what to do if you feel unsafe, or how to use SOS and journey sharing."),
  ];
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(AssistantMessage('user', text));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();
    try {
      final reply = await _service.send(text, _messages);
      setState(() => _messages.add(AssistantMessage('assistant', reply)));
    } catch (_) {
      setState(() => _messages.add(AssistantMessage('assistant', "I couldn't reach the server. Please try again.")));
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Safety Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.rose : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isUser ? null : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(m.content, style: TextStyle(color: isUser ? Colors.white : AppColors.ink)),
                  ),
                );
              },
            ),
          ),
          if (_sending) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Ask about your safety…'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppColors.rose),
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
