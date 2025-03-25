import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/Course.dart';
import 'package:flutter_application_2/models/User.dart';
import 'package:flutter_application_2/services/api_services.dart';

// Define the primary theme color for the application
const Color primaryColor = Color.fromARGB(255, 37, 37, 213);

/**
 * JalaliDate Class
 * 
 * A simple implementation of the Persian (Jalali) calendar system.
 * Provides functionality for date conversion, comparison, and formatting.
 */
class JalaliDate {
  final int year;
  final int month;
  final int day;

  JalaliDate(this.year, this.month, this.day);

  @override
  String toString() {
    return '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  }

  /**
   * Converts a Gregorian DateTime to Jalali date
   * 
   * This is an approximate conversion that works for most practical purposes.
   * For exact conversion, a more complex algorithm would be needed.
   * 
   * @param dateTime The Gregorian DateTime to convert
   * @return A JalaliDate object representing the equivalent date in Jalali calendar
   */
  static JalaliDate fromDateTime(DateTime dateTime) {
    // Approximate difference between Gregorian and Jalali calendars
    int jalaliYear = dateTime.year - 621;
    int jalaliMonth = dateTime.month;
    int jalaliDay = dateTime.day;

    // Adjust for Farvardin which corresponds to March
    if (dateTime.month < 3 || (dateTime.month == 3 && dateTime.day < 21)) {
      jalaliYear--;
      jalaliMonth = dateTime.month + 9;
    } else {
      jalaliMonth = dateTime.month - 3;
    }

    // Adjust day of month (approximate)
    if (dateTime.month == 3 && dateTime.day > 20) {
      jalaliDay = dateTime.day - 20;
    } else if (dateTime.month > 3) {
      jalaliDay = dateTime.day;
    }

    // Fix month (Jalali months are from 1 to 12)
    if (jalaliMonth <= 0) {
      jalaliMonth += 12;
    }

    return JalaliDate(jalaliYear, jalaliMonth, jalaliDay);
  }

  /**
   * Compares two Jalali dates
   * 
   * @param other The JalaliDate to compare with
   * @return Negative if this date is earlier, positive if later, zero if equal
   */
  int compareTo(JalaliDate other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    return day.compareTo(other.day);
  }

  /**
   * Gets the Persian name of a month
   * 
   * @param month The month number (1-12)
   * @return The Persian name of the month
   */
  static String getMonthName(int month) {
    final List<String> monthNames = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];

    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
  }

  /**
   * Formats the date as a human-readable string
   * 
   * @return A string in the format "day MonthName year"
   */
  String toFormattedString() {
    return '$day ${getMonthName(month)} $year';
  }

  /**
   * Converts a JalaliDate to Gregorian DateTime (approximate)
   * 
   * This is used for comparison purposes and is an approximate conversion.
   * 
   * @return A DateTime object representing the approximate Gregorian date
   */
  DateTime toDateTime() {
    int gregorianYear = year + 621;
    int gregorianMonth = month + 3;
    int gregorianDay = day;

    if (gregorianMonth > 12) {
      gregorianYear++;
      gregorianMonth -= 12;
    }

    return DateTime(gregorianYear, gregorianMonth, gregorianDay);
  }
}

/**
 * ScheduleEntry Class
 * 
 * Represents a single entry in the term schedule.
 * Contains all the information about a course session.
 */
class ScheduleEntry {
  final String day;
  final String date;
  final JalaliDate jalaliDate;
  final String time;
  final String courseCode;
  final String courseGroup;
  final String courseName;
  final String classroom;

  ScheduleEntry({
    required this.day,
    required this.date,
    required this.time,
    required this.courseCode,
    required this.courseGroup,
    required this.courseName,
    required this.classroom,
  }) : jalaliDate = _parseDate(date);

  /**
   * Parses a date string in the format "yyyy/mm/dd" to a JalaliDate object
   * 
   * @param date The date string to parse
   * @return A JalaliDate object
   */
  static JalaliDate _parseDate(String date) {
    try {
      List<String> parts = date.split('/');
      if (parts.length == 3) {
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2]);
        return JalaliDate(year, month, day);
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
    }
    return JalaliDate(1402, 1, 1); // Default date if parsing fails
  }
}

/**
 * SchedulePage Widget
 * 
 * The main widget for displaying and filtering the term schedule.
 * Provides a comprehensive UI for viewing and filtering course schedules.
 */
