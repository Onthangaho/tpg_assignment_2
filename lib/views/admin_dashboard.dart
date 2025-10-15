// ignore_for_file: use_build_context_synchronously
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
import 'package:login_form/models/booking_model.dart';
import 'package:login_form/view_models/admin_view_model.dart';
import 'package:login_form/views/booking_detail_screen.dart';
import 'package:login_form/views/login_Screen.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchController=TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {

    final adminViemModel= Provider.of<AdminViewModel>(context);
    final authService= Provider.of<Auth>(context);
    return Scaffold(

      appBar: AppBar(
        title:const Text("Admin Dashboard") ,

        actions: [
          IconButton(
            onPressed:() async{
              await authService.logoutUser();
              Navigator.push(context,MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
              
            },

            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
         width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),

        child: Column(
          children: [
            _buildFilters(),
            Expanded(child: _buildBookingList(adminViemModel)),
          ],
        ),
      ),

    );
    
  }
  Widget _buildFilters(){

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration:   InputDecoration(
                labelText: 'Search by student ID',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)
              ),
              onChanged: (value) => {()},
            ),

            
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),

            onPressed: () => _selectDateRange(),
          )
        ],
      ),
    );
  }
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
  
Widget _buildBookingList(AdminViewModel adminViewModel) {
  return StreamBuilder<List<BookingModel>>(
    stream: adminViewModel.allBookings,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text("❌ Error: ${snapshot.error}"));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      List<BookingModel> bookings = snapshot.data ?? [];

        

      if (bookings.isEmpty) {
        return const Center(child: Text("No bookings found"));
      }
       

      return FutureBuilder<List<BookingModel>>(
        future: _filterBookingsByStudentNumber(bookings),
        builder: (context, filteredSnapshot) {
          if (filteredSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!filteredSnapshot.hasData || filteredSnapshot.data!.isEmpty) {
            return const Center(child: Text("No matching bookings found"));
          }

          return ListView.builder(
            itemCount: filteredSnapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = filteredSnapshot.data![index];
              return _buildBookingTile(context, booking);
            },
          );
        },
      );
    },
  );
}
Future<List<BookingModel>> _filterBookingsByStudentNumber(List<BookingModel> bookings) async {
  if (_searchController.text.isEmpty) return bookings; // No filter applied

  List<BookingModel> filteredBookings = [];

  for (var booking in bookings) {
    String studentNumber = await _fetchStudentNumber(booking.studentId);
    if (studentNumber.contains(_searchController.text)) {
      filteredBookings.add(booking);
    }
  }

  return filteredBookings;
}

Future<List<String>> _fetchNames(String studentId, String lecturerId) async {
  try {
    final studentDoc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();
    final lecturerDoc = await FirebaseFirestore.instance.collection('lecturers').doc(lecturerId).get();

    // 🔹 Ensure student data exists before accessing
    final studentData = studentDoc.data() ?? {};
    final studentName = studentData.containsKey('name') ? studentData['name'] as String : "Unknown";
    final studentNumber = studentData.containsKey('studentNumber') ? studentData['studentNumber'] as String : "Unknown";

    // 🔹 Ensure lecturer data exists before accessing
    final lecturerData = lecturerDoc.data() ?? {};
    final lecturerName = lecturerData.containsKey('name') ? lecturerData['name'] as String : "Unknown";

    return [studentName, studentNumber, lecturerName]; // 🔹 Return all three details
  } catch (e) {
    print("❌ Error fetching names: $e");
    return ["Unknown", "Unknown", "Unknown"]; // 🔹 Error fallback
  }
}
Future<String> _fetchStudentNumber(String studentId) async {
  try {
    final studentDoc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();

    // 🔹 Check if the document exists before accessing fields
    if (!studentDoc.exists || studentDoc.data() == null) {
      return "Unknown"; // 🔹 Handles missing or invalid data
    }

    final studentData = studentDoc.data()!;
    return studentData.containsKey('studentNumber') ? studentData['studentNumber'] as String : "Unknown";
  } catch (e) {
    print("❌ Error fetching student number: $e");
    return "Unknown"; // 🔹 Error fallback
  }
}

 void _viewBookingDetails(BuildContext context, BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingDetailScreen(booking: booking)),
    );
  }



Widget _buildBookingTile(BuildContext context, BookingModel booking) {
  return FutureBuilder<List<String>>(
    future: _fetchNames(booking.studentId, booking.lecturerId),
    builder: (context, snapshot) {
      final names = snapshot.data ?? ["Fetching...", "Fetching...", "Fetching..."];
      final studentName = names[0];  
      final studentNumber = names[1];  
      final lecturerName = names[2];

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text("$studentName ($studentNumber)"), // 🔹 Show student name & number dynamically
          subtitle: Text(
            "Date: ${_formatDate(booking.dateTime)} at ${_formatDateTime(booking.dateTime)}\n"
            "Lecturer:${booking.lecturerId}\n" // 🔹 Show lecturer name & ID dynamically
            "Topic: ${booking.topic}\n"
            "Status: ${booking.status}",
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteBooking(context, booking),
          ),
          onTap: () => _viewBookingDetails(context, booking),
        ),
      );
    },
  );
}

void _deleteBooking(BuildContext context,BookingModel booking) async{
  final adminViewModel =Provider.of<AdminViewModel>(context,listen: false);
  final confirmed = await showDialog<bool>(
    context: context,

    builder: (context) => AlertDialog(
      title: const Text("Confirm Delete"),

      content: const Text('Are you show you want to delete this booking?'),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context,false),
          child: const Text('Cancel'),
        ),
        TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await adminViewModel.deleteBooking(booking.id);
              _showSnackbar(context, "✅ Booking Deleted!");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),

      ],
    ),
  );
  if(confirmed==true){
     await adminViewModel.deleteBooking(booking.id);
      _showSnackbar(context, "✅ Booking Deleted!");

  }
}
 void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

 String _formatDateTime(DateTime datetime) {
  return "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}";
}

 String _formatDate(DateTime dateTime) {
  return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
}

}


