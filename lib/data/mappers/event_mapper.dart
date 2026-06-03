import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/data/mappers/content_item_mapper.dart';
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
      contents: contents.map((item) => item.toModel()).toList(),
    );
  }
}
