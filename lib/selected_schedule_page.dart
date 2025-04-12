import 'package:flutter/material.dart';

class thisCourse {
  final String name;
  final String instructor;
  final String classroom;
  final Color color;
  final String date;
  final String day;
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

class SelectedSchedulePage extends StatefulWidget {
  final List<thisCourse> selectedCourses;

  const SelectedSchedulePage({Key? key, required this.selectedCourses})
    : super(key: key);

  @override
  State<SelectedSchedulePage> createState() => _SelectedSchedulePageState();
}

class _SelectedSchedulePageState extends State<SelectedSchedulePage> {
  int _selectedWeek = 1;
  final int _totalWeeks = 8;
  Color primaryColor = Color.fromARGB(255, 20, 165, 255);

  final List<Map<String, String>> timeSlots = [
    {'start': '8:00', 'end': '10:00'},
    {'start': '10:00', 'end': '12:00'},
    {'start': '14:00', 'end': '16:00'},
    {'start': '16:00', 'end': '18:00'},
    {'start': '18:00', 'end': '20:00'},
  ];

  Map<int, Map<String, Map<int, thisCourse>>> weeklySchedules = {};

  @override
  void initState() {
    super.initState();
    _buildScheduleMap();
  }

  void _buildScheduleMap() {
    final Map<String, int> dateToWeek = {
      // هفته اول
      '1402/01/01': 1, '1402/01/02': 1, '1402/01/03': 1,
      '1402/01/04': 1, '1402/01/05': 1, '1402/01/06': 1, '1402/01/07': 1,
      // هفته دوم
      '1402/01/08': 2, '1402/01/09': 2, '1402/01/10': 2,
      '1402/01/11': 2, '1402/01/12': 2, '1402/01/13': 2, '1402/01/14': 2,
      // هفته سوم
      '1402/01/15': 3, '1402/01/16': 3, '1402/01/17': 3,
      '1402/01/18': 3, '1402/01/19': 3, '1402/01/20': 3, '1402/01/21': 3,
      // هفته چهارم
      '1402/01/22': 4, '1402/01/23': 4, '1402/01/24': 4,
      '1402/01/25': 4, '1402/01/26': 4, '1402/01/27': 4, '1402/01/28': 4,
    };

    for (var course in widget.selectedCourses) {
      int week = dateToWeek[course.date] ?? 1;
      int slot = getSlotIndex(course.hour);
      if (slot == -1) continue;

      weeklySchedules[week] ??= {};
      weeklySchedules[week]![course.day] ??= {};
      weeklySchedules[week]![course.day]![slot] = course;
    }
    setState(() {});
  }

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
        title: const Text('برنامه انتخابی'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildWeekSelector(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildScheduleTable(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF14A5FF), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'هفته انتخابی:',
            style: TextStyle(color: Colors.white, fontFamily: 'Vazir'),
          ),
          DropdownButton<int>(
            value: _selectedWeek,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white, fontFamily: 'Vazir'),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: Container(height: 0),
            onChanged: (value) {
              setState(() {
                _selectedWeek = value!;
              });
            },
            items: List.generate(_totalWeeks, (index) {
              return DropdownMenuItem<int>(
                value: index + 1,
                child: Text('هفته ${index + 1}'),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    final List<String> weekDays = [
      'شنبه',
      'یک شنبه',
      'دو شنبه',
      'سه شنبه',
      'چهار شنبه',
      'پنج شنبه',
      'جمعه',
    ];

    return Table(
      border: TableBorder.all(color: Colors.black, width: 1.5),
      defaultColumnWidth: const FixedColumnWidth(150),
      columnWidths: const {
        0: FixedColumnWidth(80), // ستون روزها
      },
      children: [
        // 🟦 هدر جدول (ساعات کلاس)
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
            ...timeSlots.map(
              (slot) => TableCell(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        slot['start']!,
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
                        slot['end']!,
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
              ),
            ),
          ],
        ),

        // 📅 ردیف‌های مربوط به روزهای هفته
        ...weekDays.map((day) {
          return TableRow(
            children: [
              // 🔹 نام روز
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
              // 🔹 سلول‌های مربوط به کلاس‌ها در هر اسلات زمانی
              ...List.generate(timeSlots.length, (index) {
                final course = weeklySchedules[_selectedWeek]?[day]?[index];
                return TableCell(
                  child: Container(
                    height: 100,
                    color: course?.color ?? Colors.white,
                    padding: const EdgeInsets.all(4),
                    child:
                        course != null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  course.name,
                                  style: const TextStyle(
                                    fontFamily: 'Vazir',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course.instructor,
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
                                    'کلاس ${course.classroom}',
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
          );
        }).toList(),
      ],
    );
  }
}
