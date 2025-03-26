import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/User.dart';
import 'login_page.dart';
import 'weekly_schedule_page.dart';
import 'term_schedule_page.dart';
import 'exam_schedule_page.dart';

class SimpleDashboard extends StatelessWidget {
  final String username;

  final User user1;
  const SimpleDashboard({Key? key, required this.username, required this.user1})
    : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'داشبورد',
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4B22F4),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFF4B22F4),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'نام کاربری: $username',
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
    

              const SizedBox(height: 24),

              // Menu title
              const Text(
                'منوی برنامه‌ها',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 16),

              // Menu items as simple list
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuListItem(
                      title: 'برنامه هفتگی',
                      icon: Icons.calendar_view_week,
                      color: Colors.blue,
                      onTap: () => _navigateToPage(context, 'برنامه هفتگی'),
                    ),
                    _buildMenuListItem(
                      title: 'برنامه رشته',
                      icon: Icons.school,
                      color: Colors.green,
                      onTap: () => _navigateToPage(context, 'برنامه رشته'),
                    ),
                    _buildMenuListItem(
                      title: 'برنامه امتحانی',
                      icon: Icons.assignment,
                      color: Colors.orange,
                      onTap: () => _navigateToPage(context, 'برنامه امتحانی'),
                    ),
                    _buildMenuListItem(
                      title: 'برنامه ترم',
                      icon: Icons.calendar_today,
                      color: Colors.purple,
                      onTap: () => _navigateToPage(context, 'برنامه ترم'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuListItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageName) {
    if (pageName == 'برنامه هفتگی') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WeeklySchedulePage()),
      );
    } else if (pageName == 'برنامه ترم') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SchedulePage(user: user1)),
      );
    } else if (pageName == 'برنامه امتحانی') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExamSchedulePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'صفحه $pageName بعداً طراحی خواهد شد',
            style: const TextStyle(fontFamily: 'Vazir'),
            textAlign: TextAlign.right,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
