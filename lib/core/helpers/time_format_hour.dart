import 'package:intl/intl.dart';

class TimeFormatHour {
  TimeFormatHour._();

  static String formatTime12(dynamic time24) {
    try {
      if (time24.runtimeType == DateTime) {
        return DateFormat('h:mm a', 'ar').format(time24);
      } else {
        final date = DateFormat("HH:mm").parse(time24);
        return DateFormat('h:mm a', 'ar').format(date);
      }
      // نفترض أن الوقت يأتي بتنسيق "14:00"
    } catch (e) {
      return time24;
    }
  }

  static String formatDate(dynamic selectedDate) {
    return DateFormat('EEEE، d MMMM', 'ar').format(selectedDate);
  }
}