class SchedulePage extends StatefulWidget {
  final User user;
  const SchedulePage({Key? key, required this.user}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Filter state variables
  JalaliDate? startDate;
  JalaliDate? endDate;
  String? selectedDay;
  String? selectedTime;
  String searchQuery = '';

  // Text controller for search field
  final TextEditingController _searchController = TextEditingController();

  // Data collections
  late List<ScheduleEntry> allEntries;
  late List<ScheduleEntry> filteredEntries;

  // Filter options
  late List<String> dayOptions;
  late List<String> timeOptions;

  @override
  void initState() {
    fetchScheduleFromApi();
    super.initState();

    // Initialize sample data for the schedule
    allEntries = [
      ScheduleEntry(
        day: 'شنبه',
        date: '1402/07/01',
        time: '08:00-10:00',
        courseCode: '1234',
        courseGroup: '01',
        courseName: 'ریاضی 1',
        classroom: '101',
      ),
      ScheduleEntry(
        day: 'یکشنبه',
        date: '1402/07/02',
        time: '10:00-12:00',
        courseCode: '2345',
        courseGroup: '02',
        courseName: 'فیزیک 1',
        classroom: '102',
      ),
      ScheduleEntry(
        day: 'دوشنبه',
        date: '1402/07/03',
        time: '13:00-15:00',
        courseCode: '3456',
        courseGroup: '01',
        courseName: 'برنامه نویسی',
        classroom: '103',
      ),
      ScheduleEntry(
        day: 'سه شنبه',
        date: '1402/07/04',
        time: '15:00-17:00',
        courseCode: '4567',
        courseGroup: '03',
        courseName: 'مدار منطقی',
        classroom: '104',
      ),
      ScheduleEntry(
        day: 'چهارشنبه',
        date: '1402/07/05',
        time: '08:00-10:00',
        courseCode: '5678',
        courseGroup: '02',
        courseName: 'ساختمان داده',
        classroom: '105',
      ),
      ScheduleEntry(
        day: 'شنبه',
        date: '1402/07/08',
        time: '10:00-12:00',
        courseCode: '6789',
        courseGroup: '01',
        courseName: 'سیستم عامل',
        classroom: '106',
      ),
      ScheduleEntry(
        day: 'یکشنبه',
        date: '1402/07/09',
        time: '13:00-15:00',
        courseCode: '7890',
        courseGroup: '02',
        courseName: 'پایگاه داده',
        classroom: '107',
      ),
    ];

    // Initialize filtered entries with all entries
    filteredEntries = List.from(allEntries);

    // Extract unique filter options from data
    dayOptions = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه شنبه',
      'چهارشنبه',
      'پنجشنبه',
      'جمعه',
    ];
    timeOptions = allEntries.map((e) => e.time).toSet().toList();
  }

  // to send rquest
  List<Course> allCourses = [];
  List<Course> filteredCourses = [];
  List<String> timeOptions1 = [];

