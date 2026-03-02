import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../models/clothing_item.dart';
import '../services/database_service.dart';

class VirtualTryonScreen extends StatefulWidget {
  const VirtualTryonScreen({super.key});

  @override
  State<VirtualTryonScreen> createState() => _VirtualTryonScreenState();
}

class _VirtualTryonScreenState extends State<VirtualTryonScreen> {
  final _dbService = DatabaseService();
  final _picker = ImagePicker();
  File? _userPhoto;
  ClothingItem? _selectedTop;
  ClothingItem? _selectedBottom;
  Uint8List? _resultImage;
  bool _isProcessing = false;

  Future<void> _pickUserPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _userPhoto = File(picked.path);
        _resultImage = null;
      });
    }
  }

  Future<void> _selectClothingItem(String category) async {
    final items = await _dbService.getClothingItemsByCategory(category);
    if (items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('衣橱里没有${category}，请先添加')),
        );
      }
      return;
    }

    if (!mounted) return;
    final selected = await showDialog<ClothingItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择$category'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: File(item.imagePath).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(File(item.imagePath), fit: BoxFit.cover),
                        )
                      : Icon(Icons.image, color: Colors.grey[400]),
                ),
                title: Text(item.name),
                subtitle: Text('${item.color} · ${item.style}'),
                onTap: () => Navigator.pop(context, item),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        if (category == '上装' || category == '外套') {
          _selectedTop = selected;
        } else if (category == '下装') {
          _selectedBottom = selected;
        }
        _resultImage = null;
      });
    }
  }

  Future<void> _generateTryonImage() async {
    if (_userPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先上传你的人像照片')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // 模拟处理延迟
    await Future.delayed(const Duration(seconds: 2));

    // 简单的图片合成演示
    // 实际项目中这里应该调用 AI 图像生成 API
    try {
      final userBytes = await _userPhoto!.readAsBytes();
      final userImage = img.decodeImage(userBytes);

      if (userImage != null) {
        // 创建一个带文字说明的合成图
        final composite = img.copyResize(userImage, width: 400);
        
        // 添加文字说明（实际项目中这里应该做真正的AI合成）
        img.drawString(
          composite,
          '虚拟试衣效果',
          font: img.arial14,
          x: 10,
          y: 10,
          color: img.ColorRgba8(255, 255, 255, 255),
        );

        if (_selectedTop != null) {
          img.drawString(
            composite,
            '上衣: ${_selectedTop!.name}',
            font: img.arial14,
            x: 10,
            y: 30,
            color: img.ColorRgba8(255, 200, 200, 255),
          );
        }

        if (_selectedBottom != null) {
          img.drawString(
            composite,
            '下装: ${_selectedBottom!.name}',
            font: img.arial14,
            x: 10,
            y: 50,
            color: img.ColorRgba8(200, 200, 255, 255),
          );
        }

        setState(() {
          _resultImage = Uint8List.fromList(img.encodeJpeg(composite));
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('虚拟试衣'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 人像照片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('你的人像照片', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickUserPhoto,
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
                                  Text('点击上传', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 服装选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('选择服装', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildClothingSelector(
                            '上装/外套',
                            _selectedTop,
                            () => _selectClothingItem('上装'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildClothingSelector(
                            '下装',
                            _selectedBottom,
                            () => _selectClothingItem('下装'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 生成按钮
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _generateTryonImage,
              icon: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_fix_high),
              label: Text(_isProcessing ? '生成中...' : '生成试衣效果'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // 结果展示
            if (_resultImage != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '试衣效果',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_resultImage!),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '💡 提示：当前版本为基础演示。\n完整的 AI 试衣需要接入图像生成 API。',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _buildClothingSelector(String label, ClothingItem? item, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: item != null
            ? Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: File(item.imagePath).existsSync()
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.file(File(item.imagePath), fit: BoxFit.cover),
                            )
                          : Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.grey[400]),
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
      ),
    );
  }
}