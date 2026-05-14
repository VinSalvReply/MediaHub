import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/features/users/models/event.dart';

extension EventMapper on EventDto {
  Event toModel() {
    return Event(id: id, title: title, date: DateTime.parse(date));
  }
}
