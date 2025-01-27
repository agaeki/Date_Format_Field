import 'package:date_format_field/src/formater.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

/// [DateFormatType] enum specifies the formatting option for the date format
/// field.
///
/// Example:
///
/// The date -> 2nd November 2022 is displayed in the different types as:
///
/// [type1] => 02/11/22
/// [type2] => 02/11/2022
/// [type3] => 02-11-22
/// [type4] => 02-11-2022

enum DateFormatType {
  type1, // 12/02/22
  type2, // 12/02/2022
  type3, // 12-02-22
  type4, // 12-02-2022
  typeFormatString // Formatted using https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
}

/// Base class for [DateFormatField]
///
/// [DateFormatField] automatically adds separators to a custom datefield.
/// Specify the type of separators using the [DateFormatType] enumerators
///
/// Required inputs are:
///
/// [type] -> specifies the type of formatting option
///
/// [onComplete] -> function providing a nullable [DateTime] object of your
/// selected date. The [onComplete] DateTime parameter remains null until the
/// [DateFormatField] has been filled as required by the [DateFormatType] then
/// it returns a [DateTime] object based on your input.
///
/// Optional Inputs:
///
/// [addCalendar] -> sets the calendar icon on the [DateFormatField] which
/// can be used to select date using a date selection modal screen. The default
/// value is [true]
///
/// [decoration] -> this is the input for styling the [DateFormatField] this
/// is the same as the [InputDecoration] class for flutter default [TextFields]
/// so all styling on TextField applies same here.

class DateFormatField extends StatefulWidget {
  const DateFormatField({
    super.key,
    required this.onComplete,
    required this.type,
    this.formatString,
    this.addCalendar = true,
    this.decoration,
    this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.focusNode,
  });

  /// [InputDecoration] a styling class for form field
  ///
  /// This is the default flutter Input decoration used to style input fields
  final InputDecoration? decoration;

  /// [DateFormatType] is an enum for specifying the type
  final DateFormatType type;

  /// [formatString] is the string that will be used to format the date/time
  /// See https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html for
  /// list of accepted characters.
  final String? formatString;

  /// [onComplete] returns a nullable DateTime object
  ///
  /// Returns null when the datetime field is not complete
  /// Returns a DateTime object when the field has been completed
  final Function(DateTime?) onComplete;

  /// [addCalendar] sets a button that allows the selection of date from a
  /// calendar pop up
  final bool addCalendar;

  /// [initialDate] set init day before show datetime picker
  final DateTime? initialDate;

  /// [lastDate] set last date show in datetime picker
  final DateTime? lastDate;

  /// [firstDate] set first date show in date time picker
  /// the default value is 1000-0-0
  final DateTime? firstDate;

  /// [focusNode] set focusNode for DateFormatField
  /// the default value is 3000-0-0
  final FocusNode? focusNode;

  /// TextEditingController for the date format field
  /// This is used to control the input text
  final TextEditingController? controller;
  @override
  State<DateFormatField> createState() => _DateFormatFieldState();
}

class _DateFormatFieldState extends State<DateFormatField> {
  late final TextEditingController _dobFormater;
  late DateTime initialDate;

  @override
  void initState() {
    _dobFormater = widget.controller ?? TextEditingController();
    initialDate = widget.initialDate ?? DateTime.now();
    super.initState();
  }

