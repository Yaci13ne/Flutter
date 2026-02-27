import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToAudioScreen extends StatefulWidget {
  const TextToAudioScreen({super.key});

  @override
  State<TextToAudioScreen> createState() => _TextToAudioScreenState();
}

class _TextToAudioScreenState extends State<TextToAudioScreen> {
  final FlutterTts tts = FlutterTts();
  final TextEditingController controller = TextEditingController();

  bool isPlaying = false;
  bool isPaused = false;
  bool loadingVoices = false;
  double speechRate = 0.5;
  double pitch = 1.0;
  double volume = 1.0;
  String selectedLocale = 'en-US';
  List<Map<String, String>> availableVoices = [];
  Map<String, String>? selectedVoice;

  final List<Map<String, String>> languages = [
    {'code': 'af-ZA', 'name': '🇿🇦 Afrikaans'},
    {'code': 'ar-SA', 'name': '🇸🇦 Arabic'},
    {'code': 'bg-BG', 'name': '🇧🇬 Bulgarian'},
    {'code': 'ca-ES', 'name': '🇪🇸 Catalan'},
    {'code': 'cs-CZ', 'name': '🇨🇿 Czech'},
    {'code': 'da-DK', 'name': '🇩🇰 Danish'},
    {'code': 'de-AT', 'name': '🇦🇹 German (Austria)'},
    {'code': 'de-DE', 'name': '🇩🇪 German (Germany)'},
    {'code': 'el-GR', 'name': '🇬🇷 Greek'},
    {'code': 'en-AU', 'name': '🇦🇺 English (Australia)'},
    {'code': 'en-GB', 'name': '🇬🇧 English (UK)'},
    {'code': 'en-IE', 'name': '🇮🇪 English (Ireland)'},
    {'code': 'en-IN', 'name': '🇮🇳 English (India)'},
    {'code': 'en-US', 'name': '🇺🇸 English (US)'},
    {'code': 'en-ZA', 'name': '🇿🇦 English (South Africa)'},
    {'code': 'es-AR', 'name': '🇦🇷 Spanish (Argentina)'},
    {'code': 'es-ES', 'name': '🇪🇸 Spanish (Spain)'},
    {'code': 'es-MX', 'name': '🇲🇽 Spanish (Mexico)'},
    {'code': 'es-US', 'name': '🇺🇸 Spanish (US)'},
    {'code': 'et-EE', 'name': '🇪🇪 Estonian'},
    {'code': 'fa-IR', 'name': '🇮🇷 Persian'},
    {'code': 'fi-FI', 'name': '🇫🇮 Finnish'},
    {'code': 'fil-PH', 'name': '🇵🇭 Filipino'},
    {'code': 'fr-BE', 'name': '🇧🇪 French (Belgium)'},
    {'code': 'fr-CA', 'name': '🇨🇦 French (Canada)'},
    {'code': 'fr-FR', 'name': '🇫🇷 French (France)'},
    {'code': 'gl-ES', 'name': '🇪🇸 Galician'},
    {'code': 'gu-IN', 'name': '🇮🇳 Gujarati'},
    {'code': 'he-IL', 'name': '🇮🇱 Hebrew'},
    {'code': 'hi-IN', 'name': '🇮🇳 Hindi'},
    {'code': 'hr-HR', 'name': '🇭🇷 Croatian'},
    {'code': 'hu-HU', 'name': '🇭🇺 Hungarian'},
    {'code': 'id-ID', 'name': '🇮🇩 Indonesian'},
    {'code': 'it-IT', 'name': '🇮🇹 Italian'},
    {'code': 'ja-JP', 'name': '🇯🇵 Japanese'},
    {'code': 'kn-IN', 'name': '🇮🇳 Kannada'},
    {'code': 'ko-KR', 'name': '🇰🇷 Korean'},
    {'code': 'lt-LT', 'name': '🇱🇹 Lithuanian'},
    {'code': 'lv-LV', 'name': '🇱🇻 Latvian'},
    {'code': 'ml-IN', 'name': '🇮🇳 Malayalam'},
    {'code': 'mr-IN', 'name': '🇮🇳 Marathi'},
    {'code': 'ms-MY', 'name': '🇲🇾 Malay'},
    {'code': 'nb-NO', 'name': '🇳🇴 Norwegian'},
    {'code': 'nl-BE', 'name': '🇧🇪 Dutch (Belgium)'},
    {'code': 'nl-NL', 'name': '🇳🇱 Dutch (Netherlands)'},
    {'code': 'pl-PL', 'name': '🇵🇱 Polish'},
    {'code': 'pt-BR', 'name': '🇧🇷 Portuguese (Brazil)'},
    {'code': 'pt-PT', 'name': '🇵🇹 Portuguese (Portugal)'},
    {'code': 'ro-RO', 'name': '🇷🇴 Romanian'},
    {'code': 'ru-RU', 'name': '🇷🇺 Russian'},
    {'code': 'sk-SK', 'name': '🇸🇰 Slovak'},
    {'code': 'sl-SI', 'name': '🇸🇮 Slovenian'},
    {'code': 'sq-AL', 'name': '🇦🇱 Albanian'},
    {'code': 'sr-RS', 'name': '🇷🇸 Serbian'},
    {'code': 'sv-SE', 'name': '🇸🇪 Swedish'},
    {'code': 'sw-KE', 'name': '🇰🇪 Swahili'},
    {'code': 'ta-IN', 'name': '🇮🇳 Tamil'},
    {'code': 'te-IN', 'name': '🇮🇳 Telugu'},
    {'code': 'th-TH', 'name': '🇹🇭 Thai'},
    {'code': 'tr-TR', 'name': '🇹🇷 Turkish'},
    {'code': 'uk-UA', 'name': '🇺🇦 Ukrainian'},
    {'code': 'ur-PK', 'name': '🇵🇰 Urdu'},
    {'code': 'vi-VN', 'name': '🇻🇳 Vietnamese'},
    {'code': 'zh-CN', 'name': '🇨🇳 Chinese (Simplified)'},
    {'code': 'zh-HK', 'name': '🇭🇰 Chinese (Hong Kong)'},
    {'code': 'zh-TW', 'name': '🇹🇼 Chinese (Traditional)'},
    {'code': 'zu-ZA', 'name': '🇿🇦 Zulu'},
  ];

