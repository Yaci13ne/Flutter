import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twedrli/Lists/list.dart';

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
// CHAT LIST PAGE
// ═══════════════════════════════════════════════════════════════════════════

class ChatPage extends StatefulWidget {
  final int? targetUserId;
  final String? targetUserName;
  final String? relatedItemId;

  const ChatPage({
    super.key,
    this.targetUserId,
    this.targetUserName,
    this.relatedItemId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> _chats = [];
  Map<int, String> _userNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final myId = loggedInUserIdNotifier.value;
    if (myId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final results = await Future.wait([
      TwedrliApi.getActiveChats(myId),
      TwedrliApi.getUserNames(),
    ]);

    final activeChats = results[0] as List<Map<String, dynamic>>;
    _userNames = results[1] as Map<int, String>;

    setState(() {
      _chats = activeChats;
      _isLoading = false;
    });

    // If targetUserId is provided, navigate to that conversation immediately
    if (widget.targetUserId != null) {
      final targetId = widget.targetUserId!;
      final targetName = widget.targetUserName ?? _userNames[targetId] ?? 'User #$targetId';
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ConversationPage(
              userId: targetId,
              name: targetName,
              relatedItemId: widget.relatedItemId,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
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
                  const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF9B59B6),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chat',
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
            Container(height: 2, color: const Color(0xFF9B59B6)),

            // ── Chat list ─────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _chats.isEmpty
                      ? const Center(child: Text('No active chats'))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.separated(
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
                              final contactId = chat['contact_id'] as int;
                              final name = _userNames[contactId] ?? 'User #$contactId';
                              final lastMsgAt = chat['last_message_at'] != null 
                                  ? DateTime.tryParse(chat['last_message_at'].toString()) 
                                  : null;
                              
                              final timeStr = lastMsgAt != null ? _formatTime(lastMsgAt) : '';

                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => _ConversationPage(
                                      userId: contactId,
                                      name: name,
                                      relatedItemId: widget.relatedItemId,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: const Color(0xFF9B59B6).withOpacity(isDark ? 0.25 : 0.15),
                                      child: Text(
                                        name.isNotEmpty ? name[0] : '?',
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
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    subtitle: Text(
                                      chat['last_message'] as String? ?? 'Click to view messages',
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey[600] : const Color(0xFFB0B4C8),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONVERSATION PAGE
// ═══════════════════════════════════════════════════════════════════════════

class _ConversationPage extends StatefulWidget {
  final int userId;
  final String name;
  final String? relatedItemId;

  const _ConversationPage({
    required this.userId,
    required this.name,
    this.relatedItemId,
  });

  @override
  State<_ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<_ConversationPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _isComposing = false;
  List<_Msg> _msgs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final myId = loggedInUserIdNotifier.value;
    if (myId == null) return;

    final rawMsgs = await TwedrliApi.getMessages(myId, widget.userId);
    
    setState(() {
      _msgs = rawMsgs.map((m) {
        return _Msg(
          text: m['content'] ?? '',
          isMe: m['sender_id'] == myId,
          time: m['created_at'] != null 
              ? DateTime.tryParse(m['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();
      _isLoading = false;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
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

  Future<void> _send() async {
    final myId = loggedInUserIdNotifier.value;
    if (myId == null) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Optimistic UI Update: Add message immediately
    final newMsg = _Msg(
      text: text,
      isMe: true,
      time: DateTime.now(),
    );
    
    setState(() {
      _msgs.add(newMsg);
      _isComposing = false;
    });
    _controller.clear();
    _scrollToBottom();
    HapticFeedback.lightImpact();

    // 2. Show "Purple Box" Feedback (SnackBar)
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text('Message sent!'),
            ],
          ),
          backgroundColor: const Color(0xFF9B59B6), // Purple
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    // 3. Try to send to API but ignore failures (user wants to "fake it")
    await TwedrliApi.sendMessage(myId, widget.userId, text);
    
    // Always refresh messages after a small delay to pick up server-side state if it actually worked
    Future.delayed(const Duration(seconds: 1), () => _fetchMessages());
  }

  void _confirmRecovery(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Recovery'),
        content: const Text('Is this conversation about an item you have successfully recovered?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not yet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleRecoverySuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, I found it!'),
          ),
        ],
      ),
    );
  }

  void _handleRecoverySuccess() {
    // 1. Mark as claimed locally and sync with server
    if (widget.relatedItemId != null) {
      TwedrliApi.markAsClaimedLocally(widget.relatedItemId!);
      TwedrliApi.updateItemStatus(widget.relatedItemId!, ItemStatus.claimed);
      debugPrint('✅ Item ${widget.relatedItemId} persistence handled');
    }

    final myId = loggedInUserIdNotifier.value;
    final activity = ActivityItem(
      title: 'Item Recovered! 🎉',
      subtitle: 'You confirmed receiving your item through chat with ${widget.name}.',
      type: ActivityType.recovered,
      timestamp: DateTime.now(),
      isUnread: true,
      userId: myId,
    );
    activityNotifier.value = [activity, ...activityNotifier.value];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Awesome! Item marked as recovered.'),
        backgroundColor: Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
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
                    backgroundColor: const Color(0xFF9B59B6).withOpacity(isDark ? 0.25 : 0.15),
                    child: Text(
                      widget.name.isNotEmpty ? widget.name[0] : '?',
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
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9B59B6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _confirmRecovery(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF43A047).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Color(0xFF43A047), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Found it!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF43A047),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: const Color(0xFF9B59B6)),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: _msgs.length,
                    itemBuilder: (context, i) {
                      final msg = _msgs[i];
                      final next = i < _msgs.length - 1 ? _msgs[i + 1] : null;
                      final lastInGroup = next == null || next.isMe != msg.isMe;
                      return _buildBubble(msg, lastInGroup, isDark);
                    },
                  ),
            ),
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
                        color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (v) => setState(() => _isComposing = v.trim().isNotEmpty),
                        onSubmitted: (_) => _send(),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : const Color(0xFFB0B4C8),
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
                        color: _isComposing ? const Color(0xFF9B59B6) : (isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE0E3EF)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: _isComposing ? Colors.white : (isDark ? Colors.grey[600] : const Color(0xFFB0B4C8)),
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
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe)
            SizedBox(
              width: 32,
              child: lastInGroup
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF9B59B6).withOpacity(isDark ? 0.25 : 0.15),
                      child: Text(
                        widget.name.isNotEmpty ? widget.name[0] : '?',
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
                color: msg.isMe ? const Color(0xFF9B59B6) : (isDark ? const Color(0xFF2A2A3A) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 18),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  color: msg.isMe ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
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
