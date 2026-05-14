import 'package:mediahub/data/dtos/content_item_dto.dart';
import 'package:mediahub/features/users/models/content_item.dart';

extension ContentItemMapper on ContentItemDto {
  ContentItem toModel() {
    return ContentItem(
      id: id,
      title: title,
      type: type,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