  @override
  void initState() {
    super.initState();
    _configureTts();
    _loadVoicesForLocale(selectedLocale);
  }

  void _configureTts() {
    tts.setStartHandler(() => setState(() {
          isPlaying = true;
          isPaused = false;
        }));
    tts.setCompletionHandler(() => setState(() {
          isPlaying = false;
          isPaused = false;
        }));
    tts.setCancelHandler(() => setState(() {
          isPlaying = false;
          isPaused = false;
        }));
    tts.setPauseHandler(() => setState(() {
          isPaused = true;
          isPlaying = false;
        }));
    tts.setContinueHandler(() => setState(() {
          isPaused = false;
          isPlaying = true;
        }));
    tts.setErrorHandler((msg) {
      setState(() {
        isPlaying = false;
        isPaused = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTS error: $msg')),
      );
    });
  }

  /// Fetches all voices from the device that match the selected locale,
  /// then picks the first one as default.
  Future<void> _loadVoicesForLocale(String locale) async {
    setState(() {
      loadingVoices = true;
      availableVoices = [];
      selectedVoice = null;
    });

    try {
      final raw = await tts.getVoices;
      if (raw == null) {
        setState(() => loadingVoices = false);
        return;
      }

      // flutter_tts returns List<dynamic> where each item is a Map
      final all = (raw as List)
          .map((v) => Map<String, String>.from(
                (v as Map)
                    .map((k, val) => MapEntry(k.toString(), val.toString())),
              ))
          .toList();

      // Match by locale prefix (e.g. "en-US" or "en_US") — case-insensitive
      final normalized = locale.replaceAll('-', '_').toLowerCase();
      final filtered = all.where((v) {
        final vLocale = (v['locale'] ?? '').replaceAll('-', '_').toLowerCase();
        return vLocale == normalized ||
            vLocale.startsWith(normalized.split('_').first);
      }).toList();

      // Sort: exact locale match first, then alphabetically by name
      filtered.sort((a, b) {
        final aExact = (a['locale'] ?? '').replaceAll('-', '_').toLowerCase() ==
            normalized;
        final bExact = (b['locale'] ?? '').replaceAll('-', '_').toLowerCase() ==
            normalized;
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      });

      setState(() {
        availableVoices = filtered;
        selectedVoice = filtered.isNotEmpty ? filtered.first : null;
        loadingVoices = false;
      });
    } catch (_) {
      setState(() => loadingVoices = false);
    }
  }

  Future<void> _applySettings() async {
    await tts.setLanguage(selectedLocale);
    if (selectedVoice != null) {
      await tts.setVoice(selectedVoice!);
    }
    await tts.setSpeechRate(speechRate);
    await tts.setPitch(pitch);
    await tts.setVolume(volume);
  }

  Future<void> _speak() async {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text first.')),
      );
      return;
    }
    await _applySettings();
    await tts.speak(text);
  }

  Future<void> _pause() async => await tts.pause();
  Future<void> _resume() async => await tts.speak(controller.text.trim());
  Future<void> _stop() async => await tts.stop();

  /// Small chip showing whether a voice is "enhanced", "compact", "neural", etc.
  Widget _voiceQualityBadge(String name) {
    String label = '';
    Color color = Colors.grey;

    final lower = name.toLowerCase();
    if (lower.contains('neural') || lower.contains('wavenet')) {
      label = 'Neural';
      color = Colors.purple;
    } else if (lower.contains('enhanced') || lower.contains('premium')) {
      label = 'Enhanced';
      color = Colors.blue;
    } else if (lower.contains('compact')) {
      label = 'Compact';
      color = Colors.orange;
    }

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sliderTile({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        SizedBox(
            width: 56,
            child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            onChanged: (v) => setState(() => onChanged(v)),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12), textAlign: TextAlign.end),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPause = isPlaying;
    final canResume = isPaused;
    final canStop = isPlaying || isPaused;

    return Scaffold(
      appBar: AppBar(title: const Text('Text To Audio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Text input ──────────────────────────────────────────────────
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Type or paste text here…',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear',
                    onPressed: () => controller.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Language picker ─────────────────────────────────────────────
              DropdownButtonFormField<String>(
                value: selectedLocale,
                decoration: InputDecoration(
                  labelText: 'Language',
                  prefixIcon: const Icon(Icons.language),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                isExpanded: true,
                items: languages
                    .map((lang) => DropdownMenuItem(
                          value: lang['code'],
                          child: Text(lang['name']!),
                        ))
                    .toList(),
                onChanged: canStop
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            selectedLocale = val;
                            selectedVoice = null;
                          });
                          _loadVoicesForLocale(val);
                        }
                      },
              ),
              const SizedBox(height: 14),

              // ── Voice picker ────────────────────────────────────────────────
              if (loadingVoices)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Loading voices…',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else if (availableVoices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No voices found for this language on your device. '
                          'The system default will be used.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voice  (${availableVoices.length} available)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<Map<String, String>>(
                      value: selectedVoice,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.record_voice_over),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      isExpanded: true,
                      items: availableVoices.map((voice) {
                        final rawName = voice['name'] ?? 'Unknown';
                        // Make the name more readable: strip locale prefix if present
                        final displayName =
                            rawName.replaceAll('_', ' ').replaceAll('-', ' ');
                        return DropdownMenuItem(
                          value: voice,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(displayName,
                                      overflow: TextOverflow.ellipsis)),
                              _voiceQualityBadge(rawName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: canStop
                          ? null
                          : (val) {
                              if (val != null)
                                setState(() => selectedVoice = val);
                            },
                    ),

                    // Preview chip
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ActionChip(
                        avatar: const Icon(Icons.play_circle_outline, size: 16),
                        label: const Text('Preview voice',
                            style: TextStyle(fontSize: 12)),
                        onPressed: canStop
                            ? null
                            : () async {
                                await _applySettings();
                                await tts
                                    .speak('Hello, this is a voice preview.');
                              },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // ── Sliders ─────────────────────────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    children: [
                      _sliderTile(
                        icon: Icons.speed,
                        label: 'Speed',
                        value: speechRate,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (v) => speechRate = v,
                      ),
                      _sliderTile(
                        icon: Icons.music_note,
                        label: 'Pitch',
                        value: pitch,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        onChanged: (v) => pitch = v,
                      ),
                      _sliderTile(
                        icon: Icons.volume_up,
                        label: 'Volume',
                        value: volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        onChanged: (v) => volume = v,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Status indicator ────────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: (isPlaying || isPaused) ? 36 : 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPlaying ? Icons.graphic_eq : Icons.pause_circle_outline,
                      size: 18,
                      color:
                          isPlaying ? theme.colorScheme.primary : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPlaying ? 'Playing…' : 'Paused',
                      style: TextStyle(
                        color: isPlaying
                            ? theme.colorScheme.primary
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Playback buttons ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed:
                          canResume ? _resume : (!isPlaying ? _speak : null),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(canResume ? 'Resume' : 'Play'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: canPause ? _pause : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: canStop ? _stop : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tts.stop();
    controller.dispose();
    super.dispose();
  }
}
