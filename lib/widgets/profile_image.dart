// ignore_for_file: use_build_context_synchronously
/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_form/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';



class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  void _pickImage(BuildContext context) async { // 🔹 Moved inside ProfileImage
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Provider.of<ProfileViewModel>(context, listen: false).updateImage(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context), // 🔹 Handles profile image selection
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return CircleAvatar(
            radius: 50,
            backgroundImage: viewModel.imagePath != null
                ? FileImage(File(viewModel.imagePath!))
                : const NetworkImage('https://picsum.photos/250?image=9') as ImageProvider,
          );
        },
      ),
    );
  }
}