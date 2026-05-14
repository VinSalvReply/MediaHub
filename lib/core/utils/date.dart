import 'package:intl/intl.dart';

String formatDate(DateTime date, {String format = "dd-MM-yyyy HH:mm"}) {
  return DateFormat(format).format(date);
}
