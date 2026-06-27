# 从零到 IPA：没有 Mac 的做法

这份教程适合你的情况：只有 Windows，没有 Mac，不想碰 Xcode，只想最后拿到一个能给爱思助手处理的 IPA。

## 先说清楚

这个项目已经包含 GitHub Actions 云端构建配置。你在 Windows 上只需要用浏览器上传项目，然后让 GitHub 的 macOS 云机器帮你编译 IPA。

本机 Windows 不能直接编译 iOS IPA，因为 IPA 里必须有 Apple iOS SDK 编译出来的 iPhone `arm64` 程序。

## 你会得到什么

GitHub Actions 成功后会生成：

```text
ClassicPodMusic-unsigned.ipa
```

这个 IPA 是真实 iOS App 包，但默认是未签名包。你可以：

- 用爱思助手/其他自签工具签名安装。
- 或者改用付费 Apple Developer 证书和 provisioning profile 做正式签名。

## 第 1 步：新建 GitHub 仓库

1. 打开 GitHub。
2. 点右上角 `+`。
3. 选 `New repository`。
4. 仓库名填：

```text
ClassicPodMusic
```

5. 选择 `Private` 或 `Public` 都行。
6. 不要勾选 README、.gitignore、license。
7. 点 `Create repository`。

## 第 2 步：上传项目文件

你需要上传的是 `ClassicPodMusic` 文件夹里的所有内容，不是外层 zip 本身。

上传前你可以在 Windows PowerShell 里运行这个检查：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\windows_check_before_upload.ps1
```

仓库创建后，GitHub 页面上会有 `uploading an existing file` 链接：

1. 点 `uploading an existing file`。
2. 把本文件夹里的内容拖进去：

```text
ClassicPodMusic.xcodeproj
ClassicPodMusic
.github
scripts
README.md
NO_XCODE_IPA_BUILD.md
REVIEW_NOTES.md
从零到IPA_无Mac教程.md
```

3. 等上传完成。
4. 页面底部点 `Commit changes`。

注意：`.github` 文件夹必须上传成功，否则 Actions 不会出现构建按钮。

## 第 3 步：运行云端构建

1. 打开你的 GitHub 仓库。
2. 点顶部 `Actions`。
3. 左侧选择 `Build unsigned iOS IPA`。
4. 点右侧 `Run workflow`。
5. Branch 选默认分支。
6. 再点一次绿色的 `Run workflow`。

GitHub 官方文档也说明，带 `workflow_dispatch` 的 workflow 可以在 Actions 标签页手动运行。

## 第 4 步：下载 IPA

1. 等构建从黄色变成绿色。
2. 点进去那条成功的运行记录。
3. 页面底部找到 `Artifacts`。
4. 下载：

```text
ClassicPodMusic-unsigned-ipa
```

5. 解压下载内容，里面就是：

```text
ClassicPodMusic-unsigned.ipa
```

GitHub 官方文档把这种构建产物叫 workflow artifacts。

## 第 5 步：用爱思助手签名安装

1. 打开爱思助手。
2. 找到 IPA 签名/自签相关功能。
3. 导入 `ClassicPodMusic-unsigned.ipa`。
4. 用你的 Apple ID 或证书签名。
5. 签名后安装到 iPhone。

如果你用的是普通免费 Apple ID，自签 App 可能会过期，需要重新签名安装。

## Apple Music 重要提醒

这个 App 用了 MusicKit 连接你的 Apple Music 曲库。签名时如果 profile 不包含 MusicKit 权限，App 可能能装上，但读取 Apple Music 曲库会失败。

最稳的是付费 Apple Developer 账号，并在 App ID 里启用 MusicKit capability。

## 如果 Actions 失败

优先看失败日志里有没有这些字：

- `glassEffect`：说明云端 Xcode 版本太旧，需要支持 iOS 26 SwiftUI API 的 Xcode。
- `MusicKit` 或 `entitlement`：说明签名或能力配置不完整。
- `No such module MusicKit`：说明用到的 SDK 太旧。
- `Code signing is required`：说明构建脚本没有正确关闭签名，或者 GitHub runner/Xcode 设置有变化。

失败截图发给我，我可以继续改 workflow。
