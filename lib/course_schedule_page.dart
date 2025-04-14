import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/User.dart';
import 'package:flutter_application_2/selected_schedule_page.dart';
import 'package:flutter_application_2/services/api_services.dart';

const Color primaryColor = Color.fromARGB(255, 76, 175, 80); // Changed to green

class JalaliDate {
  final int year;
  final int month;
  final int day;

  JalaliDate(this.year, this.month, this.day);

  @override
  String toString() {
    return '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  }

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
}

/**
 * CourseEntry Class
 * 
 * Represents a single course in the course schedule.
 * Contains all the information about a course.
 */
class CourseEntry {
  final String id;
  final String day;
  final String date;
  final String time;
  final String courseCode;
  final String courseGroup;
  final String courseName;
  final String classroom;
  final String instructor;
  final int credits;
  final bool isSelected;

  CourseEntry({
    required this.id,
    required this.day,
    required this.date,
    required this.time,
    required this.courseCode,
    required this.courseGroup,
    required this.courseName,
    required this.classroom,
    required this.instructor,
    required this.credits,
    this.isSelected = false,
  });

  CourseEntry copyWith({bool? isSelected}) {
    return CourseEntry(
      id: id,
      day: day,
      date: date,
      time: time,
      courseCode: courseCode,
      courseGroup: courseGroup,
      courseName: courseName,
      classroom: classroom,
      instructor: instructor,
      credits: credits,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Check if this course conflicts with another course
  bool conflictsWith(CourseEntry other) {
    if (day != other.day) return false;

    try {
      List<String> thisTimeRange = time.split('-');
      List<String> otherTimeRange = other.time.split('-');

      if (thisTimeRange.length < 2 || otherTimeRange.length < 2) {
        debugPrint('Invalid time format: $time or ${other.time}');
        return false;
      }

      int thisStart = _timeToMinutes(thisTimeRange[0]);
      int thisEnd = _timeToMinutes(thisTimeRange[1]);
      int otherStart = _timeToMinutes(otherTimeRange[0]);
      int otherEnd = _timeToMinutes(otherTimeRange[1]);

      return (thisStart < otherEnd && thisEnd > otherStart);
    } catch (e) {
      debugPrint('Error in time conflict check: $e');
      return false;
    }
  }

  // Helper method to convert time string (HH:MM) to minutes
  int _timeToMinutes(String timeStr) {
    List<String> parts = timeStr.trim().split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class CourseSchedulePage extends StatefulWidget {
  final User currentUser;
  const CourseSchedulePage({Key? key, required this.currentUser})
    : super(key: key);

  @override
  State<CourseSchedulePage> createState() => _CourseSchedulePageState();
}

class _CourseSchedulePageState extends State<CourseSchedulePage> {
  String _autoExpandTime(String startTime) {
    try {
      TimeOfDay start = _parseTime(startTime);
      TimeOfDay end = TimeOfDay(hour: start.hour + 2, minute: start.minute);

      String format(TimeOfDay t) =>
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

      return '${format(start)}-${format(end)}';
    } catch (e) {
      debugPrint('Invalid startTime: $startTime');
      return '$startTime-00:00';
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Filter state variables
  String? selectedDay;
  String? selectedTime;
  String searchQuery = '';

  // Text controller for search field
  final TextEditingController _searchController = TextEditingController();

  // Data collections
  late List<CourseEntry> allCourses = [];
  late List<CourseEntry> filteredCourses = [];

  // Selected courses
  List<CourseEntry> selectedCourses = [];

  // Conflict information
  List<String> conflicts = [];
  bool showSelectedOnly = false;

  // Filter options
  late List<String> dayOptions;
  late List<String> timeOptions;

  @override
  void initState() {
    super.initState();
    fetchScheduleFromApi();

    // Initialize filtered courses with all courses
    filteredCourses = List.from(allCourses);

    // Extract unique filter options from data
    dayOptions = [
      'شنبه',
      'یک شنبه',
      'دو شنبه',
      'سه شنبه',
      'چهارشنبه',
      'پنجشنبه',
      'جمعه',
    ];
    timeOptions = allCourses.map((e) => e.time).toSet().toList();
  }

  Future<void> fetchScheduleFromApi() async {
    try {
      final courses = await ApiService().fetchSchedule(
        widget.currentUser.university,
        widget.currentUser.major,
      );

      // تبدیل لیست Course به CourseEntry
      final List<CourseEntry> convertedCourses =
          courses.map((course) {
            // 👇 Auto-expand single time to range
            String courseTime =
                course.hour.contains('-')
                    ? course.hour
                    : _autoExpandTime(course.hour); // You’ll define this below

            return CourseEntry(
              id: course.id,
              day: course.day,
              date: course.date,
              time: courseTime,
              courseCode: course.courseCode,
              courseGroup: course.group,
              courseName: course.courseName,
              classroom: course.classroom,
              instructor: course.professorName,
              credits: 3,
              isSelected: false,
            );
          }).toList();

      setState(() {
        allCourses = convertedCourses;
        filteredCourses = List.from(convertedCourses);
        timeOptions =
            convertedCourses.map((e) => e.time).toSet().toList()..sort(
              (a, b) => _timeToMinutes(
                a.split('-')[0],
              ).compareTo(_timeToMinutes(b.split('-')[0])),
            );
      });
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در دریافت برنامه درسی')),
      );
    }
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.trim().split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      if (showSelectedOnly) {
        filteredCourses = selectedCourses;
      } else {
        filteredCourses =
            allCourses.where((course) {
              // Day filter
              bool matchesDay =
                  selectedDay == null || course.day == selectedDay;

              // Time filter
              bool matchesTime =
                  selectedTime == null || course.time == selectedTime;

              // Search query filter
              bool matchesSearch =
                  searchQuery.isEmpty ||
                  course.courseName.contains(searchQuery) ||
                  course.courseCode.contains(searchQuery) ||
                  course.instructor.contains(searchQuery);

              // Course must match all applied filters
              return matchesDay && matchesTime && matchesSearch;
            }).toList();
      }
    });
  }

  void resetFilters() {
    setState(() {
      selectedDay = null;
      selectedTime = null;
      searchQuery = '';
      showSelectedOnly = false;
      _searchController.clear();
      filteredCourses = List.from(allCourses);
    });
  }

  bool toggleCourseSelection(String courseId) {
    int index = allCourses.indexWhere((course) => course.id == courseId);
    if (index == -1) return false;

    CourseEntry selectedCourse = allCourses[index];
    bool newSelectionState = !selectedCourse.isSelected;

    // Conflict check: only check if we’re turning this course ON
    if (newSelectionState) {
      for (var existing in selectedCourses) {
        if (selectedCourse.conflictsWith(existing)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تداخل زمانی: درس ${selectedCourse.courseName} با ${existing.courseName} در ${selectedCourse.day} تداخل دارد.',
                style: const TextStyle(fontFamily: 'Vazir'),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          return false;
        }
      }
    }

    setState(() {
      // Select or deselect all sessions with the same course name
      for (int i = 0; i < allCourses.length; i++) {
        if (allCourses[i].courseName == selectedCourse.courseName) {
          allCourses[i] = allCourses[i].copyWith(isSelected: newSelectionState);
        }
      }

      if (newSelectionState) {
        selectedCourses.addAll(
          allCourses.where(
            (c) =>
                c.courseName == selectedCourse.courseName &&
                !selectedCourses.contains(c),
          ),
        );
      } else {
        selectedCourses.removeWhere(
          (c) => c.courseName == selectedCourse.courseName,
        );
      }

      filteredCourses =
          showSelectedOnly ? selectedCourses : List.from(allCourses);
    });

    return true;
  }

  /**
   * Checks if a course conflicts with any of the currently selected courses
   * 
   * @param course The course to check for conflicts
   * @return A conflict message if there is a conflict, null otherwise
   */
  String? checkConflictWithCourse(CourseEntry course) {
    for (var selectedCourse in selectedCourses) {
      if (course.conflictsWith(selectedCourse)) {
        return 'تداخل زمانی: درس ${course.courseName} با درس ${selectedCourse.courseName} در روز ${course.day} تداخل دارد. امکان انتخاب همزمان وجود ندارد.';
      }
    }
    return null;
  }

  /**
   * Shows the selected courses
   */
  void showSelectedCoursesAndConflicts() {
    // Calculate total credits
    int totalCredits = selectedCourses.fold(
      0,
      (sum, course) => sum + course.credits,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'دروس انتخاب شده',
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 18),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected courses
                  Text(
                    'تعداد دروس: ${selectedCourses.length}',
                    style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'مجموع واحدها: $totalCredits',
                    style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of selected courses
                  ...selectedCourses.map(
                    (course) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.courseName,
                              style: const TextStyle(
                                fontFamily: 'Vazir',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'استاد: ${course.instructor}',
                              style: const TextStyle(fontFamily: 'Vazir'),
                            ),
                            Text(
                              'زمان: ${course.day} ${course.time}',
                              style: const TextStyle(fontFamily: 'Vazir'),
                            ),
                            Text(
                              'کلاس: ${course.classroom}',
                              style: const TextStyle(fontFamily: 'Vazir'),
                            ),
                            Text(
                              'تعداد واحد: ${course.credits}',
                              style: const TextStyle(fontFamily: 'Vazir'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'بستن',
                  style: TextStyle(fontFamily: 'Vazir', color: primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'برنامه رشته',
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.2),
                      primaryColor.withOpacity(0.05),
                    ],
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

                    // Search field
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
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
                          hintText: 'جستجوی نام درس، کد درس یا استاد',
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

                    const SizedBox(height: 12),

                    // Day and time filters
                    Row(
                      children: [
                        // Day of week filter
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selectedDay != null
                                        ? primaryColor
                                        : primaryColor.withOpacity(0.3),
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
                                            : Colors.white.withOpacity(0.1),
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
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selectedTime != null
                                        ? primaryColor
                                        : primaryColor.withOpacity(0.3),
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
                                            : Colors.white.withOpacity(0.1),
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

                    const SizedBox(height: 12),

                    // Show selected courses only toggle
                    InkWell(
                      onTap: () {
                        setState(() {
                          showSelectedOnly = !showSelectedOnly;
                          applyFilters();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              showSelectedOnly
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                showSelectedOnly
                                    ? primaryColor
                                    : primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              showSelectedOnly
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color:
                                  showSelectedOnly ? primaryColor : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'نمایش فقط دروس انتخاب شده',
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
              ),

              // Course table with horizontal scroll
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
                            0: FixedColumnWidth(65), // Checkbox column
                            1: FixedColumnWidth(180), // Course Name
                            2: FixedColumnWidth(100), // Date
                            3: FixedColumnWidth(120), // day
                            4: FixedColumnWidth(100), // time
                            5: FixedColumnWidth(100), // instructor
                            6: FixedColumnWidth(100), // classroom
                            7: FixedColumnWidth(100), //Course Group
                            8: FixedColumnWidth(100), // Course Code
                            9: FixedColumnWidth(80), // Credits
                          },
                          children: [
                            // Header row
                            TableRow(
                              decoration: BoxDecoration(color: primaryColor),
                              children: const [
                                // Checkbox column header
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'انتخاب',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Course Name
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
                                // Day
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
                                // Time
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
                                // Instructor
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'استاد',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Vazir',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Classroom
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
                                // Course Group
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
                                // Course Code
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
                                // Credits
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'واحد',
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
                            ...filteredCourses.map(
                              (course) => _buildDataTableRow(course),
                            ),

                            // Add empty rows if filtered courses are less than 7
                            if (filteredCourses.length < 7)
                              ...List.generate(
                                7 - filteredCourses.length,
                                (index) => _buildEmptyTableRow(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Button to show selected courses
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed:
                      selectedCourses.isEmpty
                          ? null
                          : () {
                            // Conflict check
                            bool hasConflict = false;
                            String? conflictMessage;

                            for (int i = 0; i < selectedCourses.length; i++) {
                              for (
                                int j = i + 1;
                                j < selectedCourses.length;
                                j++
                              ) {
                                if (selectedCourses[i].conflictsWith(
                                  selectedCourses[j],
                                )) {
                                  hasConflict = true;

                                  final c1 = selectedCourses[i];
                                  final c2 = selectedCourses[j];

                                  conflictMessage =
                                      'تداخل زمانی بین "${c1.courseName}" (${c1.day} ${c1.time}) '
                                      'و "${c2.courseName}" (${c2.day} ${c2.time})';

                                  break;
                                }
                              }
                              if (hasConflict) break;
                            }

                            if (hasConflict && conflictMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    conflictMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontFamily: 'Vazir'),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                              return; // ❗ Prevent navigation
                            }

                            // ✅ No conflict → Convert and navigate
                            List<thisCourse> convertedList =
                                selectedCourses.map((entry) {
                                  return thisCourse(
                                    name: entry.courseName,
                                    instructor: entry.instructor,
                                    classroom: entry.classroom,
                                    color:
                                        Colors
                                            .primaries[selectedCourses.indexOf(
                                                  entry,
                                                ) %
                                                Colors.primaries.length]
                                            .shade100,
                                    date: entry.date,
                                    day: entry.day,
                                    hour: entry.time.split('-')[0],
                                  );
                                }).toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SelectedSchedulePage(
                                      selectedCourses: convertedList,
                                    ),
                              ),
                            );
                          },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'نمایش برنامه درسی (${selectedCourses.map((e) => e.courseName).toSet().length} درس)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Vazir',
                        ),
                      ),
                    ],
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
   * Builds a table row for a course
   * 
   * @param course The CourseEntry to display in the row
   * @return A TableRow widget with formatted data
   */
  TableRow _buildDataTableRow(CourseEntry course) {
    return TableRow(
      decoration: BoxDecoration(
        color: course.isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
      ),
      children: [
        // Checkbox cell
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: Checkbox(
                value: course.isSelected,
                activeColor: primaryColor,
                onChanged: (bool? value) {
                  if (value == true || value == false) {
                    toggleCourseSelection(course.id);
                  }
                },
              ),
            ),
          ),
        ),
        // Course Name
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.courseName,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
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
                course.date,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        // Day
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.day,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        // Time
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.time,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        // Instructor
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.instructor,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        // Classroom
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.classroom,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        // Course Group
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.courseGroup,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        // Course Code
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.courseCode,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
        ),
        // Credits
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                course.credits.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildEmptyTableRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: List.generate(
        10, // Updated to include all columns including checkbox
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
