class MessageDb {
  late String sender;
  late String receiver;
  late String message;
  late String timestamp;

  MessageDb({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
  });

  factory MessageDb.fromMap(Map<dynamic, dynamic> map) {
    return MessageDb(
      sender: map['sender'] ?? '',
      receiver: map['receiver'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}