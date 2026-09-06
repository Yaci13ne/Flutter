import 'package:flutter/material.dart';
import 'package:twedrli/Widgets/page_shell.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final updates = [
      {
        'version': 'v2.4.0',
        'title': 'AI Match Engine',
        'desc':
            'Smarter item matching using image recognition and keyword analysis.',
        'date': '5d ago',
        'isLatest': true,
      },
      {
        'version': 'v2.3.2',
        'title': 'Bug Fixes & Performance',
        'desc':
            'Resolved crash on image upload and improved feed load time by 40%.',
        'date': '2w ago',
        'isLatest': false,
      },
      {
        'version': 'v2.3.0',
        'title': 'Campus Map Integration',
        'desc':
            'Pin lost items directly on your campus map for faster recovery.',
        'date': '1mo ago',
        'isLatest': false,
      },
      {
        'version': 'v2.2.0',
        'title': 'Dark Mode Support',
        'desc':
            'Full dark mode available across all screens. Toggle in Settings.',
        'date': '2mo ago',
        'isLatest': false,
      },
    ];

    return PageShell(
      title: 'Updates',
      accentColor: const Color(0xFF5A7AFF),
      icon: Icons.update_rounded,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: updates.length,
        itemBuilder: (context, index) {
          final u = updates[index];
          final isLatest = u['isLatest'] as bool;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isLatest
                          ? const Color(0xFF5A7AFF)
                          : const Color(0xFF5A7AFF).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: isLatest ? Colors.white : const Color(0xFF5A7AFF),
                    ),
                  ),
                  if (index < updates.length - 1)
                    Container(
                      width: 2,
                      height: 72,
                      color: const Color(0xFF5A7AFF).withOpacity(0.15),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isLatest
                          ? Border.all(
                              color: const Color(0xFF5A7AFF).withOpacity(0.4),
                              width: 1.5,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5A7AFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                u['version'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF5A7AFF),
                                ),
                              ),
                            ),
                            if (isLatest) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00BFAE,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Latest',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF00BFAE),
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              u['date'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB0B4C8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          u['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          u['desc'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7B8099),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
