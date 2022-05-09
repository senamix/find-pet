import 'package:intl/intl.dart';

class ConvertDate{

  ///yyyy-MM-dd'T'HH:mm:ss.SSS'Z' -> local DateTime
  static DateTime convertUtcStringToLocal(String dateString){
    DateTime utc = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(dateString, true); //utc format
    DateTime local = utc.toLocal(); //change to local datetime
    return local;
  }

  ///utc isoString -> yyyy-MM-dd HH:mm a
  ///datetime at API return a urc isoString
  static String convertUtcStringToLocalString(String dateString){
    DateTime local =convertUtcStringToLocal(dateString);
    String parseLocal = DateFormat("yyyy-MM-dd HH:mm a").format(local);
    return parseLocal;
  }

  static String convertUtcStringToLocalSimpleString(String dateString){
    DateTime local = convertUtcStringToLocal(dateString);
    String parseLocal = DateFormat("yyyy-MM-dd").format(local);
    return parseLocal;
  }

  ///datetime -> utc isoString
  static String convertDateTimeToIsoString(DateTime dateTime){
    DateTime date = dateTime.toUtc(); //convert to utc
    return date.toIso8601String(); //convert to ISOString ***Z
  }

  static String formatStringByPattern(String pattern, DateTime dateTime){
    final DateFormat formatter = DateFormat(pattern);
    final String formatted = formatter.format(dateTime);
    return formatted;
  }

  static String convertStringToLocalString(String dateString){
    DateTime datetime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(dateString, true); //utc format
    String parseLocal = DateFormat("yyyy-MM-dd HH:mm a").format(datetime);
    return parseLocal;
  }
}