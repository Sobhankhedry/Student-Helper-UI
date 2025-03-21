import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedField;
  String? _selectedUniversity;

  final List<String> _fields = [
    'مهندسی کامپیوتر',
    'مهندسی برق',
    'مهندسی مکانیک',
    'مهندسی عمران',
    'حسابداری',
    'مدیریت صنعتی',
  ];

  final List<String> _universities = [
    'دانشگاه تهران',
    'دانشگاه شریف',
    'دانشگاه امیرکبیر',
    'دانشگاه خلیج فارس',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(247, 240, 240, 240),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                // Header with circle
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, 
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4B22F4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'فرم ثبت نام',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B22F4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Row for name and field of study
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Vazir'),
                        decoration: const InputDecoration(
                          hintText: 'نام و نام خانوادگی',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: TextStyle(fontFamily: 'Vazir', fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildCustomDropdown(
                        hint: 'رشته تحصیلی',
                        value: _selectedField,
                        items: _fields,
                        onChanged: (value) {
                          setState(() {
                            _selectedField = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // University dropdown
                _buildCustomDropdown(
                  hint: 'نام دانشگاه',
                  value: _selectedUniversity,
                  items: _universities,
                  onChanged: (value) {
                    setState(() {
                      _selectedUniversity = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Username field
                TextField(
                  controller: _usernameController,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Vazir'),
                  decoration: const InputDecoration(
                    hintText: 'نام کاربری',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextField(
                  controller: _passwordController,
                  textAlign: TextAlign.right,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Vazir'),
                  decoration: const InputDecoration(
                    hintText: 'رمز عبور',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm password field
                TextField(
                  controller: _confirmPasswordController,
                  textAlign: TextAlign.right,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Vazir'),
                  decoration: const InputDecoration(
                    hintText: 'تأیید رمز عبور',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Register button
                ElevatedButton(
                  onPressed: () {
                    // Handle registration logic
                  },
                  child: const Text(
                    'ثبت نام',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Custom dropdown builder 
  Widget _buildCustomDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  hint,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(
                fontFamily: 'Vazir',
                color: Colors.black,
              ),
              dropdownColor: Colors.white,
              alignment: AlignmentDirectional.centerEnd,
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      item,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
