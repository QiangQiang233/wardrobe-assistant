import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';

class OutfitAdviceScreen extends StatefulWidget {
  const OutfitAdviceScreen({super.key});

  @override
  State<OutfitAdviceScreen> createState() => _OutfitAdviceScreenState();
}

class _OutfitAdviceScreenState extends State<OutfitAdviceScreen> {
  final _dbService = DatabaseService();
  final _scenarioController = TextEditingController();
  final _picker = ImagePicker();
  File? _userPhoto;
  String _advice = '';
  bool _isLoading = false;
  bool _useOfflineMode = true;

  Future<void> _pickUserPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _userPhoto = File(picked.path));
    }
  }

  Future<void> _takeUserPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _userPhoto = File(picked.path));
    }
  }

  Future<void> _getAdvice() async {
    if (_scenarioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请描述穿搭场景')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _advice = '';
    });

    // 获取衣橱数据
    final items = await _dbService.getAllClothingItems();
    final wardrobe = items.map((i) => {
      'name': i.name,
      'category': i.category,
      'color': i.color,
      'style': i.style,
      'season': i.season,
    }).toList();

    String result;
    if (_useOfflineMode) {
      result = await AIService.getOfflineAdvice(
        scenario: _scenarioController.text,
        wardrobe: wardrobe,
      );
    } else {
      result = await AIService.getOutfitAdvice(
        userPhoto: _userPhoto?.path ?? '',
        scenario: _scenarioController.text,
        wardrobe: wardrobe,
      );
    }

    setState(() {
      _advice = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('穿搭建议'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 用户照片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('你的人像照片', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _userPhoto != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_userPhoto!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person, size: 50, color: Colors.grey[400]),
                                  Text('添加照片', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 场景描述
            TextField(
              controller: _scenarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '穿搭场景',
                hintText: '例如：明天有个面试，需要正式一点的穿搭\n或者：周末约会，想要休闲又好看的风格',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // 模式切换
            Row(
              children: [
                Checkbox(
                  value: _useOfflineMode,
                  onChanged: (v) => setState(() => _useOfflineMode = v!),
                ),
                const Text('使用离线模式（无需API Key）'),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // 显示 API Key 设置说明
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('API 设置'),
                        content: const Text(
                          '要使用 AI 智能建议，请在 lib/services/ai_service.dart 中填入你的 API Key。\n\n'
                          '当前离线模式会根据你的衣橱数据生成基础建议。'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('知道了'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('如何配置 AI？'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 获取建议按钮
            ElevatedButton(
              onPressed: _isLoading ? null : _getAdvice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('获取穿搭建议', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),

            // 建议结果
            if (_advice.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              Card(
                color: Colors.deepPurple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text(
                            'AI 穿搭建议',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _advice,
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _takeUserPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickUserPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scenarioController.dispose();
    super.dispose();
  }
}