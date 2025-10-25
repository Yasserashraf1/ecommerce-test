import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/main.dart';
import '../component/button.dart';
import '../component/textformfield.dart';
import '../l10n/generated/app_localizations.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({Key? key}) : super(key: key);

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Crud crud = Crud();
  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.errorPickingImage}: $e")),
      );
    }
  }

  void _showImagePickerDialog() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectImage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(l10n.camera, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 40, color: Colors.green),
                          SizedBox(height: 8),
                          Text(l10n.gallery, style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  addNote() async {
    final l10n = AppLocalizations.of(context);
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllFields)),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var response;

    if (_selectedImage != null) {
      // Add note with image
      response = await crud.postRequestWithFile(addNoteLink, {
        "title": titleController.text,
        "content": contentController.text,
        "userId": sharedPref.getString("user_id")!,
      }, _selectedImage!);
    } else {
      // Add note without image
      response = await crud.postRequest(addNoteLink, {
        "title": titleController.text,
        "content": contentController.text,
        "userId": sharedPref.getString("user_id")!,
      });
    }

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noteAddedSuccessfully)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.failedToAddNote}: ${response['message'] ?? 'Unknown error'}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.addNote),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 20),

            // Image Preview Section
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _selectedImage != null
                  ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              )
                  : InkWell(
                onTap: _showImagePickerDialog,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                     l10n.tapToAddImage,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            Text(
              l10n.noteTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CustomTextForm(
              hintText: l10n.enterNoteTitle,
              controller: titleController,
            ),
            SizedBox(height: 20),
            Text(
              l10n.noteContent,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: l10n.enterNoteContent,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 30),
            Button(
              title: l10n.addNote,
              isLoading: isLoading,
              onpressed: addNote,
            ),
          ],
        ),
      ),
    );
  }
}
// try {
//   // Using the safer insertion method
//   int response = await sqlDb.insertNote(
//     note: noteTxt.text,
//     title: titleTxt.text,
//     color: colorTxt.text.isEmpty ? 'blue' : colorTxt.text,
//   );
//
//   if (response > 0) {
//     Navigator.of(context).pop(); // Go back to previous screen
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Note added successfully!')),
//     );
//   }
// } catch (e) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text('Error adding note: $e')),
//   );
// }
