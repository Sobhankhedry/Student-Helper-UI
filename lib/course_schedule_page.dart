import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/User.dart';
import 'package:flutter_application_2/selected_schedule_page.dart';

// Define the primary theme color for the application
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
    required this.time,
    required this.courseCode,
    required this.courseGroup,
    required this.courseName,
    required this.classroom,
    required this.instructor,
    required this.credits,
    this.isSelected = false,
  });

  // Create a copy of this course with the isSelected property changed
  CourseEntry copyWith({bool? isSelected}) {
    return CourseEntry(
      id: id,
      day: day,
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
    // If they're on different days, no conflict
    if (day != other.day) {
      return false;
    }

    // Parse time ranges
    List<String> thisTimeRange = time.split('-');
    List<String> otherTimeRange = other.time.split('-');

    // Convert to minutes for easier comparison
    int thisStart = _timeToMinutes(thisTimeRange[0]);
    int thisEnd = _timeToMinutes(thisTimeRange[1]);
    int otherStart = _timeToMinutes(otherTimeRange[0]);
    int otherEnd = _timeToMinutes(otherTimeRange[1]);

    // Check for overlap
    return (thisStart < otherEnd && thisEnd > otherStart);
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
  // Filter state variables
  String? selectedDay;
  String? selectedTime;
  String searchQuery = '';

  // Text controller for search field
  final TextEditingController _searchController = TextEditingController();

  // Data collections
  late List<CourseEntry> allCourses;
  late List<CourseEntry> filteredCourses;

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

    // Initialize sample data for the courses
    allCourses = [
      CourseEntry(
        id: '1',
        day: 'شنبه',
        time: '08:00-10:00',
        courseCode: '1234',
        courseGroup: '01',
        courseName: 'ریاضی 1',
        classroom: '101',
        instructor: 'دکتر محمدی',
        credits: 3,
      ),
      CourseEntry(
        id: '2',
        day: 'یکشنبه',
        time: '10:00-12:00',
        courseCode: '2345',
        courseGroup: '02',
        courseName: 'فیزیک 1',
        classroom: '102',
        instructor: 'دکتر رضایی',
        credits: 3,
      ),
      CourseEntry(
        id: '3',
        day: 'دوشنبه',
        time: '13:00-15:00',
        courseCode: '3456',
        courseGroup: '01',
        courseName: 'برنامه نویسی',
        classroom: '103',
        instructor: 'دکتر علوی',
        credits: 3,
      ),
      CourseEntry(
        id: '4',
        day: 'سه شنبه',
        time: '15:00-17:00',
        courseCode: '4567',
        courseGroup: '03',
        courseName: 'مدار منطقی',
        classroom: '104',
        instructor: 'دکتر حسینی',
        credits: 3,
      ),
      CourseEntry(
        id: '5',
        day: 'چهارشنبه',
        time: '08:00-10:00',
        courseCode: '5678',
        courseGroup: '02',
        courseName: 'ساختمان داده',
        classroom: '105',
        instructor: 'دکتر کریمی',
        credits: 3,
      ),
      CourseEntry(
        id: '6',
        day: 'شنبه',
        time: '10:00-12:00',
        courseCode: '6789',
        courseGroup: '01',
        courseName: 'سیستم عامل',
        classroom: '106',
        instructor: 'دکتر جعفری',
        credits: 3,
      ),
      CourseEntry(
        id: '7',
        day: 'یکشنبه',
        time: '13:00-15:00',
        courseCode: '7890',
        courseGroup: '02',
        courseName: 'پایگاه داده',
        classroom: '107',
        instructor: 'دکتر صادقی',
        credits: 3,
      ),
      CourseEntry(
        id: '8',
        day: 'شنبه',
        time: '08:00-10:00',
        courseCode: '8901',
        courseGroup: '03',
        courseName: 'هوش مصنوعی',
        classroom: '108',
        instructor: 'دکتر نوری',
        credits: 3,
      ),
      CourseEntry(
        id: '9',
        day: 'دوشنبه',
        time: '10:00-12:00',
        courseCode: '9012',
        courseGroup: '01',
        courseName: 'شبکه های کامپیوتری',
        classroom: '109',
        instructor: 'دکتر موسوی',
        credits: 3,
      ),
      CourseEntry(
        id: '10',
        day: 'سه شنبه',
        time: '13:00-15:00',
        courseCode: '0123',
        courseGroup: '02',
        courseName: 'مهندسی نرم افزار',
        classroom: '110',
        instructor: 'دکتر احمدی',
        credits: 3,
      ),
    ];

    // Initialize filtered courses with all courses
    filteredCourses = List.from(allCourses);

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
    timeOptions = allCourses.map((e) => e.time).toSet().toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /**
   * Applies all selected filters to the courses
   * 
   * This method filters the courses based on day, time, and search query.
   * It updates the filteredCourses list with courses that match all selected filters.
   */
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

  /**
   * Resets all filters to their default state
   * 
   * This method clears all filter selections and restores the original list of courses.
   */
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

  /**
   * Toggles the selection state of a course
   * 
   * @param courseId The ID of the course to toggle
   * @return True if the selection was successful, false if there was a conflict
   */
  bool toggleCourseSelection(String courseId) {
    // Find the course in allCourses
    int index = allCourses.indexWhere((course) => course.id == courseId);
    if (index == -1) return false;

    // Get the course
    CourseEntry course = allCourses[index];

    // If we're trying to select (not deselect)
    if (!course.isSelected) {
      // Check for conflicts with already selected courses
      String? conflictMessage = checkConflictWithCourse(course);

      // If there's a conflict, show message and don't allow selection
      if (conflictMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              conflictMessage,
              style: const TextStyle(fontFamily: 'Vazir'),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      }
    }

    setState(() {
      // Toggle the selection
      bool newSelectionState = !course.isSelected;

      // Update the course in allCourses
      allCourses[index] = course.copyWith(isSelected: newSelectionState);

      // Update selectedCourses list
      if (newSelectionState) {
        selectedCourses.add(allCourses[index]);
      } else {
        selectedCourses.removeWhere((c) => c.id == courseId);
      }

      // Update the filtered list as well
      int filteredIndex = filteredCourses.indexWhere((c) => c.id == courseId);
      if (filteredIndex != -1) {
        filteredCourses[filteredIndex] = filteredCourses[filteredIndex]
            .copyWith(isSelected: newSelectionState);
      }
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
                            2: FixedColumnWidth(100), // Day
                            3: FixedColumnWidth(120), // Time
                            4: FixedColumnWidth(100), // Instructor
                            5: FixedColumnWidth(100), // Classroom
                            6: FixedColumnWidth(100), // Course Group
                            7: FixedColumnWidth(100), // Course Code
                            8: FixedColumnWidth(80), // Credits
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
                                    date:
                                        '1402/01/01', // مقدار ثابت یا از دیتا بیس بگیر
                                    day: entry.day,
                                    hour:
                                        entry.time.split(
                                          '-',
                                        )[0], // فرض کردیم شروع زمان امتحانه
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
                        'نمایش برنامه درسی (${selectedCourses.length} درس)',
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

  /**
   * Builds an empty table row for padding the table
   * 
   * @return A TableRow widget with empty cells
   */
  TableRow _buildEmptyTableRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: List.generate(
        9, // Updated to include all columns including checkbox
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
