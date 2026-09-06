import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:twedrli/Widgets/page_shell.dart';
import 'package:twedrli/Pages/Activity/chat.dart';

// ─────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────

enum ItemStatus { lost, found, claimed }

enum SortOption { newest, oldest, alphabetAZ, alphabetZA }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.alphabetAZ:
        return 'A to Z';
      case SortOption.alphabetZA:
        return 'Z to A';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.newest:
        return Icons.arrow_downward;
      case SortOption.oldest:
        return Icons.arrow_upward;
      case SortOption.alphabetAZ:
        return Icons.sort_by_alpha;
      case SortOption.alphabetZA:
        return Icons.sort_by_alpha;
    }
  }
}

// ─────────────────────────────────────────────
// LOCAL IMAGE CACHE
// Stores base64 images by item ID so they survive
// fetchProducts() re-runs (server may not return img_url).
// ─────────────────────────────────────────────
final Map<String, String> _localImageCache = {};

/// Call this after a successful POST to remember the image locally.
void cacheImageForItem(String itemId, String base64DataUri) {
  if (itemId.isNotEmpty && base64DataUri.isNotEmpty) {
    _localImageCache[itemId] = base64DataUri;
    debugPrint(
      '💾 Cached image for item $itemId (${base64DataUri.length} chars)',
    );
  }
}

/// Returns the best available image for an item:
/// server URL if available, otherwise local cache.
String resolveImage(String itemId, String serverImgUrl) {
  // Server returned a real value — use it
  if (serverImgUrl.isNotEmpty) return serverImgUrl;
  // Fall back to local cache
  final cached = _localImageCache[itemId];
  if (cached != null && cached.isNotEmpty) {
    debugPrint('🔁 Using cached image for item $itemId');
    return cached;
  }
  return '';
}

// ─────────────────────────────────────────────
// IMAGE URL NORMALISATION
// ─────────────────────────────────────────────
String _normaliseImageUrl(dynamic raw) {
  if (raw == null) return '';
  final s = raw.toString().trim();
  if (s.isEmpty || s == 'null') return '';
  if (s.startsWith('data:image')) return s;
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  // Raw base64 without data URI prefix
  if (_looksLikeBase64(s)) return 'data:image/jpeg;base64,$s';
  return s;
}

