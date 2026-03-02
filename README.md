# 穿搭助手 - AI 智能穿搭应用

一个帮助你管理衣橱、获取穿搭建议的 Flutter 应用。

## 功能特点

- 👕 **服装仓库**：拍照上传衣服，自动分类管理
- 🤖 **AI 穿搭建议**：根据场景智能推荐搭配
- 🎨 **虚拟试衣**：预览穿搭效果
- 💾 **本地存储**：数据保存在本地，保护隐私

## 截图

（待添加）

## 快速开始

### 环境要求

- Flutter SDK 3.0+
- Android Studio / VS Code
- Android SDK

### 安装步骤

1. **克隆项目**
   ```bash
   cd wardrobe_assistant
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   flutter run
   ```

### 构建 APK

```bash
# 开发版 APK
flutter build apk

# 发布版 APK
flutter build apk --release

# 输出路径: build/app/outputs/flutter-apk/app-release.apk
```

## 项目结构

```
wardrobe_assistant/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/
│   │   └── clothing_item.dart    # 衣服数据模型
│   ├── screens/
│   │   ├── home_screen.dart      # 首页
│   │   ├── wardrobe_screen.dart  # 衣橱页面
│   │   ├── add_clothing_screen.dart  # 添加衣服
│   │   ├── outfit_advice_screen.dart # 穿搭建议
│   │   └── virtual_tryon_screen.dart # 虚拟试衣
│   └── services/
│       ├── database_service.dart # 数据库操作
│       └── ai_service.dart       # AI 服务
├── android/                      # Android 配置
├── pubspec.yaml                  # 依赖配置
└── README.md                     # 项目说明
```

## 配置 AI 服务（可选）

当前默认使用离线模式，如需接入 AI API：

1. 打开 `lib/services/ai_service.dart`
2. 将 `YOUR_API_KEY` 替换为你的 Moonshot/Kimi API Key：
   ```dart
   static const String _apiKey = 'sk-your-api-key-here';
   ```
3. 在穿搭建议页面取消勾选"离线模式"

获取 API Key：[Moonshot AI](https://platform.moonshot.cn/)

## 技术栈

- **Flutter** - 跨平台 UI 框架
- **SQLite** - 本地数据库
- **image_picker** - 图片选择/拍照
- **http** - 网络请求

## 待改进功能

- [ ] AI 虚拟试衣（接入图像生成 API）
- [ ] 衣服自动识别分类
- [ ] 穿搭日历/记录
- [ ] 天气联动推荐
- [ ] 云同步备份

## 许可证

MIT License
