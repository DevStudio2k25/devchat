import 'package:flutter/material.dart';

class ImageGridWidget extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback? onTap;

  const ImageGridWidget({
    super.key,
    required this.imageUrls,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageCount = imageUrls.length;

    if (imageCount == 1) {
      // Single image
      return _buildSingleImage(imageUrls[0]);
    } else if (imageCount == 2) {
      // 2 images side by side
      return _buildTwoImages();
    } else if (imageCount == 3) {
      // 3 images: 1 large + 2 small
      return _buildThreeImages();
    } else {
      // 4+ images: 2x2 grid with "+N" overlay on 4th
      return _buildFourPlusImages();
    }
  }

  Widget _buildSingleImage(String url) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTwoImages() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGridImage(imageUrls[0], 95, 180),
        const SizedBox(width: 4),
        _buildGridImage(imageUrls[1], 95, 180),
      ],
    );
  }

  Widget _buildThreeImages() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGridImage(imageUrls[0], 130, 180),
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGridImage(imageUrls[1], 60, 88),
            const SizedBox(height: 4),
            _buildGridImage(imageUrls[2], 60, 88),
          ],
        ),
      ],
    );
  }

  Widget _buildFourPlusImages() {
    if (imageUrls.length < 4) return _buildSingleImage(imageUrls[0]);
    final remaining = imageUrls.length - 4;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGridImage(imageUrls[0], 95, 95),
            const SizedBox(width: 4),
            _buildGridImage(imageUrls[1], 95, 95),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGridImage(imageUrls[2], 95, 95),
            const SizedBox(width: 4),
            // 4th image with overlay
            Stack(
              children: [
                _buildGridImage(imageUrls[3], 95, 95),
                if (remaining > 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+$remaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridImage(String url, double width, double height) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 24),
            );
          },
        ),
      ),
    );
  }
}
