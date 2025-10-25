import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/operations/edit.dart';
import '../l10n/generated/app_localizations.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;
  final String title;
  final String content;
  final String? imageUrl;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
    required this.title,
    required this.content,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  Crud crud = Crud();
  final ImagePicker _picker = ImagePicker();
  String? currentImageUrl;

  @override
  void initState() {
    super.initState();
    currentImageUrl = widget.imageUrl;
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
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      var response = await crud.postRequest(deleteNoteLink, {
        "noteId": widget.noteId,
      });

      if (response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteNote),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeImageFromNote() async {
    final l10n = AppLocalizations.of(context);

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removingImage),
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
        "noteId": widget.noteId,
      });

      if (response["status"] == "success") {
        setState(() {
          currentImageUrl = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageRemovedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        // Notify parent that image was changed
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToRemoveImage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadNewImage(ImageSource source) async {
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
          {"noteId": widget.noteId},
          imageFile,
        );

        overlayEntry.remove();

        if (response["status"] == "success") {
          String newImageUrl = response["imageUrl"] ?? "${imageBaseUrl}${response["imageName"]}";
          setState(() {
            currentImageUrl = "$newImageUrl?t=${DateTime.now().millisecondsSinceEpoch}";
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.imageUploadedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          // Notify parent that image was changed
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToUploadImage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorPickingImage),
          backgroundColor: Colors.red,
        ),
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
                  // Camera Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _uploadNewImage(ImageSource.camera);
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

                  // Gallery Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _uploadNewImage(ImageSource.gallery);
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

                  // Remove Image Option (only if image exists)
                  if (currentImageUrl != null && currentImageUrl!.isNotEmpty)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _removeImageFromNote();
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
                              l10n.remove,
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

  void _showFullImage() {
    final l10n = AppLocalizations.of(context);

    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    currentImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.white54),
                          SizedBox(height: 16),
                          Text(
                            l10n.failedToUploadImage,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.noteDetails),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditNotePage(
                    noteId: widget.noteId,
                    title: widget.title,
                    content: widget.content,
                    imageUrl: currentImageUrl,
                  ),
                ),
              ).then((result) {
                if (result == true) {
                  Navigator.of(context).pop(true);
                }
              });
            },
            icon: Icon(Icons.edit, color: Colors.green),
          ),
          IconButton(
            onPressed: deleteNote,
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (currentImageUrl != null && currentImageUrl!.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 20),
                height: 200,
                width: double.infinity,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showFullImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          currentImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
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
                                  SizedBox(height: 8),
                                  Text(
                                      l10n.failedToUploadImage,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
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
                          child: Icon(Icons.more_vert, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
            // Show add image option when no image
              Container(
                margin: EdgeInsets.only(bottom: 20),
                height: 200,
                width: double.infinity,
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
              ),

            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}