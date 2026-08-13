import 'package:mediahub/data/dtos/content_item_dto.dart';
import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/data/mappers/content_item_mapper.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';

extension EventMapper on EventDto {
  Event toModel() {
    return Event(
      id: id,
      title: title,
      date: DateTime.parse(date),
      attendees: attendees,
      status: eventStatusFromString(status),
      userId: userId,
      contents: contents.map((ContentItemDto item) => item.toModel()).toList(),
    );
  }
}

extension EventRequestMapper on Event {
  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'date': date.toIso8601String(),
    'attendees': attendees,
    'status': status.name,
    'user_id': userId,
    'contents': contents
        .map((ContentItem content) => content.toJson())
        .toList(),
  };
}
