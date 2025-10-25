import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/main.dart';
import 'package:naseej/operations/addNote.dart';
import 'package:naseej/component/cardnote.dart';
import 'package:naseej/operations/notedetailpage.dart';
import 'package:naseej/component/app_drawer.dart';
import 'package:naseej/utils/favorites_manager.dart';
import '../l10n/generated/app_localizations.dart';
import '../operations/edit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Crud crud = Crud();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize favorites manager with current user
    final userId = sharedPref.getString("user_id");
    if (userId != null) {
      FavoritesManager.setCurrentUser(userId);
    }
  }

  getNotes() async {
    var response = await crud.postRequest(viewNoteLink, {
      "userId": sharedPref.getString("user_id")!
    });
    return response;
  }

  Future<void> _pickAndUploadImage(String noteId, ImageSource source, int? noteIndex) async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        OverlayEntry? overlayEntry;
        overlayEntry = OverlayEntry(
          builder: (context) => Material(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(30),
                margin: EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      l10n.uploadingImage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        Overlay.of(context).insert(overlayEntry);

        File imageFile = File(pickedFile.path);

        var response = await crud.postRequestWithFile(
          uploadImageLink,
          {"noteId": noteId},
          imageFile,
        );

        overlayEntry.remove();

        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.imageUploadedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToUploadImage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorPickingImage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _removeImage(String noteId, int? noteIndex) async {
    final l10n = AppLocalizations.of(context);

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.remove),
        content: Text(l10n.confirmRemoveImage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.remove, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      var response = await crud.postRequest(removeImageLink, {
        "noteId": noteId,
      });

      if (response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageRemovedSuccessfully),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToRemoveImage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myNotes),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(builder: (context) => AddNotePage()),
        //       ).then((result) {
        //         if (result == true) {
        //           setState(() {});
        //         }
        //       });
        //     },
        //     icon: Icon(Icons.add),
        //   )
        // ],
      ),
      drawer: AppDrawer(
        onFavoritesChanged: () {
          setState(() {}); // Refresh the home page when favorites change
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddNotePage()),
          ).then((result) {
            if (result == true) {
              setState(() {});
            }
          });
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: getNotes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("${l10n.error}: ${snapshot.error}"));
            }

            if (!snapshot.hasData ||
                snapshot.data["status"] != "success" ||
                snapshot.data["data"] == null ||
                snapshot.data["data"].isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(l10n.noNotesYet, style: TextStyle(fontSize: 18, color: Colors.grey)),
                    Text(l10n.tapToAddFirstNote),
                  ],
                ),
              );
            }

            List<dynamic> notes = snapshot.data["data"];

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, i) {
                final note = notes[i];
                String? imageUrl;

                if (note['note_image'] != null && note['note_image'].toString().isNotEmpty) {
                  imageUrl = imageBaseUrl + note['note_image'];
                }

                return CardNote(
                  noteId: note['note_id'].toString(),
                  onTap: () {
                    String? fullImageUrl;
                    if (note['note_image'] != null && note['note_image'].toString().isNotEmpty) {
                      fullImageUrl = imageBaseUrl + note['note_image'];
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteDetailPage(
                          noteId: note['note_id'].toString(),
                          title: note['note_title'],
                          content: note['note_content'],
                          imageUrl: fullImageUrl,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        setState(() {});
                      }
                    });
                  },
                  onImageTap: () {
                    _showImagePickerDialog(context, note['note_id'].toString(), i);
                  },
                  onFavoriteChanged: () {
                    setState(() {}); // Refresh the UI when favorite status changes
                  },
                  title: "${note['note_title']}",
                  content: "${note['note_content']}",
                  imageUrl: imageUrl,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context, String noteId, int noteIndex) {
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
                      _pickAndUploadImage(noteId, ImageSource.camera, noteIndex);
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
                          Text(
                            l10n.camera,
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(noteId, ImageSource.gallery, noteIndex);
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
                          Text(
                            l10n.gallery,
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage(noteId, noteIndex);
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
                          Text(
                            l10n.gallery,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
}