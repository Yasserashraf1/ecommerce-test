import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import '../component/button.dart';
import '../component/textformfield.dart';
import '../l10n/generated/app_localizations.dart';



class EditNotePage extends StatefulWidget {
  final String noteId;
  final String title;
  final String content;
  final String? imageUrl;

  const EditNotePage({
    Key? key,
    required this.noteId,
    required this.title,
    required this.content,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Crud crud = Crud();
  bool isLoading = false;
  File? _newSelectedImage;
  bool _imageChanged = false;
  bool _removeCurrentImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    contentController.text = widget.content;
  }

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
          _newSelectedImage = File(pickedFile.path);
          _imageChanged = true;
          _removeCurrentImage = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.errorPickingImage}: $e")),
      );
    }
  }

  void _showImageOptions() {
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
                l10n.imageOptions,
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
                  if (widget.imageUrl != null || _newSelectedImage != null)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _removeCurrentImage = true;
                          _newSelectedImage = null;
                          _imageChanged = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.delete, size: 40, color: Colors.red),
                            SizedBox(height: 8),
                            Text(l10n.remove, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
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

  editNote() async {
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

    if (_imageChanged && _newSelectedImage != null) {
      // Edit note with new image
      response = await crud.postRequestWithFile(editNoteLink, {
        "noteId": widget.noteId,
        "title": titleController.text,
        "content": contentController.text,
      }, _newSelectedImage!);
    } else {
      // Edit note without changing image (or removing it)
      Map<String, String> data = {
        "noteId": widget.noteId,
        "title": titleController.text,
        "content": contentController.text,
      };

      if (_removeCurrentImage) {
        data["removeImage"] = "true";
      }

      response = await crud.postRequest(editNoteLink, data);
    }

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noteUpdatedSuccessfully)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.failedToUpdateNote}: ${response['message'] ?? 'Unknown error'}")),
      );
    }
  }

  deleteNote() async {
    final l10n = AppLocalizations.of(context);

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.remove),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        isLoading = true;
      });

      var response = await crud.postRequest(deleteNoteLink, {
        "noteId": widget.noteId,
      });

      setState(() {
        isLoading = false;
      });

      if (response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noteDeletedSuccessfully)),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${l10n.failedToDeleteNote}: ${response['message'] ?? 'Unknown error'}")),
        );
      }
    }
  }

  Widget _buildImageSection() {
    final l10n = AppLocalizations.of(context);

    if (_removeCurrentImage) {
      // Show add image placeholder when current image is marked for removal
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: InkWell(
          onTap: _showImageOptions,
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
      );
    }

    if (_newSelectedImage != null) {
      // Show new selected image
      return Container(
        height: 200,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _newSelectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _newSelectedImage = null;
                        _imageChanged = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // Show current image from server
      return Container(
        height: 200,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                        Text(l10n.failedToUploadImage, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show add image placeholder when no image exists
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: _showImageOptions,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.editNote),
        actions: [
          IconButton(
            onPressed: deleteNote,
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 20),

            // Image Section
            _buildImageSection(),

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
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Button(
              title: l10n.updateNote,
              onpressed: editNote,
            ),
          ],
        ),
      ),
    );
  }

}


/*
                        try {
                          // Method 1: Fixed SQL (removed extra comma)
                          /*
                          int response = await sqlDb.updateData(
                              """
                              UPDATE notes SET
                              note="${noteTxt.text}",
                              title="${titleTxt.text}",
                              color="${colorTxt.text}"
                              WHERE id = ${widget.id}
                          """
                          );
                          */


                          // Method 2: Better approach - using safe parameterized update
                          int response = await sqlDb.updateNote(
                            id: int.parse(widget.id.toString()),
                            note: noteTxt.text,
                            title: titleTxt.text,
                            color: colorTxt.text.isEmpty ? 'blue' : colorTxt.text,
                          );

                          if (response > 0) {
                            Navigator.of(context).pop(true); // Return true to indicate success
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Note updated successfully!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No changes were made')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error updating note: $e')),
                          );
                        }
                        */
