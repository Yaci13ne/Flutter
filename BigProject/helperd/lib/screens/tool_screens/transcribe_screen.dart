import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TranscribeScreen extends StatefulWidget {
  const TranscribeScreen({super.key});

  @override
  State<TranscribeScreen> createState() => _TranscribeScreenState();
}

class _TranscribeScreenState extends State<TranscribeScreen> {
  final SpeechToText stt = SpeechToText();
  String text = "";
  bool listening = false;
  bool initialized = false;

  // Supported languages: locale code + display name
  final List<Map<String, String>> languages = [
    {'code': 'en_US', 'name': '🇺🇸 English (US)'},
    {'code': 'en_GB', 'name': '🇬🇧 English (UK)'},
    {'code': 'ar_SA', 'name': '🇸🇦 Arabic'},
    {'code': 'zh_CN', 'name': '🇨🇳 Chinese (Simplified)'},
    {'code': 'zh_TW', 'name': '🇹🇼 Chinese (Traditional)'},
    {'code': 'nl_NL', 'name': '🇳🇱 Dutch'},
    {'code': 'fr_FR', 'name': '🇫🇷 French'},
    {'code': 'de_DE', 'name': '🇩🇪 German'},
    {'code': 'hi_IN', 'name': '🇮🇳 Hindi'},
    {'code': 'id_ID', 'name': '🇮🇩 Indonesian'},
    {'code': 'it_IT', 'name': '🇮🇹 Italian'},
    {'code': 'ja_JP', 'name': '🇯🇵 Japanese'},
    {'code': 'ko_KR', 'name': '🇰🇷 Korean'},
    {'code': 'fa_IR', 'name': '🇮🇷 Persian'},
    {'code': 'pl_PL', 'name': '🇵🇱 Polish'},
    {'code': 'pt_BR', 'name': '🇧🇷 Portuguese (Brazil)'},
    {'code': 'pt_PT', 'name': '🇵🇹 Portuguese (Portugal)'},
    {'code': 'ro_RO', 'name': '🇷🇴 Romanian'},
    {'code': 'ru_RU', 'name': '🇷🇺 Russian'},
    {'code': 'es_ES', 'name': '🇪🇸 Spanish (Spain)'},
    {'code': 'es_MX', 'name': '🇲🇽 Spanish (Mexico)'},
    {'code': 'sv_SE', 'name': '🇸🇪 Swedish'},
    {'code': 'tr_TR', 'name': '🇹🇷 Turkish'},
    {'code': 'uk_UA', 'name': '🇺🇦 Ukrainian'},
    {'code': 'vi_VN', 'name': '🇻🇳 Vietnamese'},
  ];

  String selectedLocale = 'en_US';

  Future<void> _ensureInitialized() async {
    if (!initialized) {
      initialized = await stt.initialize(
        onError: (e) => debugPrint('STT error: $e'),
      );
    }
  }

  Future<void> toggle() async {
    if (!listening) {
      await _ensureInitialized();
      if (!initialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Microphone permission denied or unavailable.')),
        );
        return;
      }
      await stt.listen(
        onResult: (r) => setState(() => text = r.recognizedWords),
        localeId: selectedLocale,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
      );
    } else {
      await stt.stop();
    }
    setState(() => listening = !listening);
  }

  void _copyText() {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _shareText() {
    if (text.isEmpty) return;
    Share.share(text);
  }

  void _clearText() {
    setState(() => text = "");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transcribe"),
        actions: [
          // Language picker
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLocale,
                icon: const Icon(Icons.language),
                borderRadius: BorderRadius.circular(12),
                items: languages.map((lang) {
                  return DropdownMenuItem(
                    value: lang['code'],
                    child: Text(lang['name']!),
                  );
                }).toList(),
                onChanged: listening
                    ? null // lock during recording
                    : (val) {
                        if (val != null) setState(() => selectedLocale = val);
                      },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: toggle,
        icon: Icon(listening ? Icons.stop : Icons.mic),
        label: Text(listening ? 'Stop' : 'Record'),
        backgroundColor: listening ? Colors.red : theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Listening indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: listening ? 40 : 0,
            color: Colors.red.shade50,
            child: listening
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fiber_manual_record,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 8),
                      Text('Listening...',
                          style: TextStyle(color: Colors.red.shade700)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // Transcript area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              child: hasText
                  ? SelectableText(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic_none,
                              size: 64,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.2)),
                          const SizedBox(height: 12),
                          Text(
                            'Tap Record to start transcribing',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Action bar (copy / share / clear)
          if (hasText)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 72),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyText,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareText,
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _clearText,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear'),
                      style:
                          OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
