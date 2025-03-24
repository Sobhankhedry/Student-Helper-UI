import 'package:flutter/material.dart';

// Define the primary theme color for the application
const Color primaryColor = Color.fromARGB(255, 37, 37, 213);

class WeeklySchedulePage extends StatelessWidget {
  const WeeklySchedulePage({super.key});

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
          'برنامه هفتگی',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

              // Weekly schedule table
              Expanded(child: _buildWeeklyScheduleTable()),

              const SizedBox(height: 40),
            ],
          ),
        ),
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

    return Table(
      border: TableBorder.all(color: Colors.black, width: 3),
      columnWidths: const {
        0: FixedColumnWidth(60),
        1: FixedColumnWidth(60),
        2: FixedColumnWidth(60),
        3: FixedColumnWidth(60),
        4: FixedColumnWidth(60),
        5: FixedColumnWidth(60),
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
                      color: Colors.white,
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'تا',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        timeSlot['end']!,
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Colors.white,
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

        // Day rows with empty cells for schedule entries
        ...weekDays
            .map(
              (day) => TableRow(
                children: [
                  // Day name cell
                  TableCell(
                    child: Container(
                      height: 70,
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
                  // Empty cells for schedule entries
                  ...List.generate(
                    5,
                    (index) => TableCell(
                      child: Container(
                        height: 70,
                        color: Colors.white,
                        child: const SizedBox(height: 32),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ],
    );
  }
}
