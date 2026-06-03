class ContentItem {
  final int id;
  final String title;
  final String type;
  final String status;
  final DateTime createdAt;
  final int? userId;
  final int? eventId;
  final List<String> mediaUrls;
  final String? postBody;
  final String? callToActionLabel;
  final String? callToActionUrl;
  final List<String> tags;

  ContentItem({
    required this.id,
    required this.title,
    required this.type,
    this.status = 'draft',
    required this.createdAt,
    this.userId,
    this.eventId,
    this.mediaUrls = const [],
    this.postBody,
    this.callToActionLabel,
    this.callToActionUrl,
    this.tags = const [],
  });
}
