import 'package:flutter/material.dart';
import 'package:devchat/services/presence_service.dart';

class PresenceIndicator extends StatelessWidget {
  final String? status;
  final double size;
  final bool showBorder;

  const PresenceIndicator({
    super.key,
    this.status,
    this.size = 12,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = PresenceService.getStatusColor(status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class LastSeenText extends StatelessWidget {
  final DateTime? lastSeen;
  final String? status;
  final TextStyle? style;

  const LastSeenText({
    super.key,
    this.lastSeen,
    this.status,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final text = PresenceService.getLastSeenText(lastSeen, status);
    final color = status == 'online' ? Colors.green : Colors.grey[600];

    return Text(
      text,
      style: style ??
          TextStyle(
            fontSize: 12,
            color: color,
          ),
    );
  }
}

class UserPresenceAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final String? status;
  final double radius;

  const UserPresenceAvatar({
    super.key,
    this.avatarUrl,
    required this.initials,
    this.status,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Text(
                  initials,
                  style: TextStyle(
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        if (status != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: PresenceIndicator(
              status: status,
              size: radius * 0.35,
            ),
          ),
      ],
    );
  }
}
