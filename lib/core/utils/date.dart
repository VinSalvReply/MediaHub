import 'package:intl/intl.dart';

String formatDate(DateTime? date, {String format = "dd-MM-yyyy HH:mm"}) {
  if (date != null) {
    return DateFormat(format).format(date);
  } else {
    return '';
  }
}
