import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TherapistReplyPage extends StatefulWidget {
  final String therapistId;
  const TherapistReplyPage({
    super.key,
    required this.therapistId,
    required String userId,
  });

  @override
  State<TherapistReplyPage> createState() => _TherapistReplyPageState();
}

class _TherapistReplyPageState extends State<TherapistReplyPage> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  Map<String, String> patientNames = {};
  String? selectedPatientId;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _assignPatientsIfNotAlreadyAssigned();
  }

  void _assignPatientsIfNotAlreadyAssigned() async {
    final snapshot = await _db.child('therapist_chats').get();
    int count = 1;
    Map<String, String> names = {};

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (var entry in data.entries) {
        final participants = Map<String, dynamic>.from(
          entry.value['participants'] ?? {},
        );
        final users =
            participants.keys.where((id) => id != widget.therapistId).toList();

        for (String userId in users) {
          final userAssigned = participants.containsKey(widget.therapistId);

          if (userAssigned) {
            names[userId] = 'Patient #$count';
            count++;
          }
        }
      }
    }

    setState(() => patientNames = names);
  }

  void _sendMessage() {
    if (selectedPatientId == null || _messageController.text.trim().isEmpty) {
      return;
    }

    final chatId = _generateChatId(widget.therapistId, selectedPatientId!);
    final message = {
      'sender': widget.therapistId,
      'text': _messageController.text.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _db.child('therapist_chats/$chatId/messages').push().set(message);

    // 🔔 Placeholder: Push Notification Logic
    _sendPushNotificationToUser(
      selectedPatientId!,
      _messageController.text.trim(),
    );

    _messageController.clear();
  }

  String _generateChatId(String id1, String id2) {
    return id1.hashCode <= id2.hashCode ? '${id1}_$id2' : '${id2}_$id1';
  }

  void _sendPushNotificationToUser(String userId, String message) {
    // TODO: Integrate FCM push notifications here
    print("Push notification to $userId: $message");
  }

  Widget _buildChatMessages(String patientId) {
    final chatId = _generateChatId(widget.therapistId, patientId);

    return StreamBuilder<DatabaseEvent>(
      stream:
          _db
              .child('therapist_chats/$chatId/messages')
              .orderByChild('timestamp')
              .onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text("No messages"));
        }

        final messagesMap = Map<String, dynamic>.from(
          snapshot.data!.snapshot.value as Map,
        );
        final messages =
            messagesMap.entries.map((entry) {
                final val = Map<String, dynamic>.from(entry.value);
                return {
                  'sender': val['sender'] ?? '',
                  'text': val['text'] ?? '',
                  'timestamp': val['timestamp'] ?? 0,
                };
              }).toList()
              ..sort(
                (a, b) =>
                    (a['timestamp'] as int).compareTo(b['timestamp'] as int),
              );

        return ListView.builder(
          reverse: false,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg['sender'] == widget.therapistId;
            return Container(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.lightBlue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg['text']),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(msg['timestamp']),
                    ),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Chat'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: const Text("Select Patient"),
            value: selectedPatientId,
            isExpanded: true,
            onChanged: (String? newVal) {
              setState(() => selectedPatientId = newVal);
            },
            items:
                patientNames.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
          ),
          const Divider(height: 1),
          Expanded(
            child:
                selectedPatientId == null
                    ? const Center(
                      child: Text("Select a patient to start chatting"),
                    )
                    : _buildChatMessages(selectedPatientId!),
          ),
          if (selectedPatientId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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
