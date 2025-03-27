import 'package:flutter/material.dart';

/**
 * Exam Class
 * 
 * Represents an exam in the exam schedule.
 * Contains information about the course name, instructor, classroom, and exam duration.
 */
class Exam {
  final String courseName;
  final String instructor;
  final String classroom;
  final String duration; // Duration in minutes
  final Color color;

  Exam({
    required this.courseName,
    required this.instructor,
    required this.classroom,
    required this.duration,
    required this.color,
  });
}

class ExamSchedulePage extends StatefulWidget {
  const ExamSchedulePage({super.key});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  // Sample exam data
  late Map<String, Map<int, Exam>> examSchedule;

  @override
  void initState() {
    super.initState();
    
    // Initialize exam schedule data
    examSchedule = {
      '1402/10/27': { 
        0: Exam(
          courseName: 'ساختمان داده',
          instructor: 'دکتر صحافی زاده',
          classroom: 'A1',
          duration: '120',
          color: Colors.blue.shade100,
        ),
      },
      '1402/10/28': { 
        1: Exam(
          courseName: 'نظریه زبان‌ها و ماشین‌ها',
          instructor: 'دکتر طلعتیان',
          classroom: 'A1',
          duration: '150',
          color: Colors.purple.shade100,
        ),
      },
      '1402/10/29': { 
        3: Exam(
          courseName: 'مهندسی نرم‌افزار',
          instructor: 'دکتر صحافی زاده',
          classroom: 'A2',
          duration: '120',
          color: Colors.red.shade100,
        ),
      },
      '1402/10/30': { 
        2: Exam(
          courseName: 'پایگاه داده‌ها',
          instructor: 'دکتر طلعتیان',
          classroom: 'A1',
          duration: '150',
          color: Colors.green.shade100,
        ),
      },
      '1402/11/1': { 
        4: Exam(
          courseName: 'سیستم‌های عامل',
          instructor: 'استاد روشن',
          classroom: 'B7',
          duration: '120',
          color: Colors.amber.shade100,
        ),
      },
      '1402/11/5': {
        0: Exam(
          courseName: 'شبکه‌های کامپیوتری',
          instructor: 'استاد خیاطی',
          classroom: 'B8',
          duration: '150',
          color: Colors.pink.shade100,
        ),
      },
      '1402/11/6': { 
        2: Exam(
          courseName: 'معماری کامپیوتر',
          instructor: 'استاد روشن',
          classroom: 'B7',
          duration: '120',
          color: Colors.indigo.shade100,
        ),
      },
      '1402/11/7': { 
        1: Exam(
          courseName: 'مدارهای منطقی',
          instructor: 'دکتر ترابی',
          classroom: 'A1',
          duration: '120',
          color: Colors.cyan.shade100,
        ),
      },
      '1402/11/8': { 
        3: Exam(
          courseName: 'داده‌کاوی',
          instructor: 'دکتر رستمی',
          classroom: 'A2',
          duration: '150',
          color: Colors.teal.shade100,
        ),
      },
      '1402/11/9': { 
        4: Exam(
          courseName: 'هوش مصنوعی',
          instructor: 'دکتر محمدی',
          classroom: 'A1',
          duration: '120',
          color: Colors.orange.shade100,
        ),
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'برنامه امتحانی',
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        _buildScheduleTable(firstWeek: true),
                        const SizedBox(height: 10),
                        _buildScheduleTable(firstWeek: false),
                      ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              // Original search box without border
              Container(
                width: 200,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'تایید',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'جستجو',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /**
   * Builds a schedule table for a week
   * 
   * @param firstWeek Boolean flag indicating if this is the first week
   * @return A widget containing the schedule table
   */
  Widget _buildScheduleTable({required bool firstWeek}) {
    final List<String> days =
        firstWeek
            ? [
              'شنبه',
              'یکشنبه',
              'دوشنبه',
              'سه شنبه',
              'چهار شنبه',
              'پنجشنبه',
              'جمعه',
            ]
            : [
              'شنبه',
              'یکشنبه',
              'دوشنبه',
              'سه شنبه',
              'چهار شنبه',
              'پنجشنبه',
              'جمعه',
            ];

    final List<String> dates =
        firstWeek
            ? [
              '1402/10/27',
              '1402/10/28',
              '1402/10/29',
              '1402/10/30',
              '1402/11/1',
              '1402/11/2',
              '1402/11/3',
            ]
            : [
              '1402/11/4',
              '1402/11/5',
              '1402/11/6',
              '1402/11/7',
              '1402/11/8',
              '1402/11/9',
              '1402/11/10',
            ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header row with time slots
          _buildHeaderRow(),

          // Day rows
          for (int i = 0; i < days.length; i++) _buildDayRow(days[i], dates[i]),
        ],
      ),
    );
  }

  /**
   * Builds the header row with time slots
   * 
   * @return A widget containing the header row
   */
  Widget _buildHeaderRow() {
    // Correct purple color from the image
    const Color headerColor = Color(0xFFD580FF);
    return Row(
      children: [
        // Day/Time corner cell
        Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: headerColor,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: 5,
                right: 5,
                child: Text(
                  'روز',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
              const Positioned(
                bottom: 5,
                left: 5,
                child: Text(
                  'ساعت',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomPaint(painter: DiagonalLinePainter()),
              ),
            ],
          ),
        ),

        // Time slot headers
        _buildTimeSlotHeader('8:00\nتا\n10:00', headerColor),
        _buildTimeSlotHeader('10:00\nتا\n12:00', headerColor),
        _buildTimeSlotHeader('12:30\nتا\n14:00', headerColor),
        _buildTimeSlotHeader('14:00\nتا\n16:00', headerColor),
        _buildTimeSlotHeader('16:00\nتا\n18:00', headerColor),
      ],
    );
  }

  /**
   * Builds a time slot header cell
   * 
   * @param timeText The text to display in the cell
   * @param backgroundColor The background color of the cell
   * @return A widget containing the time slot header
   */
  Widget _buildTimeSlotHeader(String timeText, Color backgroundColor) {
    return Container(
      width: 150,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          timeText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Vazir',
          ),
        ),
      ),
    );
  }

  /**
   * Builds a day row with exam slots
   * 
   * @param day The name of the day
   * @param date The date string
   * @return A widget containing the day row
   */
  Widget _buildDayRow(String day, String date) {
    return Row(
      children: [
        // Day cell
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Vazir',
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 10, fontFamily: 'Vazir'),
              ),
            ],
          ),
        ),

        // Time slots for this day (with exams if scheduled)
        for (int i = 0; i < 5; i++)
          _buildExamCell(date, i),
      ],
    );
  }

  /**
   * Builds an exam cell for a specific date and time slot
   * 
   * @param date The date string
   * @param timeSlot The time slot index (0-4)
   * @return A widget containing the exam cell
   */
  Widget _buildExamCell(String date, int timeSlot) {
    // Check if there's an exam scheduled for this date and time slot
    final examForThisSlot = examSchedule[date]?[timeSlot];
    
    return Container(
      width: 150,
      height: 80,
      decoration: BoxDecoration(
        color: examForThisSlot?.color ?? Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(4),
      child: examForThisSlot != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  examForThisSlot.courseName,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  examForThisSlot.instructor,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'کلاس ${examForThisSlot.classroom}',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${examForThisSlot.duration} دقیقه',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}

/**
 * DiagonalLinePainter
 * 
 * A custom painter that draws a diagonal line from top-left to bottom-right.
 * Used in the day/time corner cell of the schedule table.
 */
class DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
