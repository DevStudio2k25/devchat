import 'package:flutter/material.dart';

class AttachmentBottomSheet extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onVideoTap;
  final VoidCallback onDocumentTap;
  final VoidCallback onAudioTap;

  const AttachmentBottomSheet({
    super.key,
    required this.onGalleryTap,
    required this.onVideoTap,
    required this.onDocumentTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Share Content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // First row - Media
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachmentOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: const Color(0xFF667eea),
                onTap: onGalleryTap,
              ),
              _AttachmentOption(
                icon: Icons.videocam_rounded,
                label: 'Video',
                color: const Color(0xFFEC4899),
                onTap: onVideoTap,
              ),
              _AttachmentOption(
                icon: Icons.insert_drive_file_rounded,
                label: 'Document',
                color: const Color(0xFF10B981),
                onTap: onDocumentTap,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Second row - Audio only
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AttachmentOption(
                icon: Icons.headphones_rounded,
                label: 'Audio',
                color: const Color(0xFFF59E0B),
                onTap: onAudioTap,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with gradient
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
