/// Payload written to the Firestore [notifications] collection.
///
/// The web frontend listens to this collection and displays each notification
/// in a ticker. It marks [status] as "read" after the display time expires.
class NotificationPayload {
  const NotificationPayload({
    required this.id,
    required this.text,
    required this.timestamp,
    this.status = 'pending',
    // manual | fine | streak | moab | zone
    this.type = 'manual',
    this.imageUrl,
    this.targetPlayerId,
  });

  final String id;
  final String text;
  final DateTime timestamp;
  final String status;
  final String type;
  final String? imageUrl;
  final String? targetPlayerId;
}
