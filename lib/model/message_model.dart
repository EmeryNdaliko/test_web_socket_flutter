class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String? image;
  final DateTime timestamp;

  MessageModel.build({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.image,
    required this.timestamp,
  });

  // Conversion depuis JSON (depuis API)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel.build(
      id: int.parse(json['id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      receiverId: int.parse(json['receiver_id'].toString()),
      message: json['message'] ?? '',
      image: json['image'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Conversion vers JSON (pour envoi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
