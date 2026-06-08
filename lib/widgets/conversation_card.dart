import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/baby_profile.dart';
import '../models/conversation.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conv;
  final BabyProfile? profile;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ConversationCard({
    super.key,
    required this.conv,
    required this.profile,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final preview = conv.turns.take(3).toList();
    final hasMore = conv.turns.length > 3;
    final dateText = DateFormat('MM.dd').format(conv.occurredAt);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conv.background != null && conv.background!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.place_outlined,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      conv.background!,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            ...preview.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: '${t.emoji} '),
                        TextSpan(
                          text: '${t.role}：',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: t.content),
                      ],
                    ),
                  ),
                )),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '… 还有 ${conv.turns.length - 3} 句',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (conv.babyAgeSnapshot.isNotEmpty && profile != null)
                  Text(
                    '${profile!.name} ${conv.babyAgeSnapshot}',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                const Spacer(),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
