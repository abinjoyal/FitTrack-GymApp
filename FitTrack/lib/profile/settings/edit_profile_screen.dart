import 'dart:io';
import 'package:fit_track/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<HomeProvider>();

      await provider.loadProfile();

      nameController.text = provider.name;
      emailController.text = provider.email;
      phoneController.text = provider.phone;
    });
  }

  /// 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  /// ☁️ UPLOAD IMAGE
  Future<String?> uploadImage() async {
    if (imageFile == null) return null;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    /// 🔥 GET EXTENSION (png / jpg / jpeg)
    final fileExt = imageFile!.path.split('.').last;

    /// 🔥 DYNAMIC FILE NAME
    final filePath = "${user!.id}/profile.$fileExt";

    await supabase.storage
        .from('profile_images')
        .upload(
          filePath,
          imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

    final imageUrl = supabase.storage
        .from('profile_images')
        .getPublicUrl(filePath);

    return imageUrl;
  }

  /// 💾 SAVE PROFILE
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final provider = context.read<HomeProvider>();

    try {
      /// 📸 Upload image first
      final imageUrl = await uploadImage();

      /// 💾 Update profile (Provider handles email update)
      await provider.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        imageUrl: imageUrl,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile Updated 🚀")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C2E05), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// 👤 PROFILE IMAGE
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white12,
                              backgroundImage: imageFile != null
                                  ? FileImage(imageFile!)
                                  : (provider.imageUrl.isNotEmpty
                                        ? NetworkImage(
                                            "${provider.imageUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
                                          )
                                        : null),

                              child:
                                  (imageFile == null &&
                                      provider.imageUrl.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: const Color(0xFFD0FD3E),
                              ),
                              onPressed: pickImage,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        _buildField(nameController, "Name", Icons.person),
                        const SizedBox(height: 15),
                        _buildField(emailController, "Email", Icons.email),
                        const SizedBox(height: 15),
                        _buildField(phoneController, "Phone", Icons.phone),

                        const SizedBox(height: 30),

                        /// 💾 SAVE BUTTON
                        ElevatedButton(
                          onPressed: saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD0FD3E),
                          ),
                          child: const Text("Save Changes"),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// 🔧 TEXT FIELD WIDGET
  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFD0FD3E),),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
