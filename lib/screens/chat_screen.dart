import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String domain;
  const ChatScreen({required this.domain, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, fromUser: true));
      _sending = true;
      _controller.clear();
    });

    final api = context.read<ApiService>();
    final res = await api.sendChat(domain: widget.domain, message: text);

    if (res['success'] == true) {
      final data = res['data'];
      String reply = '';
      if (data is Map && data['response'] != null) {
        reply = data['response'].toString();
      } else if (data is String) {
        reply = data;
      } else {
        reply = data.toString();
      }

      setState(() {
        _messages.add(ChatMessage(text: reply, fromUser: false));
        _sending = false;
      });
    } else {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: ${res['message'] ?? 'Unknown error'}', fromUser: false));
        _sending = false;
      });
      if (res['unauthorized'] == true) {
        // optional: redirect to login
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session expired. Please login again.')));
      }
    }
  }

  Widget _buildBubble(ChatMessage m) {
    final align = m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = m.fromUser ? Colors.blue.shade100 : Colors.grey.shade200;
    final radius = m.fromUser
        ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(12))
        : const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12));
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color, borderRadius: radius),
          child: Text(m.text),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${m.time.hour.toString().padLeft(2,'0')}:${m.time.minute.toString().padLeft(2,'0')}',
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suvidha — ${widget.domain}'),
        backgroundColor: const Color.fromARGB(255, 93, 116, 221),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildBubble(_messages[index]);
              },
            ),
          ),
          if (_sending) const LinearProgressIndicator(),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Ask Suvidha...',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 6),
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _sending ? null : _send,
                    child: const Icon(Icons.send),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
