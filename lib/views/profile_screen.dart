/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */

import 'package:flutter/material.dart';
import 'package:login_form/view_models/profile_view_model.dart';
import 'package:login_form/widgets/Profile_detail.dart';
import 'package:login_form/widgets/profile_image.dart';
import 'package:login_form/widgets/update_button.dart';
import 'package:provider/provider.dart';

class ProfilePageScreen extends StatelessWidget {
  const ProfilePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: Container(

        width: double.infinity,
        height: double.infinity,
         decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.user == null) {
              return const Center(
                  child: CircularProgressIndicator()); // 🔹 Prevents null errors
            }
        
            return Center(
              child: SingleChildScrollView(

                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth > 600
                        ? _buildTabletLayout()
                        : _buildPhoneLayout();
                  },
                  ),
                )
                )
              ),
            );
          },
        ),
      ),
    );
  }
 Widget _buildPhoneLayout() {
    return const Column(
      children: [
        ProfileImage(),
        ProfileDetails(),
        SizedBox(height: 20),
        UpdateButton(),
      ],
    );
  }


   Widget _buildTabletLayout() {
    return const Row(
      children: [
        Expanded(child: Column(children: [ProfileImage(), ProfileDetails()])),
        Expanded(child: Center(child: UpdateButton())),
      ],
    );
  }
}

 
 

