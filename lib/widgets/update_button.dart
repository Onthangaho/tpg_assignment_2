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


class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return ElevatedButton(
          onPressed: viewModel.isEditing ? () => _saveProfile(viewModel) : viewModel.toggleEditMode,
          child: Text(viewModel.isEditing ? "Save Changes" : "Edit Profile"),
        );
      },
    );
  }

void _saveProfile(ProfileViewModel viewModel) {
  if (viewModel.user == null) return; // 🔹 Prevents null reference error

  viewModel.updateProfile(
    viewModel.user?.name ?? "N/A",
    viewModel.user?.studentNumber ?? "N/A",
    viewModel.user?.contactNumber ?? "N/A",
  );
}

}