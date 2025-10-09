import 'package:dice_master/features/account/bloc/account_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
          bloc: BlocProvider.of<AccountBloc>(context)
            ..add(const TriggerAccountLoaded()),
          builder: (context, state) {
            if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountFailure) {
              return Center(child: Text(state.message));
            } else if (state is AccountLoaded) {
              final user = state.user;
              final displayNameController =
                  TextEditingController(text: user.displayName);
              final emailController = TextEditingController(text: user.email);
              final phoneNumberController =
                  TextEditingController(text: user.phoneNumber);
              final photoURLController =
                  TextEditingController(text: user.photoURL);
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (user.photoURL != null) {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then((file) {
                            if (file != null) {
                              photoURLController.text = file.path;
                            }
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(
                                user.photoURL!,
                                scale: 1.0,
                              )
                            : null,
                        child: user.photoURL == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: displayNameController,
                      decoration:
                          const InputDecoration(labelText: "Display Name"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: phoneNumberController,
                      decoration:
                          const InputDecoration(labelText: "Phone Number"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<AccountBloc>(context).add(
                          TriggerAccountUpdate(
                            displayName: displayNameController.text,
                            photoURL: photoURLController.text,
                            email: emailController.text,
                            phoneNumber: phoneNumberController.text,
                          ),
                        );
                      },
                      child: const Text("Save Changes"),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text("Unknown state"));
          }),
    );
  }
}
