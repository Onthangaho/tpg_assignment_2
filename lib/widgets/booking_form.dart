/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:flutter/material.dart';


class BookingForm extends StatefulWidget {
  final List<Map<String, dynamic>> lecturers;
  final String? initialModule;
  final DateTime? initialDate;
  final String? initialTopic;
  final String? initialNotes;
  final void Function(
      String module, DateTime dateTime, String topic, String notes, String lecturerId) onSubmit;

  const BookingForm({
    super.key,
    required this.onSubmit,
    required this.lecturers,
    this.initialModule,
    this.initialDate,
    this.initialTopic,
    this.initialNotes,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController moduleController;
  late TextEditingController topicController;
  late TextEditingController notesController;
  DateTime selectedDate = DateTime.now();
  String? selectedLecturerId;

  @override
  void initState() {
    super.initState();
    moduleController = TextEditingController(text: widget.initialModule ?? '');
    topicController = TextEditingController(text: widget.initialTopic ?? '');
    notesController = TextEditingController(text: widget.initialNotes ?? '');
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  void submitForm() {
    if (_formKey.currentState!.validate() && selectedLecturerId != null) {
      widget.onSubmit(
        moduleController.text,
        selectedDate,
        topicController.text,
        notesController.text,
        selectedLecturerId!,
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a lecturer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            hint: const Text('Select Lecturer'),
            initialValue: selectedLecturerId,
            items: widget.lecturers.map((lecturer) {
              return DropdownMenuItem(
                value: lecturer['email']?.toString(),
                child: Text(lecturer['name']),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedLecturerId = value),
          ),
          TextFormField(
            controller: moduleController,
            decoration: const InputDecoration(labelText: 'Module'),
          ),
          TextFormField(
            controller: topicController,
            decoration: const InputDecoration(labelText: 'Topic'),
          ),
          TextFormField(
            controller: notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          ElevatedButton(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2050),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
            child: const Text("Pick Date"),
          ),
          ElevatedButton(
            onPressed: submitForm,
            child: const Text("Book Consultation"),
          ),
        ],
      ),
    );
  }
}