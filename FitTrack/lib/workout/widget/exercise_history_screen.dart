// import 'package:flutter/material.dart';

// class ExerciseHistoryScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> workouts;

//   const ExerciseHistoryScreen({super.key, required this.workouts});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("Workout History"),
//         backgroundColor: Colors.black,
//       ),
//       body: workouts.isEmpty
//           ? const Center(
//               child: Text(
//                 "No exercises added",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: workouts.length,
//               itemBuilder: (context, index) {
//                 final item = workouts[index];

//                 return GestureDetector(
//                   onTap: () {
//                     _showHistory(context, item);
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1C1C1E),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Row(
//                       children: [
//                         /// ICON
//                         CircleAvatar(
//                           radius: 25,
//                           backgroundColor: const Color(0xFFD0FD3E),
//                           child: Text(
//                             item["name"][0].toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         /// TEXT
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item["name"],
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 item["description"],
//                                 style: const TextStyle(color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   void _showHistory(BuildContext context, Map<String, dynamic> item) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.black,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           height: 300,
//           child: Column(
//             children: [
//               const Text(
//                 "Workout Details",
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//               const SizedBox(height: 20),
//               Text(item["name"], style: const TextStyle(color: Colors.white)),
//               const SizedBox(height: 10),
//               Text(item["description"],
//                   style: const TextStyle(color: Colors.grey)),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }