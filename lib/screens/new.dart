import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lawyer.dart';
import '../models/account.dart';
import 'home.dart';
import 'Lawyer screens/lawyerHomeScreen.dart';

class New extends StatefulWidget {
  const New({super.key, required this.email, required this.uid});
  final String email;
  final String uid;

  @override
  State<New> createState() => _NewState();
}

class _NewState extends State<New> {
  bool isLawyer = false;
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();

  final List<String> professions = [
    "Civil Law",
    "Criminal Law",
    "Commercial Law",
    "Labor Law",
    "Insurance Law",
    "International Law",
  ];
  String? _selectedProfession;

  final List<String> provinces = [
    "Amman (capital)",
    "Zarqaa",
    "ma'an",
    "Irbid",
    "Aqaba",
  ];
  String? _selectedprovinces;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Complete Sign-Up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 20),
                _buildUserTypeToggle(),
                const SizedBox(height: 20),
                _buildProfileImagePicker(),
                const SizedBox(height: 20),
                _buildTextField("Full Name", _nameController),
                const SizedBox(height: 15),
                _buildTextField(
                  "Phone Number",
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                if (isLawyer) ...[
                  const SizedBox(height: 15),
                  _buildDropdownField("Profession", _selectedProfession),
                  const SizedBox(height: 15),
                  _buildDropdownFieldprov("Province", _selectedprovinces),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Years of Experience",
                    _experienceController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField("License Number", _licenseController),
                  const SizedBox(height: 15),
                  _buildTextField("Description", _descController),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Consultation Fee",
                    _feesController,
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 25),
                isSubmitting
                    ? CircularProgressIndicator()
                    : _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUserTypeCard("I'm a Client", Icons.person, false),
        const SizedBox(width: 16),
        _buildUserTypeCard("I'm a Lawyer", Icons.gavel, true),
      ],
    );
  }

  Widget _buildUserTypeCard(String label, IconData icon, bool value) {
    bool selected = isLawyer == value;
    return GestureDetector(
      onTap: () => setState(() => isLawyer = value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              selected ? const Color.fromARGB(255, 112, 67, 0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color.fromARGB(255, 112, 84, 0).withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
          ],
          border: Border.all(
            color:
                selected
                    ? const Color.fromARGB(255, 100, 65, 0)
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: const Color.fromARGB(255, 116, 70, 0).withOpacity(0.2),
        backgroundImage:
            _selectedImage != null ? FileImage(_selectedImage!) : null,
        child:
            _selectedImage == null
                ? Icon(
                  Icons.camera_alt,
                  color: const Color.fromARGB(255, 130, 69, 0),
                  size: 30,
                )
                : null,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 112, 73, 0),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: (val) => setState(() => _selectedProfession = val),
      items:
          professions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownFieldprov(String label, String? value) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: (val) => setState(() => _selectedprovinces = val),
      items:
          provinces
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color.fromARGB(255, 121, 83, 0),
      ),
      onPressed: _submitForm,
      child: const Text(
        "Submit",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    String imageUrl = '';
    if (_selectedImage != null) {
      try {
        imageUrl = await uploadImageToSupabase(_selectedImage!, widget.uid);
      } catch (e) {
        print("Image upload error: $e");
        setState(() => isSubmitting = false);
        _showError("Failed to upload image");
        return;
      }
    }

    try {
      if (!isLawyer) {
        Account user = Account(
          uid: widget.uid,
          name: _nameController.text,
          email: widget.email,
          number: _phoneController.text,
          isLawyer: false,
          imageUrl: imageUrl, // add this
        );
        await user.addToFirestore();
        Get.to(HomeScreen(account: user));
      } else {
        Lawyer lawyer = Lawyer(
          uid: widget.uid,
          name: _nameController.text,
          email: widget.email,
          number: _phoneController.text,
          licenseNO: _licenseController.text,
          exp: int.parse(_experienceController.text),
          specialization: _selectedProfession,
          province: _selectedprovinces,
          isLawyer: true,
          desc: _descController.text,
          fees: _feesController.text,
          imageUrl: imageUrl, // add this
        );
        await lawyer.addToFirestore();
        Get.to(LawyerHomeScreen(lawyer: lawyer));
      }
    } catch (e) {
      _showError("Something went wrong");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<String> uploadImageToSupabase(File imageFile, String uid) async {
    final supabase = Supabase.instance.client;
    final bytes = await imageFile.readAsBytes();
    final fileName = '$uid.jpg'; // Save using UID
    final path = 'profile_pics/$fileName';

    final response = await supabase.storage
        .from('imagges')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    print("Upload response: $response");

    if (response.isEmpty) throw Exception("Upload failed");

    final publicUrl = supabase.storage.from('imagges').getPublicUrl(path);
    return publicUrl;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