  Future<void> fetchScheduleFromApi() async {
    try {
      final courses = await ApiService().fetchSchedule(
        widget.user.university,
        widget.user.major,
      );

      setState(() {
        allCourses = courses;
        filteredCourses = List.from(courses);
        timeOptions1 = courses.map((e) => e.hour).toSet().toList();
      });
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('خطا در دریافت برنامه')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Replace the entire _showJalaliDatePicker method with this simpler version
  Future<void> _showJalaliDatePicker(
    BuildContext context,
    bool isStartDate,
  ) async {
    // Get current Jalali date
    final now = DateTime.now();
    final currentJalaliDate = JalaliDate.fromDateTime(now);

    // Get the currently selected date or default to current date
    JalaliDate selectedDate =
        isStartDate
            ? startDate ?? currentJalaliDate
            : endDate ??
                (startDate != null
                    ? JalaliDate(
                      startDate!.year,
                      startDate!.month,
                      startDate!.day + 7,
                    )
                    : currentJalaliDate);

    // Initialize selected values
    int selectedYear = selectedDate.year;
    int selectedMonth = selectedDate.month;
    int selectedDay = selectedDate.day;

    // Show the custom date picker dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isStartDate ? 'انتخاب تاریخ شروع' : 'انتخاب تاریخ پایان',
            style: const TextStyle(fontFamily: 'Vazir', fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Calculate days in the selected month
              int daysInMonth = 31; // Default for months 1-6
              if (selectedMonth > 6) {
                daysInMonth = 30; // For months 7-11
              }
              if (selectedMonth == 12) {
                daysInMonth = 29; // For month 12 (Esfand)
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day selection
                  Row(
                    children: [
                      const Text('روز:', style: TextStyle(fontFamily: 'Vazir')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedDay,
                          items: List.generate(daysInMonth, (index) {
                            final day = index + 1;
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text(
                                day.toString(),
                                style: const TextStyle(fontFamily: 'Vazir'),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              selectedDay = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Month selection
                  Row(
                    children: [
                      const Text('ماه:', style: TextStyle(fontFamily: 'Vazir')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedMonth,
                          items: List.generate(12, (index) {
                            final monthIndex = index + 1;
                            return DropdownMenuItem<int>(
                              value: monthIndex,
                              child: Text(
                                JalaliDate.getMonthName(monthIndex),
                                style: const TextStyle(fontFamily: 'Vazir'),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value!;

                              // Adjust days in month based on selected month
                              if (selectedMonth > 6) {
                                daysInMonth = 30;
                              } else {
                                daysInMonth = 31;
                              }
                              if (selectedMonth == 12) {
                                daysInMonth = 29;
                              }

                              // Adjust selected day if it exceeds days in month
                              if (selectedDay > daysInMonth) {
                                selectedDay = daysInMonth;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Year selection
                  Row(
                    children: [
                      const Text('سال:', style: TextStyle(fontFamily: 'Vazir')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedYear,
                          items:
                              List.generate(
                                10,
                                (index) => currentJalaliDate.year - 5 + index,
                              ).map((year) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(
                                    year.toString(),
                                    style: const TextStyle(fontFamily: 'Vazir'),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                final selectedJalaliDate = JalaliDate(
                  selectedYear,
                  selectedMonth,
                  selectedDay,
                );

                if (isStartDate) {
                  setState(() {
                    startDate = selectedJalaliDate;
                    // If end date is before start date, adjust end date
                    if (endDate != null && endDate!.compareTo(startDate!) < 0) {
                      endDate = JalaliDate(
                        startDate!.year,
                        startDate!.month,
                        startDate!.day + 7,
                      );
                    }
                  });

                  // If end date is not selected, show end date picker
                  if (endDate == null) {
                    Navigator.of(context).pop();
                    _showJalaliDatePicker(context, false);
                    return;
                  }
                } else {
                  setState(() {
                    endDate = selectedJalaliDate;
                  });
                }

                applyFilters();
                Navigator.of(context).pop();
              },
              child: Text(
                'تأیید',
                style: TextStyle(fontFamily: 'Vazir', color: primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'انصراف',
                style: TextStyle(fontFamily: 'Vazir', color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /**
   * Applies all selected filters to the schedule entries
   * 
   * This method filters the entries based on date range, day, time, and search query.
   * It updates the filteredEntries list with entries that match all selected filters.
   */
  void applyFilters() {
    setState(() {
      filteredEntries =
          allEntries.where((entry) {
            // Date range filter
            bool matchesDateRange = true;
            if (startDate != null && endDate != null) {
              bool isAfterOrEqualStart =
                  entry.jalaliDate.compareTo(startDate!) >= 0;
              bool isBeforeOrEqualEnd =
                  entry.jalaliDate.compareTo(endDate!) <= 0;
              matchesDateRange = isAfterOrEqualStart && isBeforeOrEqualEnd;
            }

            // Day filter
            bool matchesDay = selectedDay == null || entry.day == selectedDay;

            // Time filter
            bool matchesTime =
                selectedTime == null || entry.time == selectedTime;

            // Search query filter
            bool matchesSearch =
                searchQuery.isEmpty ||
                entry.courseName.contains(searchQuery) ||
                entry.courseCode.contains(searchQuery);

            // Entry must match all applied filters
            return matchesDateRange &&
                matchesDay &&
                matchesTime &&
                matchesSearch;
          }).toList();
    });
  }

  /**
   * Resets all filters to their default state
   * 
   * This method clears all filter selections and restores the original list of entries.
   */
  void resetFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedDay = null;
      selectedTime = null;
      searchQuery = '';
      _searchController.clear();
      filteredEntries = List.from(allEntries);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format date range for display
    String dateRangeText = '';
    if (startDate != null && endDate != null) {
      dateRangeText =
          'از ${startDate!.toFormattedString()} تا ${endDate!.toFormattedString()}';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'برنامه ترم',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Vazir',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters section with enhanced UI
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A1A), Color(0xFF303030)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter header with reset button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.filter_list,
                                color: primaryColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'فیلترها',
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        // Reset filters button
                        InkWell(
                          onTap: resetFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'حذف فیلترها',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Vazir',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search and date range filters
                    Row(
                      children: [
                        // Search field
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'جستجوی نام یا کد درس',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Vazir',
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                  applyFilters();
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Date range selector
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () => _showJalaliDatePicker(context, true),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      dateRangeText.isEmpty
                                          ? Colors.grey[700]!
                                          : primaryColor,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color:
                                          dateRangeText.isEmpty
                                              ? Colors.grey.withOpacity(0.2)
                                              : primaryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.date_range,
                                      color:
                                          dateRangeText.isEmpty
                                              ? Colors.grey
                                              : primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dateRangeText.isEmpty
                                          ? 'بازه تاریخ'
                                          : dateRangeText,
                                      style: TextStyle(
                                        color:
                                            dateRangeText.isEmpty
                                                ? Colors.grey
                                                : Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Vazir',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Day and time filters
                    Row(
                      children: [
                        // Day of week filter
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selectedDay != null
                                        ? primaryColor
                                        : Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedDay != null
                                            ? primaryColor.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color:
                                        selectedDay != null
                                            ? primaryColor
                                            : Colors.grey,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedDay,
                                      hint: const Text(
                                        'روز هفته',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      dropdownColor: Colors.grey[800],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Vazir',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDay = value;
                                          applyFilters();
                                        });
                                      },
                                      items:
                                          dayOptions
                                              .map<DropdownMenuItem<String>>((
                                                String value,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              })
                                              .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Class time filter
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selectedTime != null
                                        ? primaryColor
                                        : Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedTime != null
                                            ? primaryColor.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    color:
                                        selectedTime != null
                                            ? primaryColor
                                            : Colors.grey,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedTime,
                                      hint: const Text(
                                        'ساعت کلاس',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      dropdownColor: Colors.grey[800],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Vazir',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedTime = value;
                                          applyFilters();
                                        });
                                      },
                                      items:
                                          timeOptions
                                              .map<DropdownMenuItem<String>>((
                                                String value,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              })
                                              .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Schedule table with horizontal scroll
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          defaultColumnWidth: const FixedColumnWidth(120),
                          columnWidths: const {
                            0: FixedColumnWidth(100), // Day
                            1: FixedColumnWidth(120), // Date
                            2: FixedColumnWidth(120), // Class Time
                            3: FixedColumnWidth(180), // Course Name
                            4: FixedColumnWidth(100), // Classroom
                            5: FixedColumnWidth(100), // Course Group
                            6: FixedColumnWidth(100), // Course Code
                          },
                          children: [
                            // Header row
                            TableRow(
                              decoration: BoxDecoration(color: primaryColor),
                              children: const [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'روز',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'تاریخ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'ساعت کلاس',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'نام درس',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'کلاس',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'گروه درس',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'کد درس',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Data rows
                            ...filteredEntries.map(
                              (entry) => _buildDataTableRow(entry),
                            ),

                            // Add empty rows if filtered entries are less than 10
                            if (filteredEntries.length < 7)
                              ...List.generate(
                                7 - filteredEntries.length,
                                (index) => _buildEmptyTableRow(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Builds a table row for a schedule entry
   * 
   * @param entry The ScheduleEntry to display in the row
   * @return A TableRow widget with formatted data
   */
  TableRow _buildDataTableRow(ScheduleEntry entry) {
    // Format the date for display
    final JalaliDate jalaliDate = entry.jalaliDate;
    final String formattedDate =
        '${jalaliDate.day} ${JalaliDate.getMonthName(jalaliDate.month)} ${jalaliDate.year}';

    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                entry.day,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                entry.time,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                entry.courseName,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                entry.classroom,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                entry.courseGroup,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                entry.courseCode,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /**
   * Builds an empty table row for padding the table
   * 
   * @return A TableRow widget with empty cells
   */
  TableRow _buildEmptyTableRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: List.generate(
        7,
        (index) => const TableCell(
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text('', style: TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ),
    );
  }
}
