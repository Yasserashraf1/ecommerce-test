import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/main.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/operations/notedetailpage.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Crud crud = Crud();
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': AppColor.primaryColor},
    {'name': 'Traditional', 'icon': Icons.architecture, 'color': AppColor.secondColor},
    {'name': 'Modern', 'icon': Icons.filter_none, 'color': AppColor.goldAccent},
    {'name': 'Vintage', 'icon': Icons.history, 'color': AppColor.earthBrown},
    {'name': 'Custom', 'icon': Icons.palette, 'color': AppColor.bronzeAccent},
  ];

  getNotes() async {
    var response = await crud.postRequest(viewNoteLink, {
      "userId": sharedPref.getString("user_id")!
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            backgroundColor: AppColor.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Explore',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColor.primaryColor, AppColor.secondColor],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF2C2520) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search carpets...',
                    prefixIcon: Icon(Icons.search, color: AppColor.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.filter_list, color: AppColor.primaryColor),
                      onPressed: () {
                        // Show filter dialog
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'] as String;
                      });
                    },
                    child: Container(
                      width: 90,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                          colors: [
                            category['color'] as Color,
                            (category['color'] as Color).withOpacity(0.7),
                          ],
                        )
                            : null,
                        color: isSelected ? null : (isDark ? Color(0xFF2C2520) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (category['color'] as Color).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: (category['color'] as Color).withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : (category['color'] as Color),
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColor.backgroundcolor : AppColor.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Products Title
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 16, color: AppColor.primaryColor),
                        SizedBox(width: 4),
                        Text(
                          'Sort',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products Grid
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: FutureBuilder(
              future: getNotes(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text('Error loading products'),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data["status"] != "success" ||
                    snapshot.data["data"] == null ||
                    snapshot.data["data"].isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text('No products found'),
                    ),
                  );
                }

                List<dynamic> notes = snapshot.data["data"];

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
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
                        title: "${note['note_title']}",
                        content: "${note['note_content']}",
                        imageUrl: imageUrl,
                      );
                    },
                    childCount: notes.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}