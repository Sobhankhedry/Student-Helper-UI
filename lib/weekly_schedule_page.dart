import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/Course.dart';
import 'package:flutter_application_2/models/User.dart';
import 'package:flutter_application_2/services/api_services.dart';

const Color primaryColor = Color.fromARGB(255, 20, 165, 255);

class thisCourse {
  final String name;
  final String instructor;
  final String classroom;
  final Color color;
  final String date; // e.g. '1402/2/10'
  final String day; // e.g. 'دوشنبه'
  final String hour;

  thisCourse({
    required this.date,
    required this.day,
    required this.hour,
    required this.name,
    required this.instructor,
    required this.classroom,
    required this.color,
  });
}

class WeeklySchedulePage extends StatefulWidget {
  final User currentUser;
  const WeeklySchedulePage({super.key, required this.currentUser});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  // Selected week (default to week 1)
  int _selectedWeek = 1;

  // Total number of weeks in a term
  final int _totalWeeks = 8;
  Map<int, Map<String, Map<int, thisCourse>>> weeklySchedules = {};

  @override
  void initState() {
    super.initState();
    fetchWeeklyFromApi();
  }

  Future<void> fetchWeeklyFromApi() async {
    try {
      final Map<String, int> dateToWeek = {
        // هفته اول
        '1402/01/01': 1,
        '1402/01/02': 1,
        '1402/01/03': 1,
        '1402/01/04': 1,
        '1402/01/05': 1,
        '1402/01/06': 1,
        '1402/01/07': 1,

        // هفته دوم
        '1402/01/08': 2,
        '1402/01/09': 2,
        '1402/01/10': 2,
        '1402/01/11': 2,
        '1402/01/12': 2,
        '1402/01/13': 2,
        '1402/01/14': 2,

        // هفته سوم
        '1402/01/15': 3,
        '1402/01/16': 3,
        '1402/01/17': 3,
        '1402/01/18': 3,
        '1402/01/19': 3,
        '1402/01/20': 3,
        '1402/01/21': 3,

        // // هفته چهارم
        '1402/01/22': 4,
        '1402/01/23': 4,
        '1402/01/24': 4,
        '1402/01/25': 4,
        '1402/01/26': 4,
        '1402/01/27': 4,
        '1402/01/28': 4,

        // // هفته پنجم
        // '1402/1/29': 5,
        // '1402/1/30': 5,
        // '1402/1/31': 5,
        // '1402/2/1': 5,
        // '1402/2/2': 5,
        // '1402/2/3': 5,
        // '1402/2/4': 5,

        // // هفته ششم
        // '1402/2/5': 6,
        // '1402/2/6': 6,
        // '1402/2/7': 6,
        // '1402/2/8': 6,
        // '1402/2/9': 6,
        // '1402/2/10': 6,
        // '1402/2/11': 6,

        // // هفته هفتم
        // '1402/2/12': 7,
        // '1402/2/13': 7,
        // '1402/2/14': 7,
        // '1402/2/15': 7,
        // '1402/2/16': 7,
        // '1402/2/17': 7,
        // '1402/2/18': 7,

        // // هفته هشتم
        // '1402/2/19': 8,
        // '1402/2/20': 8,
        // '1402/2/21': 8,
        // '1402/2/22': 8,
        // '1402/2/23': 8,
        // '1402/2/24': 8,
        // '1402/2/25': 8,
      };
      List<Course> course = await ApiService().fetchWeekly(
        widget.currentUser.university,
        widget.currentUser.major,
        widget.currentUser.userName,
      );

      for (var c in course) {
        int week = dateToWeek[c.date] ?? 1;
        print('Date: ${c.date}, Day: ${c.day}, Hour: ${c.hour}');
        print('Slot Index: ${getSlotIndex(c.hour)}');
        int slot = getSlotIndex(c.hour);

        if (slot == -1) continue;

        weeklySchedules[week] ??= {};
        weeklySchedules[week]![c.day] ??= {};

        weeklySchedules[week]![c.day]![slot] = thisCourse(
          name: c.courseName,
          instructor: c.professorName,
          classroom: c.classroom,
          color: Colors.primaries[slot % Colors.primaries.length].shade100,
          date: c.date,
          day: c.day,
          hour: c.hour,
        );
      }
      setState(() {});
    } catch (e) {}
  }

  final List<Map<String, String>> timeSlots = [
    {'start': '8:00', 'end': '10:00'},
    {'start': '10:00', 'end': '12:00'},
    {'start': '14:00', 'end': '16:00'},
    {'start': '16:00', 'end': '18:00'},
    {'start': '18:00', 'end': '20:00'},
  ];

  int getSlotIndex(String hour) {
    TimeOfDay courseTime = _parseTime(hour);

    for (int i = 0; i < timeSlots.length; i++) {
      TimeOfDay start = _parseTime(timeSlots[i]['start']!);
      TimeOfDay end = _parseTime(timeSlots[i]['end']!);

      if (_isTimeInRange(courseTime, start, end)) {
        return i;
      }
    }

    return -1;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final total = (TimeOfDay t) => t.hour * 60 + t.minute;
    return total(time) >= total(start) && total(time) < total(end);
  }

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
        border: Border.all(color: const Color(0xFF14A5FF), width: 1),
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
      'یک شنبه',
      'دو شنبه',
      'سه شنبه',
      'چهار شنبه',
      'پنجشنبه',
      'جمعه',
    ];

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
                    final courseForThisSlot =
                        weeklySchedules[_selectedWeek]?[day]?[index];
                    print(
                      'Schedule for week $_selectedWeek: ${weeklySchedules[_selectedWeek]}',
                    );
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
