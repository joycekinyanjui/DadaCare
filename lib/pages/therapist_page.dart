import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TherapistPage extends StatefulWidget {
  final String userId;
  final String therapistId;

  const TherapistPage({
    super.key,
    required this.userId,
    required this.therapistId,
  });

  @override
  State<TherapistPage> createState() => _TherapistPageState();
}

class _TherapistPageState extends State<TherapistPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late final String chatId;
  bool showNotice = true;

  @override
  void initState() {
    super.initState();
    chatId = _generateChatId(widget.userId, widget.therapistId);
    _setParticipants();
  }

  String _generateChatId(String userId, String therapistId) {
    return userId.hashCode <= therapistId.hashCode
        ? '${userId}_$therapistId'
        : '${therapistId}_$userId';
  }

  void _setParticipants() {
    _database.child('therapist_chats/$chatId/participants').update({
      widget.userId: true,
      widget.therapistId: true,
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = {
      'sender': widget.userId,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _database.child('therapist_chats/$chatId/messages').push().set(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Therapy Chat'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          if (showNotice)
            Container(
              color: Colors.yellow[100],
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Please Note:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Therapist replies may be delayed. Kindly ask only questions that require specialized medical or emotional feedback.\n\nFor random or general inquiries, please speak to the DadaCare Assistant instead.This page is to be used for consultation about physical or mental health issues that require medical expertise. Please remain patient, our doctors will reply in due time.\n\n If this is an emergency that requires immidiate attention Please call emergency hotlines",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => showNotice = false),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream:
                  _database
                      .child('therapist_chats/$chatId/messages')
                      .orderByChild('timestamp')
                      .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null || data is! Map) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages =
                    data.entries.map((entry) {
                        final value = entry.value;
                        if (value is Map<dynamic, dynamic>) {
                          final msg = Map<String, dynamic>.from(value);
                          return {
                            'text': msg['text'] ?? '',
                            'sender': msg['sender'] ?? '',
                            'timestamp': msg['timestamp'] ?? 0,
                          };
                        }
                        return {'text': '', 'sender': '', 'timestamp': 0};
                      }).toList()
                      ..sort(
                        (a, b) => (a['timestamp'] as int).compareTo(
                          b['timestamp'] as int,
                        ),
                      );

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender'] == widget.userId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.lightBlue[100] : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['text'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('h:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  message['timestamp'] as int,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.lightBlue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
