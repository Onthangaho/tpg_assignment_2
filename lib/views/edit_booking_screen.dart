/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_form/auth/auth.dart';
import 'package:provider/provider.dart';

import '../models/booking_model.dart';

class EditBookingScreen extends StatefulWidget {
  final BookingModel booking;

  const EditBookingScreen({super.key, required this.booking});

  @override
  EditBookingScreenState createState() => EditBookingScreenState();
}

class EditBookingScreenState extends State<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController moduleController;
  late TextEditingController topicController;
  late TextEditingController notesController;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedLecturerId;
  List<Map<String, dynamic>> lecturers = [];

  @override
  void initState() {
    super.initState();
    moduleController = TextEditingController(text: widget.booking.module);
    topicController = TextEditingController(text: widget.booking.topic);
    notesController = TextEditingController(text: widget.booking.notes);
    selectedDate = widget.booking.dateTime is Timestamp
        ? (widget.booking.dateTime as Timestamp).toDate()
        : widget.booking.dateTime;
    selectedTime = TimeOfDay.fromDateTime(selectedDate);
    selectedLecturerId = widget.booking.lecturerId;
    _fetchLecturers();
  }

  void _fetchLecturers() async {
    final authService = Provider.of<Auth>(context, listen: false);
    List<Map<String, dynamic>> fetchedLecturers = await authService.getAdminLecturers();
    setState(() {
      lecturers = fetchedLecturers;
    });
  }

  void submitForm() {
    if (_formKey.currentState!.validate() && selectedLecturerId != null) {
      final authService = Provider.of<Auth>(context, listen: false);

      // Combine date and time into a single DateTime object
      DateTime dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      authService.updateBooking(
        widget.booking.id,
        moduleController.text,
        dateTime,
        topicController.text,
        notesController.text,
        authService.currentUser!.uid,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Booking Updated Successfully!")),
      );

      Navigator.pop(context); // Navigate back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Consultation")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedLecturerId,
                items: lecturers.map((lecturer) {
                  return DropdownMenuItem(
                    value: lecturer['email']?.toString(),
                    child: Text("${lecturer['name']} (${lecturer['email']})"),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedLecturerId = value),
              ),
              TextFormField(controller: moduleController, decoration: const InputDecoration(labelText: "Module")),
              TextFormField(controller: topicController, decoration: const InputDecoration(labelText: "Topic")),
              TextFormField(controller: notesController, decoration: const InputDecoration(labelText: "Notes")),

              // Pick Date Button
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
              const SizedBox(height: 10,),
              // Pick Time Button
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) setState(() => selectedTime = picked);
                },
                child: const Text("Pick Time"),
              ),
               const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text("Update Consultation"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}