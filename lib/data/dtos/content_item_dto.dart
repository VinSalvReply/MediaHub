class ContentItemDto {
  final int id;
  final String title;
  final String type;
  final String status;
  final String createdAt;
  final int? userId;
  final int? eventId;
  final List<String> mediaUrls;
  final String? postBody;
  final String? callToActionLabel;
  final String? callToActionUrl;
  final List<String> tags;

  ContentItemDto({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.eventId,
    required this.mediaUrls,
    required this.postBody,
    required this.callToActionLabel,
    required this.callToActionUrl,
    required this.tags,
  });

  factory ContentItemDto.fromJson(Map<String, dynamic> json) {
    final int fallbackId = Object.hash(
      json['title'],
      json['created_at'],
      json['type'],
    ).abs();

    return ContentItemDto(
      id: (json['id'] as num?)?.toInt() ?? fallbackId,
      title: (json['title'] as String?) ?? 'Contenuto senza titolo',
      type: (json['type'] as String?) ?? 'post',
      status: (json['status'] as String?) ?? 'draft',
      createdAt:
          (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      userId: (json['user_id'] as num?)?.toInt(),
      eventId: (json['event_id'] as num?)?.toInt(),
      mediaUrls:
          ((json['media_urls'] as List<dynamic>?) ??
                  ((json['attachment_url'] as String?)?.isNotEmpty ?? false
                      ? <dynamic>[json['attachment_url']]
                      : const <dynamic>[]))
              .whereType<String>()
              .map((String url) => url.trim())
              .where((String url) => url.isNotEmpty)
              .toList(),
      postBody: json['post_body'] as String?,
      callToActionLabel: json['cta_label'] as String?,
      callToActionUrl: json['cta_url'] as String?,
      tags: ((json['tags'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<String>()
          .map((String tag) => tag.trim())
          .where((String tag) => tag.isNotEmpty)
          .toList(),
    );
  }
}
