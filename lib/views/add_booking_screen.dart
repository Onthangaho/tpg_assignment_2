/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:flutter/material.dart';
import 'package:login_form/auth/auth.dart';
import 'package:login_form/models/booking_model.dart';
import 'package:provider/provider.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController moduleController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedLecturerId;
  List<Map<String, dynamic>> lecturers = [];

  @override
  void initState() {
    _fetchLecturers();
    super.initState();
  }

  void _fetchLecturers() async {
    final authService = Provider.of<Auth>(context, listen: false);
    List<Map<String, dynamic>> fetchedLecturers =
        await authService.getAdminLecturers();
    setState(() {
      lecturers = fetchedLecturers;
    });
  }

  void submitForm() {
    if (_formKey.currentState!.validate() && selectedLecturerId != null) {
      final authService = Provider.of<Auth>(context, listen: false);
      //combine selectected date and time

      DateTime dateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, selectedTime.hour, selectedTime.minute);

      authService.bookConsultation(
        BookingModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          studentId: authService.currentUser!.uid,
          lecturerId: selectedLecturerId!,
          module: moduleController.text,
          dateTime: dateTime,
          topic: topicController.text,
          notes: notesController.text,
          status: "pending",
        ),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("✅ Booking Confirmed!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit COnsultation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                hint: const Text('Select Lecturer'),
                value: selectedLecturerId,
                items: lecturers.map((lecturer) {
                  return DropdownMenuItem(
                    value: lecturer['email']?.toString(),
                    child: Text('${lecturer['name']} (${lecturer['email']})'),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedLecturerId = value),
              ),
              TextFormField(
                  controller: moduleController,
                  decoration: const InputDecoration(labelText: "Module")),
              TextFormField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: "Topic",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Topic is required";
                  } else if (value.length < 20) {
                    return "Topic must be at least 20 characters long";
                  }
                  return null;
                },
              ),
              TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: "Notes")),

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
                child: const Text("Add Consultation"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
