// ignore_for_file: use_build_context_synchronously
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
//import 'package:login_form/models/user_model.dart';
import 'package:login_form/views/add_booking_screen.dart';
import 'package:login_form/views/booking_detail_screen.dart';
import 'package:login_form/views/edit_booking_screen.dart';
import 'package:login_form/views/login_Screen.dart';
import 'package:login_form/views/profile_screen.dart';

import 'package:provider/provider.dart';

class StudentHomeScreen extends StatelessWidget {
  final String email;
  const StudentHomeScreen({super.key, required this.email});

  void _navigateToAddBookingScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddBookingScreen(),
        )).then((_) {});
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  //delete booking
  void _deleteBooking(BuildContext context, String bookingId) async {
    final authService = Provider.of<Auth>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text('Are you sure you want to delete this booking'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await authService.deleteBooking(bookingId);

              _showSnackbar(context, "✅ Booking Deleted!");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await authService.deleteBooking(bookingId);
      _showSnackbar(context, "✅ Booking Deleted!");
    }
  }

  void _navigateToProfileScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePageScreen()),
    );
  }

  //navigate to edit screen method
  void _navigateToEditBookingScreen(
      BuildContext context, BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditBookingScreen(booking: booking)),
    ).then((_) {
      _showSnackbar(context, "✅ Booking Updated Successfully!");
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student home'),
        actions: [
          IconButton(
            onPressed: () => _navigateToProfileScreen(context),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () async {
              await authService.logoutUser();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ));
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBookingScreen(context),
        tooltip: 'Book Consultation',
        child: const Icon(Icons.add),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Column(
          children: [
            Expanded(child: _buildBookingsList(context, authService)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, Auth authService) {
    return StreamBuilder<List<BookingModel>>(
      stream: authService.getBookings(authService.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(
            child: Text('No consultations Booked'),
          );
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            return Card(
                elevation: 8,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Text('${booking.module} - ${booking.topic}'),
                  subtitle: Text(
                      'Date: ${_formatDate(booking.dateTime)} at ${_formatDateTime(booking.dateTime)}\nStatus: ${booking.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () =>
                            _navigateToEditBookingScreen(context, booking),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBooking(context, booking.id),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingDetailScreen(booking: booking),
                      )),
                ));
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime datetime) {
    return '${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year}";
  }
}
