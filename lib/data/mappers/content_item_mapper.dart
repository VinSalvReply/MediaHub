import 'package:mediahub/data/dtos/content_item_dto.dart';
import 'package:mediahub/features/users/models/content_item.dart';

extension ContentItemMapper on ContentItemDto {
  ContentItem toModel() {
    return ContentItem(
      id: id,
      title: title,
      type: type,
      status: status,
      createdAt: DateTime.parse(createdAt),
      userId: userId,
      eventId: eventId,
      mediaUrls: mediaUrls,
      postBody: postBody,
      callToActionLabel: callToActionLabel,
      callToActionUrl: callToActionUrl,
      tags: tags,
    );
  }
}

extension ContentItemRequestMapper on ContentItem {
  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'type': type,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'user_id': userId,
    'event_id': eventId,
    'media_urls': mediaUrls,
    'post_body': postBody,
    'cta_label': callToActionLabel,
    'cta_url': callToActionUrl,
    'tags': tags,
  };
}
