# ClassicPod Music

一个自己用的 SwiftUI 原生 iOS 音乐播放器原型：界面是 iPod 风格，并加入 iOS 26 Liquid Glass 视觉方向；数据通过 Apple Music / MusicKit 读取你的音乐资料库。

## 你需要什么

- 一台能运行 Xcode 的 Mac，或者云 Mac 构建环境。
- iPhone 上已经登录 Apple Music，并且资料库里有歌曲。
- Apple Developer 账号。免费账号可以真机调试，但安装签名通常会过期；长期自用建议使用付费开发者账号。

## 在 Xcode 里运行

1. 用 Xcode 打开 `ClassicPodMusic.xcodeproj`。
2. 选中 `ClassicPodMusic` target，进入 `Signing & Capabilities`。
3. 选择你的 Team。
4. 把 Bundle Identifier 改成你自己的唯一值，例如 `com.yourname.ClassicPodMusic`。
5. 添加或确认 `MusicKit` capability。
6. 插上 iPhone，选择真机运行。
7. 第一次打开 App 时允许 Apple Music 访问权限。

## 不打开 Xcode 生成 IPA

如果你只想拿到一个可重签的 IPA，不想打开 Xcode，可以看 `BUILD_IPA_WITHOUT_MAC_CN.md`。我已经加了 GitHub Actions 工作流：它会在云端 macOS runner 上构建 `dist/ClassicPodMusic-unsigned.ipa`，你再用自己的证书和 profile 重签安装。

## 已实现

- Apple Music 授权请求。
- 使用 MusicKit 读取用户曲库歌曲。
- 歌曲列表、当前播放页、封面显示。
- 播放、暂停、上一首、下一首。
- iPhone 16 Pro 竖屏比例下的播放器布局。
- iOS 26 `glassEffect` 原生玻璃效果，以及旧系统上的 material fallback。
- 经典播放器风格机身和点击轮界面。
- 本地审查记录：`REVIEW_NOTES.md`。

## 注意

- Windows 无法完成最终 iOS 编译、签名和安装；这一步仍然需要 Xcode/macOS。
- MusicKit 只能访问 Apple 允许的媒体资料库内容。订阅状态、地区、DRM、云资料库开关都会影响读取和播放。
- 如果你只用免费 Apple ID 真机安装，过一段时间可能需要重新安装。
