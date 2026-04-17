import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  final ScrollController _scrollController = ScrollController();

  final double itemWidth = 75;
  final double itemSpacing = 12;
  final double horizontalPadding = 16;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedDate();
    });
  }

  @override
  void didUpdateWidget(covariant DateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!isSameDate(oldWidget.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerSelectedDate();
      });
    }
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime> _getMonthDates() {
    final lastDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + 1,
      0,
    );

    return List.generate(
      lastDay.day,
      (index) => DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        index + 1,
      ),
    );
  }

  void _centerSelectedDate() {
    if (!_scrollController.hasClients) return;

    final selectedIndex = widget.selectedDate.day - 1;
    final screenWidth = MediaQuery.of(context).size.width;

    final totalItemWidth = itemWidth + itemSpacing;

    double offset =
        (selectedIndex * totalItemWidth) -
        (screenWidth / 2) +
        (itemWidth / 2) +
        horizontalPadding;

    offset = offset.clamp(0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    final monthDates = _getMonthDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// MONTH TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            DateFormat('MMMM yyyy').format(widget.selectedDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

       SizedBox(height: size.height * 0.02), 

        SizedBox(
          height:size.height * 0.10,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: monthDates.length,
            itemBuilder: (context, index) {
              final date = monthDates[index];

              final bool isSelected = isSameDate(date, widget.selectedDate);

              return GestureDetector(
                onTap: () {
                  widget.onDateSelected(date);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      /// DATE CARD
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: itemWidth,
                        height: size.height * 0.08,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD0FD3E)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white70,
                              ),
                            ),
                         SizedBox(height: size.height * 0.00), 
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                     SizedBox(height: size.height * 0.01), 

                      if (isSelected)
                        Container(
                          width: size.width * 0.01,
                          height: size.height * 0.01,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD0FD3E),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
