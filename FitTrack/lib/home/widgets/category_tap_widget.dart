import 'package:flutter/material.dart';

enum HomeTab { exercise, nutrition }

class CategoryTapWidget extends StatelessWidget {
  final HomeTab selectedTab;
  final Function(HomeTab) onTabSelected;

  const CategoryTapWidget({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Row(
        children: [

          Expanded(
            child: _buildTab(
              label: "Exercise",
              tab: HomeTab.exercise,
            ),
          ),

          SizedBox(width: size.width * 0.04),

          Expanded(
            child: _buildTab(
              label: "Nutrition & Supplements",
              tab: HomeTab.nutrition,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required HomeTab tab,
  }) {

    final bool isSelected = selectedTab == tab;

    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () => onTabSelected(tab),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD0FD3E)
              : Colors.white10,

          borderRadius: BorderRadius.circular(25),
        ),

        alignment: Alignment.center,

        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,

          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}