bool _looksLikeBase64(String s) {
  if (s.length < 20) return false;
  return RegExp(
    r'^[A-Za-z0-9+/\r\n]+=*$',
  ).hasMatch(s.replaceAll('\n', '').replaceAll('\r', ''));
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

class LostFoundItem {
  final String id;
  final String title;
  final String location;
  final DateTime timestamp;
  final ItemStatus status;
  final String imagePath;
  final String description;
  final String contactInfo;
  final String color;
  final String category;
  final int? userId;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String get locationDisplay {
    const map = {
      'info': 'Faculté d\'Informatique',
      'sm': 'Faculté des Sciences et Mathématiques',
      'st': 'Faculté des Sciences et Technologie',
      'math': 'Faculté des Mathématiques',
    };
    return map[location] ?? location;
  }

  const LostFoundItem({
    required this.id,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.status,
    required this.imagePath,
    this.description = '',
    this.contactInfo = '',
    this.color = '',
    required this.category,
    this.userId,
  });

  LostFoundItem copyWith({ItemStatus? status}) {
    return LostFoundItem(
      id: id,
      title: title,
      location: location,
      timestamp: timestamp,
      status: status ?? this.status,
      imagePath: imagePath,
      description: description,
      contactInfo: contactInfo,
      color: color,
      category: category,
      userId: userId,
    );
  }

  factory LostFoundItem.fromJson(
    Map<String, dynamic> json, {
    String reporterName = '',
  }) {
    ItemStatus parseStatus(String? s) {
      switch (s) {
        case 'found':
          return ItemStatus.found;
        case 'claimed':
          return ItemStatus.claimed;
        default:
          return ItemStatus.lost;
      }
    }

    final id = json['id']?.toString() ?? '';
    final userId = json['user_id'] as int?;

    // ── Safely read title — try common field names ───────────────────────────
    final title =
        (json['title'] ?? json['name'] ?? json['item_title'] ?? 'Untitled')
            .toString()
            .trim();

    final contact = reporterName.isNotEmpty
        ? 'Reported by $reporterName'
        : 'Reported by user #${json['user_id']}';

    // ── Normalise image, then apply local cache fallback ────────────────────
    final serverImgRaw = json['img_url']?.toString() ?? '';
    if (serverImgRaw.isNotEmpty && serverImgRaw != 'null') {
      debugPrint('🌐 Server returned img_url for item $id (length: ${serverImgRaw.length})');
    } else {
      debugPrint('⚠️ No image data found in DB for item $id');
    }

    final serverImg = _normaliseImageUrl(json['img_url']);
    final finalImg = resolveImage(id, serverImg);

    return LostFoundItem(
      id: id,
      title: title.isEmpty ? 'Untitled' : title,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      status: parseStatus(json['status'] as String?),
      location: json['location']?.toString() ?? '',
      timestamp: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imagePath: finalImg,
      contactInfo: contact,
      color: json['color']?.toString() ?? '',
      userId: userId,
    );
  }
}

// ─────────────────────────────────────────────
// ACTIVITY MODELS & NOTIFIER
// ─────────────────────────────────────────────

enum ActivityType { approved, match, message, recovered, security, system }

class ActivityItem {
  final String title;
  final String subtitle;
  final ActivityType type;
  final bool isUnread;
  final DateTime timestamp;
  final int? userId;
  final int? relatedUserId;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
    this.isUnread = false,
    this.userId,
    this.relatedUserId,
  });

  String get displayTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}';
  }

  ActivityItem copyWith({bool? isUnread}) {
    return ActivityItem(
      title: title,
      subtitle: subtitle,
      type: type,
      timestamp: timestamp,
      isUnread: isUnread ?? this.isUnread,
      userId: userId,
      relatedUserId: relatedUserId,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'time': displayTime,
        'type': type.index,
        'isUnread': isUnread,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
        'relatedUserId': relatedUserId,
      };
}

final ValueNotifier<List<ActivityItem>> activityNotifier = ValueNotifier([
  ActivityItem(
    title: 'Welcome to Twedrli',
    subtitle: 'Start reporting lost items to help your community!',
    type: ActivityType.system,
    timestamp: DateTime.now(),
    isUnread: true,
    userId: null, // System message
  ),
]);

// ─────────────────────────────────────────────
// NOTIFIERS
// ─────────────────────────────────────────────

final ValueNotifier<List<LostFoundItem>> allItemsNotifier = ValueNotifier([]);
final ValueNotifier<List<LostFoundItem>> savedItemsNotifier = ValueNotifier([]);

// Local persistence for claims to prevent revert on refresh if API fails
final Set<String> _localClaimedIds = {};
final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(true);
final ValueNotifier<String> errorNotifier = ValueNotifier('');

final ValueNotifier<int?> loggedInUserIdNotifier = ValueNotifier<int?>(null);
final ValueNotifier<String> loggedInUserNameNotifier = ValueNotifier<String>(
  '',
);
final ValueNotifier<String> loggedInTokenNotifier = ValueNotifier<String>('');
final ValueNotifier<String> loggedInDepartmentNotifier = ValueNotifier<String>(
  '',
);
final ValueNotifier<bool> isGuestNotifier = ValueNotifier<bool>(false);

// ─────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────

class TwedrliApi {
  static const String _base = 'https://twedrliapi.linguaflo.me';

