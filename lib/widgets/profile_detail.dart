// ignore_for_file: file_names
/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:flutter/material.dart';
import 'package:login_form/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';


class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      
      builder: (context, viewModel, child) {

        if (viewModel.user == null) {
      return const Center(child: CircularProgressIndicator()); // 🔹 Prevent null error
    }

      return Column(
          children: [
            _buildProfileField("Name", viewModel.user!.name , viewModel.isEditing),
            _buildProfileField("Student Number", viewModel.user!.studentNumber ?? "N/A", viewModel.isEditing),
            _buildProfileField("Contact Number", viewModel.user!.contactNumber ?? "N/A", viewModel.isEditing),
            _buildProfileField("Email", viewModel.user?.email ?? "N/A", viewModel.isEditing),

          ],

        );
      },
    );
  }

  Widget _buildProfileField(String label, String value, bool isEditing) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: value,
      readOnly: !isEditing,
    );
  }
}