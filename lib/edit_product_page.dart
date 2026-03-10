import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

const String baseUrl =
    "http://127.0.0.1/flutter_product_image/php_api/";

class EditProductPage extends StatefulWidget {
  final dynamic product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {

  late TextEditingController fnameController;
  late TextEditingController lnameController;
  late TextEditingController phoneController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  XFile? selectedImage;

  @override
  void initState() {
    super.initState();

    fnameController =
        TextEditingController(text: widget.product['fname']);
    lnameController =
        TextEditingController(text: widget.product['lname']);

    phoneController =
        TextEditingController(text: widget.product['phone']);

    usernameController =
        TextEditingController(text: widget.product['username']);
    passwordController =
        TextEditingController(text: widget.product['password']);
  }

  ////////////////////////////////////////////////////////////
  // ✅ PICK IMAGE
  ////////////////////////////////////////////////////////////

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UPDATE PRODUCT + IMAGE
  ////////////////////////////////////////////////////////////

  Future<void> updateProduct() async {
    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl}update_product_with_image.php"),
      );

      ////////////////////////////////////////////////////////
      // ✅ Fields
      ////////////////////////////////////////////////////////

      request.fields['id'] = widget.product['id'].toString();
      request.fields['fname'] = fnameController.text;
      request.fields['lname'] = lnameController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['username'] = usernameController.text;
      request.fields['password'] = passwordController.text;
      request.fields['old_image'] = widget.product['image'];

      ////////////////////////////////////////////////////////
      // ✅ Image (ถ้ามี)
      ////////////////////////////////////////////////////////

      if (selectedImage != null) {

        if (kIsWeb) {

          final bytes = await selectedImage!.readAsBytes();

          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: selectedImage!.name,
            ),
          );

        } else {

          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              selectedImage!.path,
            ),
          );
        }
      }

      ////////////////////////////////////////////////////////
      // ✅ Send
      ////////////////////////////////////////////////////////

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      final data = json.decode(responseData);

      if (data["success"] == true) {

        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขเรียบร้อย")),
        );
      }

    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    String imageUrl =
        "${baseUrl}images/${widget.product['image']}";

    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขนักศึกษา")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [

              //////////////////////////////////////////////////
              // 🖼 IMAGE PREVIEW
              //////////////////////////////////////////////////

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: selectedImage == null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : kIsWeb
                          ? Image.network(
                              selectedImage!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: fnameController,
                decoration: const InputDecoration(labelText: "ชื่อ"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: lnameController,
                decoration: const InputDecoration(labelText: "นามสกุล"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "เบอร์โทรศัพท์"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "username"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "password"),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateProduct,
                  child: const Text("บันทึก"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}