  static Future<void> fetchProducts() async {
    isLoadingNotifier.value = true;
    errorNotifier.value = '';
    try {
      final results = await Future.wait([
        http
            .get(Uri.parse('$_base/products'))
            .timeout(const Duration(seconds: 15)),
        http
            .get(Uri.parse('$_base/users'))
            .timeout(const Duration(seconds: 15)),
      ]);

      final productsRes = results[0];
      final usersRes = results[1];

      final Map<int, String> userNames = {};
      if (usersRes.statusCode == 200) {
        final List<dynamic> userList = json.decode(usersRes.body);
        for (final u in userList) {
          userNames[u['id'] as int] = u['name'] ?? 'Unknown';
        }
      }

      if (productsRes.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(productsRes.body);
        allItemsNotifier.value = jsonList.map((e) {
          final map = e as Map<String, dynamic>;
          final userId = map['user_id'] as int?;
          final name = userId != null ? (userNames[userId] ?? '') : '';
          final item = LostFoundItem.fromJson(map, reporterName: name);
          
          // Apply local claim override
          if (_localClaimedIds.contains(item.id)) {
            return item.copyWith(status: ItemStatus.claimed);
          }
          return item;
        }).toList();

        checkPotentialMatches();
      } else {
        errorNotifier.value = 'Server error ${productsRes.statusCode}';
      }
    } catch (e) {
      errorNotifier.value =
          'Could not reach the server. Check your connection.';
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  static void markAsClaimedLocally(String id) {
    _localClaimedIds.add(id);
    // Also update current state
    final items = allItemsNotifier.value;
    final idx = items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(status: ItemStatus.claimed);
      allItemsNotifier.value = List.from(items);
    }
  }

  static Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/products/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      debugPrint('DELETE /products/$id → ${response.statusCode}');
      // Also remove from local image cache
      _localImageCache.remove(id);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('DELETE error: $e');
      return false;
    }
  }

  static Future<bool> updateItemStatus(String id, ItemStatus status) async {
    try {
      final statusStr = status.name;
      final response = await http.put(
        Uri.parse('$_base/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': statusStr}),
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('PUT /products/$id status=$statusStr → ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('updateItemStatus error: $e');
      return false;
    }
  }

  // ── Message Methods ────────────────────────────────────────────────────────
  
  // Local cache for messages that failed to sync but we want to show anyway
  static final List<Map<String, dynamic>> _localMessageStorage = [];
  static final Map<int, String> _localUserNames = {
    // Add "yacined" for demo purposes
    12345: 'yacined', 
  };

  static void registerLocalName(int id, String name) {
    _localUserNames[id] = name;
  }

  static Future<List<Map<String, dynamic>>> getActiveChats(int userId) async {
    List<Map<String, dynamic>> serverChats = [];
    try {
      final response = await http
          .get(Uri.parse('$_base/messages/user/$userId'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        serverChats = List<Map<String, dynamic>>.from(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('getActiveChats error: $e');
    }

    // ── Local Chat Discovery ──
    // Group local messages by contact to simulate active conversations
    final localUserMsgs = _localMessageStorage.where(
      (m) => m['sender_id'] == userId || m['receiver_id'] == userId,
    );
    final Map<int, Map<String, dynamic>> localChatsMap = {};

    for (var m in localUserMsgs) {
      final contactId =
          (m['sender_id'] == userId)
              ? m['receiver_id'] as int
              : m['sender_id'] as int;
      final time = m['created_at'] as String;

      if (!localChatsMap.containsKey(contactId) ||
          time.compareTo(localChatsMap[contactId]!['last_message_at'] as String) > 0) {
        localChatsMap[contactId] = {
          'contact_id': contactId,
          'last_message_at': time,
          'last_message': m['content'], // Store the actual text
        };
      }
    }

    // Merge server chats with local discovery
    final List<Map<String, dynamic>> combined = [...serverChats];
    for (var lc in localChatsMap.values) {
      final existsIdx = combined.indexWhere(
        (sc) => sc['contact_id'] == lc['contact_id'],
      );
      if (existsIdx != -1) {
        // Use whichever is newer
        final st = combined[existsIdx]['last_message_at'].toString();
        final lt = lc['last_message_at'].toString();
        if (lt.compareTo(st) > 0) {
          combined[existsIdx] = lc;
        }
      } else {
        combined.add(lc);
      }
    }

    return combined;
  }

  static Future<List<Map<String, dynamic>>> getMessages(
    int senderId,
    int receiverId,
  ) async {
    List<Map<String, dynamic>> serverMsgs = [];
    try {
      final response = await http
          .get(Uri.parse('$_base/messages/$senderId/$receiverId'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        serverMsgs = List<Map<String, dynamic>>.from(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('getMessages error: $e');
    }

    // Filter local storage for this conversation
    final localMsgs = _localMessageStorage.where((m) {
      final s = m['sender_id'] as int;
      final r = m['receiver_id'] as int;
      return (s == senderId && r == receiverId) ||
          (s == receiverId && r == senderId);
    }).toList();

    // Combine and sort
    final combined = [...serverMsgs, ...localMsgs];
    combined.sort((a, b) {
      final ta = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
          DateTime.now();
      final tb = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
          DateTime.now();
      return ta.compareTo(tb);
    });

    // Simple deduplication based on content and sender in the same minute
    final List<Map<String, dynamic>> deduped = [];
    for (var m in combined) {
      final exists = deduped.any((dm) =>
          dm['content'] == m['content'] &&
          dm['sender_id'] == m['sender_id'] &&
          (DateTime.tryParse(dm['created_at']?.toString() ?? '')
                      ?.difference(DateTime.tryParse(
                          m['created_at']?.toString() ?? '') ??
                      DateTime.now())
                      .inMinutes
                      .abs() ??
                  10) <
              1);
      if (!exists) deduped.add(m);
    }

    return deduped;
  }

  static Future<bool> sendMessage(
    int senderId,
    int receiverId,
    String content,
  ) async {
    // ── Local Persistence ──
    _localMessageStorage.add({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_base/messages'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'sender_id': senderId,
              'receiver_id': receiverId,
              'content': content,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('POST /messages → ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('sendMessage error: $e');
      return false;
    }
  }

  static Future<bool> updateUserName(int userId, String name) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_base/users/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('updateUserName error: $e');
      return false;
    }
  }

  static Future<bool> updateProfilePicture(int userId, String imgUrl) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_base/users/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'img_url': imgUrl}),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('updateProfilePicture error: $e');
      return false;
    }
  }

  static Future<Map<int, String>> getUserNames() async {
    try {
      final response = await http
          .get(Uri.parse('$_base/users'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> userList = json.decode(response.body);
        final Map<int, String> names = {..._localUserNames};
        for (final u in userList) {
          names[u['id'] as int] = u['name'] ?? 'Unknown';
        }
        return names;
      }
    } catch (e) {
      debugPrint('getUserNames error: $e');
    }
    return {..._localUserNames};
  }

  static int checkPotentialMatches() {
    final userId = loggedInUserIdNotifier.value;
    if (userId == null) return 0;

    final items = allItemsNotifier.value;
    final myLostItems = items
        .where((i) => i.userId == userId && i.status == ItemStatus.lost)
        .toList();
    final otherFoundItems = items
        .where((i) => i.userId != userId && i.status == ItemStatus.found)
        .toList();

    int newMatchesCount = 0;

    for (var lost in myLostItems) {
      for (var found in otherFoundItems) {
        // Match logic: same category and similar title
        final sameCategory =
            lost.category.toLowerCase() == found.category.toLowerCase();
        final similarTitle =
            found.title.toLowerCase().contains(lost.title.toLowerCase()) ||
                lost.title.toLowerCase().contains(found.title.toLowerCase());

        if (sameCategory && similarTitle) {
          final title = 'Potential Match: ${found.title}';
          // Check if this specific match notification already exists
          final exists = activityNotifier.value
              .any((a) => a.title == title && a.userId == userId);

          if (!exists) {
            final activity = ActivityItem(
              title: title,
              subtitle:
                  'Someone found an item that might be yours in ${found.location}.',
              type: ActivityType.match,
              timestamp: DateTime.now(),
              isUnread: true,
              userId: userId,
            );
            activityNotifier.value = [activity, ...activityNotifier.value];
            newMatchesCount++;
          }
        }
      }
    }
    return newMatchesCount;
  }
}

// ─────────────────────────────────────────────
// CAMPUS PLACES
// ─────────────────────────────────────────────

final List<String> campusPlaces = [
  "Faculté des Sciences",
  "Faculté des Lettres et des Langues",
  "Faculté des Sciences Humaines et Sociales",
  "Faculté des Sciences Islamiques",
  "Faculté de Droit et des Sciences Politiques",
  "Faculté des Sciences Économiques, Commerciales et des Sciences de Gestion",
  "Faculté de Technologie",
  "Département de Biologie",
  "Département de Chimie",
  "Département de Physique",
  "Département de Mathématiques",
  "Département de Langue Arabe et des Arts",
  "Département de Psychologie",
  "Département de Philosophie",
  "Département d'Histoire",
  "Département de Sociologie",
  "Département de Langue Française",
  "Département de Langue Anglaise",
  "Bibliothèque Centrale",
  "Centre d'Enseignement Intensif des Langues (CEIL)",
  "Fablab Université de Tlemcen",
  "Le Restaurant Universitaire",
  "Administration Centrale",
  "Rectorat",
  "Service de Scolarité",
  "Service des Œuvres Universitaires",
  "Infirmerie Universitaire",
  "Mosquée de l'Université",
  "Salle de Sport",
  "Terrain de Football",
  "Amphithéâtre Principal",
  "Salle de Conférences",
  "Centre de Calcul",
  "Résidence Universitaire Mansourah 4 (Ahmed Mohammed)",
  "Résidence Universitaire Mansourah 5",
  "Résidence Universitaire Mansourah 7 (Ben Ahmed Abdel Kader)",
  "Résidence Universitaire Martyre Maliha Hamidou",
  "Entrée Principale du Campus",
  "Parking Principal",
  "Arrêt de Bus Campus",
  "Allée Centrale du Campus",
];

final List<String> campusZones = campusPlaces;

// ─────────────────────────────────────────────
// OBJECT TYPES
// ─────────────────────────────────────────────

final List<String> objectTypes = [
  "Phone",
  "Laptop",
  "Tablet",
  "Smart Watch",
  "Headphones",
  "Earbuds",
  "AirPods",
  "Charger",
  "Power Bank",
  "USB Flash Drive",
  "External Hard Drive",
  "Calculator",
  "Graphing Calculator",
  "Wallet",
  "Purse",
  "Backpack",
  "Handbag",
  "Student ID Card",
  "National ID Card",
  "Passport",
  "Driver's License",
  "Car Keys",
  "House Keys",
  "Locker Key",
  "Notebook",
  "Binder",
  "Textbook",
  "Lab Manual",
  "Folder",
  "Pen",
  "Pencil Case",
  "Glasses",
  "Sunglasses",
  "Water Bottle",
  "Lunch Box",
  "Jacket",
  "Sweater",
  "Hoodie",
  "Scarf",
  "Umbrella",
  "USB Cable",
  "Mouse",
  "Keyboard",
  "Scientific Instrument",
  "Lab Coat",
  "Access Card",
  "Sports Equipment",
  "Football",
  "Gym Bag",
  "Bluetooth Speaker",
  "Camera",
  "Microphone",
  "Tripod",
  "Project Report",
  "Presentation Clicker",
  "Diary",
  "Makeup Bag",
  "Medication",
];

final List<String> departements = [
  "Département de Biologie",
  "Département de Langue Arabe et des Arts",
  "Département de Psychologie",
  "Département de Philosophie",
  "Département d'Histoire",
  "Département de Chimie",
  "Département de Physique",
  "Département de Mathématiques",
  "Département de Sociologie",
  "Département de Langue Française",
  "Département de Langue Anglaise",
  "Département d'Informatique",
];
final ValueNotifier<String> loggedInImgUrlNotifier = ValueNotifier<String>('');
