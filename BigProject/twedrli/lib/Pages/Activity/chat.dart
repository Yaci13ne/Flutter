import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _Msg {
  final String text;
  final bool isMe;
  final DateTime time;

  _Msg({required this.text, required this.isMe, required this.time});
}

// ═══════════════════════════════════════════════════════════════════════════
// IN-MEMORY STORE
// ═══════════════════════════════════════════════════════════════════════════

class _Store extends ChangeNotifier {
  static final _Store _i = _Store._();
  factory _Store() => _i;
  _Store._();

  final Map<String, List<_Msg>> _convos = {};

  List<_Msg> msgs(String name) => _convos[name] ?? [];

  void send(String name, String text) {
    _convos.putIfAbsent(name, () => []);
    _convos[name]!.add(_Msg(text: text, isMe: true, time: DateTime.now()));
    notifyListeners();
  }

  String lastMsg(String name) {
    final list = _convos[name];
    if (list == null || list.isEmpty) return '';
    return list.last.text;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHAT LIST PAGE
// ═══════════════════════════════════════════════════════════════════════════

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _store = _Store();

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Alex',
      'msg': 'Hey! I think I found your water bottle 👋',
      'time': '3h ago',
      'unread': true,
      'seed': 'Hey! I think I found your water bottle 👋',
    },
    {
      'name': 'Jordan',
      'msg': 'Is this the umbrella you lost?',
      'time': '1d ago',
      'unread': false,
      'seed': 'Is this the umbrella you lost?',
    },
    {
      'name': 'Campus Security',
      'msg': 'Please pick up your ID at the front desk.',
      'time': '1d ago',
      'unread': false,
      'seed': 'Please pick up your ID at the front desk.',
    },
    {
      'name': 'Maya',
      'msg': 'Found your AirPods near the library!',
      'time': '2d ago',
      'unread': false,
      'seed': 'Found your AirPods near the library!',
    },
  ];

  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(() => setState(() {}));
    if (!_seeded) {
      _seeded = true;
      for (final c in _chats) {
        final name = c['name'] as String;
        if (_store.msgs(name).isEmpty) {
          _store._convos[name] = [
            _Msg(text: c['seed'] as String, isMe: false, time: DateTime.now()),
          ];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PageShell(
      title: 'Chat',
      accentColor: const Color(0xFF9B59B6),
      icon: Icons.chat_bubble_rounded,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _chats.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 76,
          color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFECEDF2),
        ),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final name = chat['name'] as String;
          final isUnread = chat['unread'] as bool;
          final displayMsg = _store.lastMsg(name).isNotEmpty
              ? _store.lastMsg(name)
              : chat['msg'] as String;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _ConversationPage(name: name)),
            ),
            child: Container(
              color: isUnread
                  ? (isDark ? const Color(0xFF1E1525) : const Color(0xFFFAF5FF))
                  : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
              child: Stack(
                children: [
                  if (isUnread)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3,
                        color: const Color(0xFF9B59B6),
                      ),
                    ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(
                        0xFF9B59B6,
                      ).withOpacity(isDark ? 0.25 : 0.15),
                      child: Text(
                        name[0],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B59B6),
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    subtitle: Text(
                      displayMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnread
                            ? (isDark
                                  ? Colors.white70
                                  : const Color(0xFF1A1A2E))
                            : (isDark
                                  ? Colors.grey[500]
                                  : const Color(0xFF7B8099)),
                        fontWeight: isUnread
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: Text(
                      chat['time'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[600]
                            : const Color(0xFFB0B4C8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONVERSATION PAGE
// ═══════════════════════════════════════════════════════════════════════════

class _ConversationPage extends StatefulWidget {
  final String name;
  const _ConversationPage({required this.name});

  @override
  State<_ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<_ConversationPage> {
  final _store = _Store();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onUpdate);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(animate: false),
    );
  }

  @override
  void dispose() {
    _store.removeListener(_onUpdate);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        final max = _scroll.position.maxScrollExtent;
        animate
            ? _scroll.animateTo(
                max,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              )
            : _scroll.jumpTo(max);
      }
    });
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    setState(() => _isComposing = false);
    _store.send(widget.name, text);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final msgs = _store.msgs(widget.name);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Container(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(
                      0xFF9B59B6,
                    ).withOpacity(isDark ? 0.25 : 0.15),
                    child: Text(
                      widget.name[0],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9B59B6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Text(
                          'Active now',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9B59B6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: const Color(0xFF9B59B6)),

            // ── Messages ──
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: msgs.length,
                itemBuilder: (context, i) {
                  final msg = msgs[i];
                  final next = i < msgs.length - 1 ? msgs[i + 1] : null;
                  final lastInGroup = next == null || next.isMe != msg.isMe;
                  return _buildBubble(msg, lastInGroup, isDark);
                },
              ),
            ),

            // ── Input ──
            Container(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A3A)
                            : const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (v) =>
                            setState(() => _isComposing = v.trim().isNotEmpty),
                        onSubmitted: (_) => _send(),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey[600]
                                : const Color(0xFFB0B4C8),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isComposing ? _send : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _isComposing
                            ? const Color(0xFF9B59B6)
                            : (isDark
                                  ? const Color(0xFF2A2A3A)
                                  : const Color(0xFFE0E3EF)),
                        shape: BoxShape.circle,
                        boxShadow: _isComposing
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF9B59B6,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: _isComposing
                            ? Colors.white
                            : (isDark
                                  ? Colors.grey[600]
                                  : const Color(0xFFB0B4C8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_Msg msg, bool lastInGroup, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        bottom: lastInGroup ? 8 : 2,
        left: msg.isMe ? 56 : 0,
        right: msg.isMe ? 0 : 56,
      ),
      child: Row(
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe)
            SizedBox(
              width: 32,
              child: lastInGroup
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(
                        0xFF9B59B6,
                      ).withOpacity(isDark ? 0.25 : 0.15),
                      child: Text(
                        widget.name[0],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B59B6),
                        ),
                      ),
                    )
                  : null,
            ),
          if (!msg.isMe) const SizedBox(width: 6),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isMe
                    ? const Color(0xFF9B59B6)
                    : (isDark ? const Color(0xFF2A2A3A) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: msg.isMe
                        ? const Color(0xFF9B59B6).withOpacity(0.25)
                        : Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  color: msg.isMe
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE SHELL
// ═══════════════════════════════════════════════════════════════════════════

class _PageShell extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;
  final Widget body;

  const _PageShell({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, color: accentColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: accentColor),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
