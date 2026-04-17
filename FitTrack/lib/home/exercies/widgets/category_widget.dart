import 'package:flutter/material.dart';

class CategoryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Function(String) onCategorySelected;
  final String selectedCategory;
  final bool isToday;

  const CategoryWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedCategory,
    required this.isToday,
  });

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    /// 🔥 FILTER (fix index bug + hide Add for past days)
    final filteredCategories = widget.categories.where((cat) {
      if (cat["title"] == "Add" && !widget.isToday) {
        return false;
      }
      return true;
    }).toList();

    return SizedBox(
      height: size.width * 0.24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),

        /// ✅ CORRECT LENGTH
        itemCount: filteredCategories.length,

        separatorBuilder: (_, _) => SizedBox(width: size.width * 0.03),

        itemBuilder: (context, index) {
          /// ✅ USE FILTERED LIST
          final category = filteredCategories[index];

          final bool isSelected =
              widget.selectedCategory == category["title"];

          /// ===============================
          /// ➕ ADD BUTTON
          /// ===============================
          if (category["title"] == "Add") {
            return GestureDetector(
              onTap: () {
                widget.onCategorySelected("Add");
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.14,
                    height: size.width * 0.14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white10,
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFFD0FD3E),
                    ),
                  ),
                  SizedBox(height: size.height * 0.008),
                  const Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          /// ===============================
          /// 🏋️ NORMAL CATEGORY
          /// ===============================
          return GestureDetector(
            onTap: () {
              widget.onCategorySelected(category["title"]);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.14,
                  height: size.width * 0.14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFD0FD3E)
                        : Colors.white10,
                  ),
                  child: Icon(
                    category["icon"] is IconData
                        ? category["icon"]
                        : IconData(
                            category["icon"],
                            fontFamily: 'MaterialIcons',
                          ),
                    color: isSelected
                        ? Colors.black
                        : const Color(0xFFD0FD3E),
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                SizedBox(
                  width: size.width * 0.18,
                  child: Text(
                    category["title"],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFD0FD3E)
                          : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}