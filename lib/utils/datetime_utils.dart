import 'package:intl/intl.dart';

class DateTimeUtils {
  static final dateFormat = DateFormat('d MMM, y');

  static String minuteToHHMM(int totalMinutes, {bool? showHourAndMinute}) {
    final hh = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final mm = (totalMinutes % 60).toString().padLeft(2, '0');

    final showHourAndMinutePostText = showHourAndMinute ?? true;
    return "$hh:$mm ${showHourAndMinutePostText ? "hh:mm" : ""}";
  }

  static String convertMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours hour${hours > 1 ? 's' : ''}'
          '${remainingMinutes > 0 ? ' $remainingMinutes min${remainingMinutes > 1 ? 's' : ''}' : ''}';
    } else {
      return '$minutes min${minutes > 1 ? 's' : ''}';
    }
  }
}
