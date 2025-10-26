import 'package:flutter/material.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/main.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/operations/notedetailpage.dart';
import '../core/constant/imgaeasset.dart';
import '../l10n/generated/app_localizations.dart';

class ShopPage extends StatefulWidget {
  final String category;

  const ShopPage({Key? key, required this.category}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Crud crud = Crud();

  getNotes() async {
    var response = await crud.postRequest(viewNoteLink, {
      "userId": sharedPref.getString("user_id")!
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('${widget.category} Carpets'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: getNotes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColor.primaryColor,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
                  SizedBox(height: 16),
                  Text(
                    "${l10n.error}: ${snapshot.error}",
                    style: TextStyle(color: AppColor.warningColor),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data["status"] != "success" ||
              snapshot.data["data"] == null ||
              snapshot.data["data"].isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 64,
                    color: AppColor.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          List<dynamic> notes = snapshot.data["data"];

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: notes.length,
            itemBuilder: (context, i) {
              final note = notes[i];
              String? imageUrl;

              if (note['note_image'] != null &&
                  note['note_image'].toString().isNotEmpty) {
                imageUrl = imageBaseUrl + note['note_image'];
              }

              return ProductCard(
                noteId: note['note_id'].toString(),
                onTap: () {
                  String? fullImageUrl;
                  if (note['note_image'] != null &&
                      note['note_image'].toString().isNotEmpty) {
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
                onFavoriteChanged: () {
                  setState(() {});
                },
                title: "Traditional Persian Carpet",
                content: "Beautiful handmade carpet 5x8 ft",
                imageAsset: AppImageAsset.cardImage,
              );
            },
          );
        },
      ),
    );
  }
}