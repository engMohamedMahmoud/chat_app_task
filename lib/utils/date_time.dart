import 'package:intl/intl.dart';

class MyDateTime{

  static String dateTimeFormat(String time){
    String t = '';
    t = DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(int.parse(time)));
    return t;
  }


  static DateTime dateFormat(String time){
    var dt = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return DateTime(dt.year, dt.month, dt.year);
  }

  static String dateTimeFunc(String time){
    String day = '';
    var dt = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    var today = DateTime.now();
    var yesterday = DateTime.now().add(const Duration(days: -1));

    final t = DateTime(today.year, today.month, today.day);
    final y = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final d = DateTime(dt.year, dt.month, dt.day);

    if(d == t){
      day=  DateFormat.jm().format(dt).toString();
    }else if(d == y){
      day = 'Yesterday';
    }else if(dt.year == today.year){
      day=  DateFormat.MMMd().format(dt).toString();
    }
    else{
     day=  DateFormat.yMMMd().format(dt).toString();
    }

    return day;
  }

}