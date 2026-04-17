import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FoodAIService {
  static Future<Map<String, dynamic>?> analyzeFood(File image) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://abi3420-my-aiserver.hf.space/analyze-food"),
      );

      request.files.add(await http.MultipartFile.fromPath("file", image.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);

        /// ❌ NO FOOD DETECTED
        if (data["food"] == null &&
            (data["foods"] == null || data["foods"].isEmpty)) {
          return null;
        }

        /// ✅ SINGLE FOOD
        if (data["food"] != null) {
          return {
            "name": data["food"],
            "calories": data["calories"] ?? 0,
            "protein": data["protein"] ?? 0,
            "carbs": data["carbs"] ?? 0,
          };
        }

        /// ✅ MULTI FOOD (first item)
        if (data["foods"] != null && data["foods"].isNotEmpty) {
          final first = data["foods"][0];

          return {
            "name": first["name"],
            "calories": first["calories"] ?? 0,
            "protein": first["protein"] ?? 0,
            "carbs": first["carbs"] ?? 0,
            "foods": data["foods"], // full list
          };
        }
      }

      return null;
    } catch (e) {
      print("AI ERROR: $e");
      return null;
    }
  }
}