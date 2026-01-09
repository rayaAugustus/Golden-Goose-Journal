# 快速启动指南

## 🚀 5分钟快速开始

### 前置要求

确保你已经安装：
- Flutter SDK 3.10.4 或更高版本
- Android Studio 或 VS Code
- Git

### 步骤 1: 克隆项目

```bash
git clone <repository-url>
cd golden_goose_journal
```

### 步骤 2: 安装依赖

```bash
flutter pub get
```

### 步骤 3: 运行应用

```bash
# 查看可用设备
flutter devices

# 运行到指定设备
flutter run

# 或者指定设备
flutter run -d <device-id>
```

## 📱 功能演示流程

### 第一次使用

1. **写第一篇成功日记**
   - 打开应用，点击"写日记"
   - 填写3个成功（可以点击"示例"快速填充）
   - 选择心情和标签（可选）
   - 点击"完成"

2. **创建72小时挑战**
   - 完成日记后会提示创建挑战
   - 或者在"挑战"标签页点击"新建挑战"
   - 输入挑战标题和最小动作
   - 可以使用快捷模板
   - 点击"创建"

3. **创建梦想**
   - 进入"梦想"标签页
   - 点击"新建梦想"
   - 添加封面图（可选）
   - 输入标题、目标金额和日期
   - 写下为什么想要它（可选）
   - 点击"创建"

4. **存入梦想罐**
   - 在梦想详情页点击"存一笔"
   - 选择快捷金额或自定义
   - 选择来源和备注（可选）
   - 点击"确认存入"

## 🎯 核心功能测试

### 测试成功日记
```
1. 进入"日记"标签
2. 点击"写日记"
3. 填写3个成功
4. 查看连续天数是否增加
5. 点击"成功回顾"查看随机成功
```

### 测试72小时挑战
```
1. 进入"挑战"标签
2. 创建一个新挑战
3. 查看倒计时是否正常
4. 点击"完成"填写证据
5. 查看是否出现存入提示
```

### 测试梦想储蓄
```
1. 进入"梦想"标签
2. 创建一个梦想
3. 点击梦想卡片查看详情
4. 点击"存一笔"
5. 查看进度条是否更新
```

## 🔧 开发模式

### 热重载
在应用运行时，修改代码后：
- 按 `r` 进行热重载
- 按 `R` 进行热重启
- 按 `q` 退出

### 调试模式
```bash
# 启用调试模式
flutter run --debug

# 查看日志
flutter logs
```

### 性能分析
```bash
# 启用性能分析
flutter run --profile
```

## 📊 数据查看

### 查看数据库
数据库位置：
- Android: `/data/data/com.example.golden_goose_journal/databases/golden_goose.db`
- iOS: `Library/Application Support/golden_goose.db`

使用工具：
- [DB Browser for SQLite](https://sqlitebrowser.org/)
- Android Studio 的 Database Inspector

### 查看日志
```bash
# 实时查看日志
flutter logs

# 过滤日志
flutter logs | grep "DatabaseService"
```

## 🐛 常见问题解决

### 问题 1: 依赖安装失败
```bash
# 清理缓存
flutter clean
flutter pub cache repair
flutter pub get
```

### 问题 2: 构建失败
```bash
# 检查Flutter环境
flutter doctor -v

# 更新Flutter
flutter upgrade
```

### 问题 3: 模拟器无法启动
```bash
# 列出所有模拟器
flutter emulators

# 启动指定模拟器
flutter emulators --launch <emulator-id>
```

### 问题 4: 热重载不工作
```bash
# 完全重启应用
按 R 键或重新运行 flutter run
```

## 📝 开发建议

### 推荐的开发工具
- **IDE**: VS Code + Flutter插件 或 Android Studio
- **调试**: Flutter DevTools
- **数据库**: DB Browser for SQLite
- **API测试**: Postman (如果有后端)
- **版本控制**: Git + GitHub Desktop

### 推荐的VS Code插件
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Error Lens

### 代码片段
在VS Code中输入：
- `stless` - 创建StatelessWidget
- `stful` - 创建StatefulWidget
- `build` - 创建build方法

## 🎨 UI调试

### 查看布局边界
```dart
// 在main.dart中添加
MaterialApp(
  debugShowCheckedModeBanner: false,
  showPerformanceOverlay: true, // 显示性能叠加层
  // ...
)
```

### 查看Widget树
在DevTools中：
1. 运行应用
2. 打开 `http://localhost:9100`
3. 选择 Widget Inspector

## 📦 构建发布版本

### Android APK
```bash
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle
```bash
flutter build appbundle --release
# 输出: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# 然后在Xcode中打开项目进行签名
```

## 🔄 更新依赖

```bash
# 查看过期的包
flutter pub outdated

# 更新所有包
flutter pub upgrade

# 更新特定包
flutter pub upgrade package_name
```

## 📚 学习资源

### 官方文档
- [Flutter文档](https://flutter.dev/docs)
- [Dart语言教程](https://dart.dev/guides)
- [Provider状态管理](https://pub.dev/packages/provider)

### 推荐教程
- Flutter官方Codelabs
- Flutter中文网
- YouTube: The Net Ninja - Flutter Tutorial

### 社区
- [Flutter中文社区](https://flutter.cn/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Discussions](https://github.com/flutter/flutter/discussions)

## 💡 下一步

1. **熟悉代码结构** - 阅读 `DEVELOPMENT.md`
2. **尝试修改UI** - 调整颜色、字体等
3. **添加新功能** - 参考开发指南
4. **提交PR** - 贡献你的代码

## 🆘 获取帮助

遇到问题？
1. 查看 [常见问题](#-常见问题解决)
2. 阅读 [开发文档](DEVELOPMENT.md)
3. 提交 [Issue](https://github.com/your-repo/issues)
4. 加入社区讨论

---

**祝你开发愉快！** 🎉
