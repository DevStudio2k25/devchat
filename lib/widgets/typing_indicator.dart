import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final List<String> typingUsers;

  const TypingIndicator({
    super.key,
    required this.typingUsers,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getTypingText(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = (_controller.value - delay).clamp(0.0, 1.0);
        final scale = 0.5 + (0.5 * (1 - (value - 0.5).abs() * 2));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _getTypingText() {
    if (widget.typingUsers.length == 1) {
      return '${widget.typingUsers[0]} is typing...';
    } else if (widget.typingUsers.length == 2) {
      return '${widget.typingUsers[0]} and ${widget.typingUsers[1]} are typing...';
    } else {
      return '${widget.typingUsers.length} people are typing...';
    }
  }
}

class ReadReceipt extends StatelessWidget {
  final bool isRead;
  final bool isSent;
  final bool isDelivered;

  const ReadReceipt({
    super.key,
    this.isRead = false,
    this.isSent = false,
    this.isDelivered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIcon(),
      size: 16,
      color: isRead ? const Color(0xFF667eea) : Colors.grey[400],
    );
  }

  IconData _getIcon() {
    if (isRead) {
      return Icons.done_all;
    } else if (isDelivered) {
      return Icons.done_all;
    } else if (isSent) {
      return Icons.done;
    } else {
      return Icons.schedule;
    }
  }
}
