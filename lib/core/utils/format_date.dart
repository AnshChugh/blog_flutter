import 'package:intl/intl.dart';

String formatDateBydMMMYY(DateTime date) {
  return DateFormat("d MMM, yyyy").format(date);
}