  InputDecoration? decoration() {
    if (!widget.addCalendar) return widget.decoration;

    // Only add a time picker icon if the format string is used and contains
    // at least one of the time-related format characters
    final bool pickTimeIcon = widget.type == DateFormatType.typeFormatString &&
        (widget.formatString == null
            || widget.formatString!.contains(RegExp(r'[Hjms]')));
    if (widget.decoration == null) {
      return InputDecoration(
          suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: pickDate,
                  icon: const Icon(Icons.calendar_month),
                )
              ] + (pickTimeIcon ? [
                IconButton(
                    onPressed: pickTime,
                    icon: const Icon(Icons.access_time))
              ]
                  : [])
          )
      );
    }

    return widget.decoration!.copyWith(
        suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: pickDate,
                icon: const Icon(Icons.calendar_month),
              )
            ] + (pickTimeIcon ? [
              IconButton(
                  onPressed: pickTime,
                  icon: const Icon(Icons.access_time))
            ]
                : []))
    );
  }

  void formatInput(String value) {
    /// formatter for the text input field
    DateTime? completeDate;
    switch (widget.type) {
      case DateFormatType.type1:
        completeDate = Formater.type1(value, _dobFormater);
        break;
      case DateFormatType.type2:
        completeDate = Formater.type2(value, _dobFormater);
        break;
      case DateFormatType.type3:
        completeDate = Formater.type3(value, _dobFormater);
        break;
      case DateFormatType.type4:
        completeDate = Formater.type4(value, _dobFormater);
        break;
      case DateFormatType.typeFormatString:
        completeDate = Formater.typeFormatString(value, widget.formatString!, _dobFormater);
        break;
      default:
    }
    setState(() {
      // Do some mangling to ensure we combine the chosen date and time
      final chosenTime = TimeOfDay.fromDateTime(completeDate ?? DateTime.now());
      final newDate = completeDate ?? DateTime.now();
      initialDate = DateTime(newDate.year, newDate.month, newDate.day, chosenTime.hour, chosenTime.minute);

      // update the datetime
      widget.onComplete(initialDate);
    });
  }

  Future<void> pickDate() async {
    /// pick the date directly from the screen
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.firstDate ?? DateTime(1000),
      lastDate: widget.lastDate ?? DateTime(3000),
    );
    if (picked != null) {
      // Do some mangling to ensure we store the correct date and time
      final chosenTime = TimeOfDay.fromDateTime(initialDate);
      initialDate = DateTime(picked.year, picked.month, picked.day, chosenTime.hour, chosenTime.minute);

      String inputText;
      switch (widget.type) {
        case DateFormatType.type1:
          inputText =
              '${padDayMonth(picked.day)}/${padDayMonth(picked.month)}/${picked.year % 100}';
          break;
        case DateFormatType.type2:
          inputText =
              '${padDayMonth(picked.day)}/${padDayMonth(picked.month)}/${picked.year}';
          break;
        case DateFormatType.type3:
          inputText =
              '${padDayMonth(picked.day)}-${padDayMonth(picked.month)}-${picked.year % 100}';
          break;
        case DateFormatType.type4:
          inputText =
              '${padDayMonth(picked.day)}-${padDayMonth(picked.month)}-${picked.year}';
          break;
        case DateFormatType.typeFormatString:
          inputText = DateFormat(widget.formatString).format(initialDate);
          break;
        default:
          inputText = '';
      }
      setState(() {
        _dobFormater.text = inputText;
      });
      widget.onComplete(initialDate);
    }
  }

  Future<void> pickTime() async {
    /// pick the time directly from the screen
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (picked != null) {
      initialDate = DateTime(initialDate.year, initialDate.month, initialDate.day, picked.hour, picked.minute);

      String inputText;
      switch (widget.type) {
        case DateFormatType.typeFormatString:
          inputText = DateFormat(widget.formatString).format(initialDate);
          break;
        default:
          inputText = '';
      }
      setState(() {
        _dobFormater.text = inputText;
      });

      widget.onComplete(initialDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dobFormater,
      onTap: () {
        _dobFormater.selection = TextSelection.fromPosition(
          TextPosition(offset: _dobFormater.text.length),
        );
      },
      focusNode: widget.focusNode,
      decoration: decoration(),
      keyboardType: TextInputType.datetime,
      onChanged: formatInput,
    );
  }

  String padDayMonth(int value) => value.toString().padLeft(2, '0');
}
