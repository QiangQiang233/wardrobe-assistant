import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/clothing_item.dart';
import '../services/database_service.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _category = '上装';
  String _color = '白色';
  String _style = '休闲';
  String _season = '春秋';
  File? _imageFile;
  final _picker = ImagePicker();
  final _dbService = DatabaseService();

  final List<String> _categories = ['上装', '下装', '外套', '鞋子', '配饰'];
  final List<String> _colors = ['白色', '黑色', '灰色', '蓝色', '红色', '绿色', '黄色', '粉色', '棕色', '其他'];
  final List<String> _styles = ['休闲', '正式', '运动', '时尚', '简约', '复古'];
  final List<String> _seasons = '春夏,春秋,秋冬,冬,四季'.split(',');

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveClothing() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      final item = ClothingItem(
        name: _nameController.text,
        category: _category,
        color: _color,
        style: _style,
        season: _season,
        imagePath: _imageFile!.path,
        createdAt: DateTime.now(),
      );

      await _dbService.insertClothingItem(item);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('衣服添加成功！')),
        );
        Navigator.pop(context);
      }
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请添加衣服照片')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加衣服'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 图片选择区域
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('点击添加照片', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 衣服名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '衣服名称',
                  hintText: '例如：白色T恤、黑色西装裤',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入衣服名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 分类
              _buildDropdown('分类', _category, _categories, (v) => setState(() => _category = v!)),
              const SizedBox(height: 16),

              // 颜色
              _buildDropdown('颜色', _color, _colors, (v) => setState(() => _color = v!)),
              const SizedBox(height: 16),

              // 风格
              _buildDropdown('风格', _style, _styles, (v) => setState(() => _style = v!)),
              const SizedBox(height: 16),

              // 季节
              _buildDropdown('季节', _season, _seasons, (v) => setState(() => _season = v!)),
              const SizedBox(height: 30),

              // 保存按钮
              ElevatedButton(
                onPressed: _saveClothing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('保存到衣橱', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _showImagePickerOptions() {
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
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}