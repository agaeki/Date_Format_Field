import 'package:flutter/material.dart';

class Formater {
  static int _parseInt(String input) {
    return int.parse(input);
  }

  static DateTime _parseDateTimeShort(String input) {
    int day = int.parse(input.substring(0, 2));
    int month = int.parse(input.substring(3, 5));
    int year = int.parse(input.substring(6, 8));
    return DateTime(year + 2000, month, day);
  }

  static DateTime _parseDateTimeLong(String input) {
    int day = int.parse(input.substring(0, 2));
    int month = int.parse(input.substring(3, 5));
    int year = int.parse(input.substring(6, 10));
    return DateTime(year, month, day);
  }

  static void _typeTemplate(String input, TextEditingController controller,
      String separator, int lastIndex) {
    switch (input.length) {
      case 1:
        if (_parseInt(input) > 3) {
          controller.text = '0$input$separator';
        }
        break;
      case 2:
        if (_parseInt(input) > 31) {
          controller.text = input[0];
        }
        break;
      case 3:
        if (input[2] != separator) {
          controller.text = int.parse(input[2]) <= 1
              ? '${input.substring(0, 2)}$separator${input[2]}'
              : '${input.substring(0, 2)}${separator}0${input[2]}$separator';
        }
        break;
      case 4:
        break;
      case 5:
        if (_parseInt(input.substring(3, 5)) > 12) {
          controller.text = input.substring(0, 4);
          break;
        }
        break;
      case 6:
        if (input[5] != separator) {
          controller.text = '${input.substring(0, 5)}$separator${input[5]}';
        }
        break;
      default:
        if (input.length == lastIndex) {
          controller.text = input.substring(0, lastIndex - 1);
        }
    }
    // move to the end of textfield
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  static DateTime? type1(String input, TextEditingController controller) {
    int maxLength = 9;
    _typeTemplate(input, controller, '/', maxLength);
    if (input.length >= maxLength - 1) {
      return _parseDateTimeShort(input);
    }
    return null;
  }

  static DateTime? type2(String input, TextEditingController controller) {
    int maxLength = 11;
    _typeTemplate(input, controller, '/', maxLength);
    if (input.length >= maxLength - 1) {
      return _parseDateTimeLong(input);
    }
    return null;
  }

  static DateTime? type3(String input, TextEditingController controller) {
    int maxLength = 9;
    _typeTemplate(input, controller, '-', maxLength);
    if (input.length >= maxLength - 1) {
      return _parseDateTimeShort(input);
    }
    return null;
  }

  static DateTime? type4(String input, TextEditingController controller) {
    int maxLength = 11;
    _typeTemplate(input, controller, '-', maxLength);
    if (input.length >= maxLength - 1) {
      return _parseDateTimeLong(input);
    }
    return null;
  }
}
