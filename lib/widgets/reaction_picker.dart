import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;

  const ReactionPicker({
    super.key,
    required this.onEmojiSelected,
  });

  static const List<String> popularEmojis = [
    '👍', '❤️', '😂', '😮', '😢', '🙏',
    '🎉', '🔥', '👏', '✨', '💯', '🚀',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'React to message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Emoji Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: popularEmojis.length,
            itemBuilder: (context, index) {
              return _buildEmojiButton(popularEmojis[index]);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onEmojiSelected(emoji),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea).withOpacity(0.1),
                const Color(0xFF764ba2).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class ReactionDisplay extends StatelessWidget {
  final Map<String, List<String>> reactions;
  final String? currentUserId;
  final Function(String emoji) onReactionTap;

  const ReactionDisplay({
    super.key,
    required this.reactions,
    this.currentUserId,
    required this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: reactions.entries.map((entry) {
        final emoji = entry.key;
        final userIds = entry.value;
        final count = userIds.length;
        final hasReacted = currentUserId != null && userIds.contains(currentUserId);

        return _buildReactionChip(
          emoji: emoji,
          count: count,
          hasReacted: hasReacted,
          onTap: () => onReactionTap(emoji),
        );
      }).toList(),
    );
  }

  Widget _buildReactionChip({
    required String emoji,
    required int count,
    required bool hasReacted,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: hasReacted
                ? const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  )
                : null,
            color: hasReacted ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: hasReacted
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: hasReacted
                ? [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: hasReacted ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReactionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ReactionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea).withOpacity(0.1),
                const Color(0xFF764ba2).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF667eea).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_reaction_outlined,
                size: 16,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                'React',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
