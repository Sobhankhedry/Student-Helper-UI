import 'package:flutter/material.dart';

const Color primaryColor = Color.fromARGB(255, 20, 165, 255);

class Course {
  final String name;
  final String instructor;
  final String classroom;
  final Color color;

  Course({
    required this.name,
    required this.instructor,
    required this.classroom,
    required this.color,
  });
}

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({super.key});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  // Selected week (default to week 1)
  int _selectedWeek = 1;

  // Total number of weeks in a term
  final int _totalWeeks = 16;

  final Map<String, int> dateToWeek = {
    // هفته اول
    '1402/1/1': 1,
    '1402/1/2': 1,
    '1402/1/3': 1,
    '1402/1/4': 1,
    '1402/1/5': 1,
    '1402/1/6': 1,
    '1402/1/7': 1,

    // هفته دوم
    '1402/1/8': 2,
    '1402/1/9': 2,
    '1402/1/10': 2,
    '1402/1/11': 2,
    '1402/1/12': 2,
    '1402/1/13': 2,
    '1402/1/14': 2,

    // هفته سوم
    '1402/1/15': 3,
    '1402/1/16': 3,
    '1402/1/17': 3,
    '1402/1/18': 3,
    '1402/1/19': 3,
    '1402/1/20': 3,
    '1402/1/21': 3,

    // هفته چهارم
    '1402/1/22': 4,
    '1402/1/23': 4,
    '1402/1/24': 4,
    '1402/1/25': 4,
    '1402/1/26': 4,
    '1402/1/27': 4,
    '1402/1/28': 4,

    // هفته پنجم
    '1402/1/29': 5,
    '1402/1/30': 5,
    '1402/1/31': 5,
    '1402/2/1': 5,
    '1402/2/2': 5,
    '1402/2/3': 5,
    '1402/2/4': 5,

    // هفته ششم
    '1402/2/5': 6,
    '1402/2/6': 6,
    '1402/2/7': 6,
    '1402/2/8': 6,
    '1402/2/9': 6,
    '1402/2/10': 6,
    '1402/2/11': 6,

    // هفته هفتم
    '1402/2/12': 7,
    '1402/2/13': 7,
    '1402/2/14': 7,
    '1402/2/15': 7,
    '1402/2/16': 7,
    '1402/2/17': 7,
    '1402/2/18': 7,

    // هفته هشتم
    '1402/2/19': 8,
    '1402/2/20': 8,
    '1402/2/21': 8,
    '1402/2/22': 8,
    '1402/2/23': 8,
    '1402/2/24': 8,
    '1402/2/25': 8,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'برنامه هفتگی',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Vazir',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week selector dropdown
              _buildWeekSelector(),

              const SizedBox(height: 16),

              // Weekly schedule table with scrolling
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildWeeklyScheduleTable(),
                  ),
                ),
              ),

              SizedBox(height: 16),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Build the week selector dropdown
  Widget _buildWeekSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Week label
          Text(
            'انتخاب هفته:',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Vazir',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Dropdown for week selection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: _selectedWeek,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              elevation: 16,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Vazir',
                fontWeight: FontWeight.bold,
              ),
              underline: Container(height: 0),
              dropdownColor: primaryColor,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedWeek = newValue!;
                });
              },
              items: List.generate(_totalWeeks, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(
                    'هفته ${index + 1}',
                    style: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleTable() {
    // Define time slots for the schedule
    final List<Map<String, String>> timeSlots = [
      {'start': '8:00', 'end': '10:00'},
      {'start': '10:00', 'end': '12:00'},
      {'start': '14:00', 'end': '16:00'},
      {'start': '16:00', 'end': '18:00'},
      {'start': '18:00', 'end': '20:00'},
    ];

    // Define days of the week in Persian
    final List<String> weekDays = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه شنبه',
      'چهارشنبه',
      'پنجشنبه',
      'جمعه',
    ];

    // Define sample courses for different weeks
    final Map<int, Map<String, Map<int, Course>>> weeklySchedules = {
      // Week 1
      1: {
        'شنبه': {
          0: Course(
            name: 'ساختمان داده',
            instructor: 'دکتر صحافی زاده',
            classroom: 'B7',
            color: Colors.blue.shade100,
          ),
          2: Course(
            name: 'پایگاه داده‌ها',
            instructor: 'دکتر طلعتیان',
            classroom: 'B6',
            color: Colors.green.shade100,
          ),
        },
        'یکشنبه': {
          1: Course(
            name: 'نظریه زبان‌ها و ماشین‌ها',
            instructor: 'دکتر طلعتیان',
            classroom: 'B7',
            color: Colors.purple.shade100,
          ),
          3: Course(
            name: 'هوش مصنوعی',
            instructor: 'دکتر محمدی',
            classroom: 'B8',
            color: Colors.orange.shade100,
          ),
        },
        'دوشنبه': {
          0: Course(
            name: 'مهندسی نرم‌افزار',
            instructor: 'دکتر صحافی زاده',
            classroom: 'B7',
            color: Colors.red.shade100,
          ),
          4: Course(
            name: 'داده‌کاوی',
            instructor: 'دکتر رستمی',
            classroom: 'B6',
            color: Colors.teal.shade100,
          ),
        },
        'سه شنبه': {
          2: Course(
            name: 'سیستم‌های عامل',
            instructor: 'استاد روشن',
            classroom: 'B5',
            color: Colors.amber.shade100,
          ),
          3: Course(
            name: 'معماری کامپیوتر',
            instructor: 'استاد روشن',
            classroom: 'B9',
            color: Colors.indigo.shade100,
          ),
        },
        'چهارشنبه': {
          1: Course(
            name: 'شبکه‌های کامپیوتری',
            instructor: 'استاد خیاطی',
            classroom: 'B8',
            color: Colors.pink.shade100,
          ),
          4: Course(
            name: 'مدارهای منطقی',
            instructor: 'دکتر ترابی',
            classroom: 'B1',
            color: Colors.cyan.shade100,
          ),
        },
      },

      // Week 2
      2: {
        'شنبه': {
          0: Course(
            name: 'ساختمان داده',
            instructor: 'دکتر صحافی زاده',
            classroom: 'B7',
            color: Colors.blue.shade100,
          ),
          3: Course(
            name: 'هوش مصنوعی',
            instructor: 'دکتر محمدی',
            classroom: 'B8',
            color: Colors.orange.shade100,
          ),
        },
        'یکشنبه': {
          1: Course(
            name: 'نظریه زبان‌ها و ماشین‌ها',
            instructor: 'دکتر طلعتیان',
            classroom: 'B7',
            color: Colors.purple.shade100,
          ),
          4: Course(
            name: 'مدارهای منطقی',
            instructor: 'دکتر ترابی',
            classroom: 'B1',
            color: Colors.cyan.shade100,
          ),
        },
        'دوشنبه': {
          2: Course(
            name: 'پایگاه داده‌ها',
            instructor: 'دکتر طلعتیان',
            classroom: 'B6',
            color: Colors.green.shade100,
          ),
          4: Course(
            name: 'داده‌کاوی',
            instructor: 'دکتر رستمی',
            classroom: 'B6',
            color: Colors.teal.shade100,
          ),
        },
        'سه شنبه': {
          0: Course(
            name: 'مهندسی نرم‌افزار',
            instructor: 'دکتر صحافی زاده',
            classroom: 'B7',
            color: Colors.red.shade100,
          ),
          3: Course(
            name: 'معماری کامپیوتر',
            instructor: 'استاد روشن',
            classroom: 'B9',
            color: Colors.indigo.shade100,
          ),
        },
        'چهارشنبه': {
          1: Course(
            name: 'شبکه‌های کامپیوتری',
            instructor: 'استاد خیاطی',
            classroom: 'B8',
            color: Colors.pink.shade100,
          ),
          2: Course(
            name: 'سیستم‌های عامل',
            instructor: 'استاد روشن',
            classroom: 'B5',
            color: Colors.amber.shade100,
          ),
        },
      },
    };

    // For weeks 3-16, use the same schedule as week 1 or 2 alternately
    for (int i = 3; i <= _totalWeeks; i++) {
      weeklySchedules[i] = weeklySchedules[i % 2 == 1 ? 1 : 2]!;
    }

    // Get the schedule for the selected week
    final courseSchedule =
        weeklySchedules[_selectedWeek] ?? weeklySchedules[1]!;

    return Table(
      border: TableBorder.all(color: Colors.black, width: 1.5),
      defaultColumnWidth: const FixedColumnWidth(150),
      columnWidths: const {
        0: FixedColumnWidth(80), // Day column
      },
      children: [
        // Header row with time slots
        TableRow(
          decoration: BoxDecoration(color: primaryColor),
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    'ساعت',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Generate time slot headers
            ...List.generate(5, (index) {
              final timeSlot = timeSlots[index];
              return TableCell(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeSlot['start']!,
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'تا',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        timeSlot['end']!,
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),

        // Day rows with course data
        ...weekDays
            .map(
              (day) => TableRow(
                children: [
                  // Day name cell
                  TableCell(
                    child: Container(
                      height: 100,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontFamily: 'Vazir',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // Course cells for each time slot
                  ...List.generate(5, (index) {
                    // Check if there's a course scheduled for this day and time slot
                    final courseForThisSlot = courseSchedule[day]?[index];

                    return TableCell(
                      child: Container(
                        height: 100,
                        color: courseForThisSlot?.color ?? Colors.white,
                        padding: const EdgeInsets.all(4),
                        child:
                            courseForThisSlot != null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      courseForThisSlot.name,
                                      style: const TextStyle(
                                        fontFamily: 'Vazir',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      courseForThisSlot.instructor,
                                      style: const TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'کلاس ${courseForThisSlot.classroom}',
                                        style: const TextStyle(
                                          fontFamily: 'Vazir',
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                )
                                : const SizedBox(),
                      ),
                    );
                  }),
                ],
              ),
            )
            .toList(),
      ],
    );
  }
}
