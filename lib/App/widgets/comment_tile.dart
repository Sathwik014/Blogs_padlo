import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blogs_pado/App/models/comment_model.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool canDelete;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    required this.canDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.commenterPhotoUrl.isNotEmpty
                ? CachedNetworkImageProvider(comment.commenterPhotoUrl)
                : null,
          ),
          const SizedBox(width: 10),

          // Name + comment + metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + comment
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${comment.commenterName} ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: comment.content,
                        style: const TextStyle(color:Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Timestamp, likes, reply (optional dummy info)
                Row(
                  children: [
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Reply',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete / Like icon
          canDelete
              ? IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
              : IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays >= 7) return '${diff.inDays ~/ 7}w';
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'Just now';
  }
}
