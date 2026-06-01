class ContentItem {
  final int id;
  final String title;
  final String type;
  final String status;
  final DateTime createdAt;
  final int? userId;
  final int? eventId;

  ContentItem({
    required this.id,
    required this.title,
    required this.type,
    this.status = 'draft',
    required this.createdAt,
    this.userId,
    this.eventId,
  });
}
