class CommentModel {
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String commenterPhotoUrl;
  final String content;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.commenterPhotoUrl,
    required this.content,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'],
      commenterId: map['commenterId'],
      commenterName: map['commenterName'],
      commenterPhotoUrl: map['commenterPhotoUrl'] ?? '',
      content: map['content'],
      timestamp: map['timestamp'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'commenterId': commenterId,
      'commenterName': commenterName,
      'commenterPhotoUrl': commenterPhotoUrl,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
