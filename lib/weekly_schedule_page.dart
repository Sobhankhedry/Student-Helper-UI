import 'package:flutter/material.dart';

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  'برنامه هفتگی',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20,),

              Expanded(child: _buildWeeklyScheduleTable()),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleTable() {
    final List<Map<String, String>> timeSlots = [
      {'start': '8:00', 'end': '10:00'},
      {'start': '10:00', 'end': '12:00'},
      {'start': '12:30', 'end': '14:00'},
      {'start': '14:00', 'end': '16:00'},
      {'start': '16:00', 'end': '18:00'},
    ];

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
        TableRow(
          decoration: const BoxDecoration(color: Color.fromARGB(255, 37, 175, 213)),
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

        ...weekDays
            .map(
              (day) => TableRow(
                children: [
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
                  ...List.generate(
                    5,
                    (index) => TableCell(
                      child: Container(
                        height: 70,
                        color: Colors.white,
                        child: const SizedBox(height: 32,),
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
