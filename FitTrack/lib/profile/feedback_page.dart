import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackPage extends StatefulWidget {
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  Map<String, bool> issues = {
    "Not enough exercise variety": false,
    "Exercise instructions are unclear": false,
    "Too many steps to log a workout": false,
    "Difficulty level doesn’t match my fitness level": false,
    "Layout/design feels confusing": false,
    "Too many ads / interruptions": false,
    "Others": false,
  };

  TextEditingController controller = TextEditingController();

  /// 🚀 SAVE FUNCTION
  Future<void> saveFeedback(List<String> selectedIssues, String message) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('feedback').insert({
        'issues': selectedIssues,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Feedback sent 💪")));

      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🌈 GRADIENT BACKGROUND
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2E05), Colors.black],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                /// 🔙 HEADER
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Feedback",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                /// 📝 ICON
                Icon(Icons.feedback, size: 60, color: Color(0xFFD0FD3E)),

                SizedBox(height: 20),

                /// ✅ CHECKBOX LIST
                Expanded(
                  child: ListView(
                    children: issues.keys.map((text) {
                      return CheckboxListTile(
                        value: issues[text],
                        activeColor: Color(0xFFD0FD3E),
                        checkColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            issues[text] = value!;
                          });
                        },
                        title: Text(
                          text,
                          style: TextStyle(color: Colors.white),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ),

                /// ✍️ TEXT BOX
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        style: TextStyle(color: Colors.white),
                        onChanged: (_) {
                          setState(() {}); // button update
                        },
                        decoration: InputDecoration(
                          hintText: "Tell us more about your issues",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD0FD3E),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        List<String> selected = issues.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();

                        /// ❌ message empty
                        if (controller.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please enter your feedback message",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        /// ❌ no checkbox
                        if (selected.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please select at least one issue"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        /// ✅ save
                        await saveFeedback(selected, controller.text);
                      },
                      child: Text(
                        "Send Feedback",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
