import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'dart:ui';

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  DialogFlowtter? dialogFlowtter;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool isListening = false;
  bool shouldSpeak = true;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _initDialogflow();
    _initSpeechAndTTS();
  }

  Future<void> _initDialogflow() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/dadacare-nx9c-d32b88dee3ce.json',
      );
      Map<String, dynamic> jsonCredentials = json.decode(jsonString);
      DialogFlowtter df = DialogFlowtter(
        credentials: DialogAuthCredentials.fromJson(jsonCredentials),
      );
      setState(() => dialogFlowtter = df);
    } catch (e) {
      debugPrint("Dialogflow init error: $e");
    }
  }

  Future<void> _initSpeechAndTTS() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
  }

  void _sendMessage(String text) async {
    if (text.isEmpty || dialogFlowtter == null) return;
    setState(() {
      messages.add({'message': text, 'isUserMessage': true});
      _messageController.clear();
    });

    try {
      DetectIntentResponse response = await dialogFlowtter!.detectIntent(
        queryInput: QueryInput(
          text: TextInput(text: text, languageCode: selectedLanguage),
        ),
      );
      if (response.message != null) {
        final botText = response.message!.text?.text?[0] ?? '';
        setState(() {
          messages.add({'message': botText, 'isUserMessage': false});
        });
        if (shouldSpeak) await _speak(botText);
      }
    } catch (e) {
      debugPrint("Dialogflow error: $e");
      setState(() {
        messages.add({
          'message': 'Sorry, something went wrong.',
          'isUserMessage': false,
        });
      });
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.setLanguage(selectedLanguage == 'en' ? 'en-US' : 'sw');
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS error: $e");
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus:
          (status) => setState(
            () => isListening = !(status == "done" || status == "notListening"),
          ),
      onError: (error) => setState(() => isListening = false),
    );

    if (available) {
      setState(() => isListening = true);
      await _speech.listen(
        localeId: selectedLanguage == 'en' ? 'en_US' : 'sw',
        onResult:
            (val) =>
                setState(() => _messageController.text = val.recognizedWords),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please allow microphone permission.")),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => isListening = false);
  }

  @override
  void dispose() {
    dialogFlowtter?.dispose();
    _messageController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── Background ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe1f5fe), Color(0xfffce4ec)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ─── Centered Chatbox ───────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.lightBlue,
                            child: Icon(
                              Icons.support_agent,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'DadaCare Assistant',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Tooltip(
                            message: shouldSpeak ? 'Voice ON' : 'Voice OFF',
                            child: IconButton(
                              icon: Icon(
                                shouldSpeak
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () => shouldSpeak = !shouldSpeak,
                                  ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.language),
                            onSelected:
                                (value) =>
                                    setState(() => selectedLanguage = value),
                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value: 'en',
                                    child: Text('English'),
                                  ),
                                  PopupMenuItem(
                                    value: 'sw',
                                    child: Text('Kiswahili'),
                                  ),
                                ],
                          ),
                        ],
                      ),
                      const Divider(),
                      // Messages
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var message = messages[index];
                            return Align(
                              alignment:
                                  message['isUserMessage']
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color:
                                      message['isUserMessage']
                                          ? Colors.lightBlue[100]
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['message'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Input
                      Row(
                        children: [
                          Tooltip(
                            message:
                                isListening
                                    ? 'Stop listening'
                                    : 'Start listening',
                            child: IconButton(
                              icon: Icon(
                                isListening ? Icons.mic_off : Icons.mic,
                                color: Colors.blue,
                              ),
                              onPressed:
                                  isListening
                                      ? _stopListening
                                      : _startListening,
                            ),
                          ),
                          Expanded(
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[100],
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Ask me anything...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.blue),
                            onPressed:
                                () => _sendMessage(
                                  _messageController.text.trim(),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
