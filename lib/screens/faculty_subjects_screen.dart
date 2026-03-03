import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class FacultySubjectsScreen extends StatefulWidget {
  const FacultySubjectsScreen({super.key});

  @override
  State<FacultySubjectsScreen> createState() => _FacultySubjectsScreenState();
}

class _FacultySubjectsScreenState extends State<FacultySubjectsScreen> {
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  String _selectedType = 'theory';
  String _selectedSemester = 'VI';

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    try {
      final subjects = await DatabaseService.getSubjects();
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subject', style: GoogleFonts.inter()),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
                items: ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII']
                    .map((semester) => DropdownMenuItem(
                          value: semester,
                          child: Text(semester),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSemester = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['theory', 'lab']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.capitalizeFirst()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditsController,
                decoration: const InputDecoration(
                  labelText: 'Credits',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addSubject,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSubject() async {
    if (_formKey.currentState!.validate()) {
      final subjectData = {
        'code': _codeController.text,
        'name': _nameController.text,
        'semester': _selectedSemester,
        'department': 'CSE',
        'credits': int.parse(_creditsController.text),
        'type': _selectedType,
      };

      final success = await DatabaseService.addSubject(subjectData);
      if (success) {
        _clearForm();
        Navigator.pop(context);
        _loadSubjects();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject added successfully')),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _codeController.clear();
    _creditsController.clear();
    _selectedType = 'theory';
    _selectedSemester = 'VI';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Subjects', style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withValues(alpha: 0.1),
              const Color(0xFF764ba2).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Semester VI Subjects',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddSubjectDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Subject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Subjects List
                  Expanded(
                    child: _subjects.isEmpty
                        ? Center(
                            child: Text(
                              'No subjects found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _subjects.length,
                            itemBuilder: (context, index) {
                              final subject = _subjects[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: subject['type'] == 'lab'
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1),
                                    child: Icon(
                                      subject['type'] == 'lab' ? Icons.science : Icons.book,
                                      color: subject['type'] == 'lab' ? Colors.orange : Colors.blue,
                                    ),
                                  ),
                                  title: Text(
                                    subject['name'],
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${subject['code']} • ${subject['semester']} Semester • ${subject['credits']} Credits',
                                    style: GoogleFonts.inter(),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: subject['type'] == 'lab'
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      subject['type'].capitalizeFirst(),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: subject['type'] == 'lab'
                                            ? Colors.orange
                                            : Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
