import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 使用 Moonshot/Kimi API (用户当前的AI服务)
  static const String _apiKey = 'YOUR_API_KEY'; // 用户需要填入自己的API Key
  static const String _baseUrl = 'https://api.moonshot.cn/v1/chat/completions';

  /// 获取穿搭建议
  static Future<String> getOutfitAdvice({
    required String userPhoto,
    required String scenario,
    required List<Map<String, dynamic>> wardrobe,
  }) async {
    try {
      final wardrobeDescription = wardrobe.map((item) {
        return "${item['category']}: ${item['name']} (${item['color']}, ${item['style']})";
      }).join('\n');

      final prompt = '''你是一个专业的穿搭顾问。请根据以下信息给出穿搭建议：

【穿搭场景】
$scenario

【用户衣橱】
$wardrobeDescription

请给出：
1. 2-3套适合该场景的穿搭方案
2. 每套方案说明搭配理由
3. 可以添加一些小建议（配饰、颜色搭配等）

请用中文回答，格式清晰易读。''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'moonshot-v1-8k',
          'messages': [
            {'role': 'system', 'content': '你是一个专业的时尚穿搭顾问，擅长根据个人特点和场合需求给出实用且时尚的穿搭建议。'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        return '获取建议失败: ${response.statusCode}';
      }
    } catch (e) {
      return '网络错误: $e';
    }
  }

  /// 模拟穿搭建议（离线模式，用于测试）
  static Future<String> getOfflineAdvice({
    required String scenario,
    required List<Map<String, dynamic>> wardrobe,
  }) async {
    // 根据场景和衣橱生成建议
    final tops = wardrobe.where((i) => i['category'] == '上装').toList();
    final bottoms = wardrobe.where((i) => i['category'] == '下装').toList();
    final shoes = wardrobe.where((i) => i['category'] == '鞋子').toList();

    if (tops.isEmpty || bottoms.isEmpty) {
      return '衣橱里的衣服还不够多哦，先添加一些上衣和下装吧！';
    }

    return '''
🎯 穿搭建议（基于"$scenario"）

**方案一：休闲舒适**
- 上衣：${tops.isNotEmpty ? tops[0]['name'] : '白T恤'} (${tops.isNotEmpty ? tops[0]['color'] : '白色'})
- 下装：${bottoms.isNotEmpty ? bottoms[0]['name'] : '牛仔裤'} (${bottoms.isNotEmpty ? bottoms[0]['color'] : '蓝色'})
- ${shoes.isNotEmpty ? '鞋子：${shoes[0]['name']}' : ''}
- 💡 这套搭配简洁大方，适合日常出行。

**方案二：稍微正式**
${tops.length > 1 ? '- 上衣：${tops[1]['name']} (${tops[1]['color']})' : '- 可以搭配一件外套增加层次感'}
${bottoms.length > 1 ? '- 下装：${bottoms[1]['name']} (${bottoms[1]['color']})' : '- 选择深色下装更显稳重'}

---
💬 小贴士：
- 根据天气可适当增减外套
- 配饰如手表、项链可以提升整体造型感

（提示：配置 API Key 后可获得更智能的 AI 建议）
''';
  }
}