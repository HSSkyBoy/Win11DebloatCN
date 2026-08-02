# Win11Debloat

[![上游发布](https://img.shields.io/github/v/release/Raphire/Win11Debloat?style=for-the-badge&label=上游发布)](https://github.com/Raphire/Win11Debloat/releases/latest)
[![本库发布](https://img.shields.io/github/v/release/HSSkyBoy/Win11DebloatCN?style=for-the-badge&label=本库发布)](https://github.com/HSSkyBoy/Win11DebloatCN/releases/latest)
[![加入讨论](https://img.shields.io/badge/加入讨论-2D9F2D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Raphire/Win11Debloat/discussions)
[![文档](https://img.shields.io/badge/文档-_?style=for-the-badge&logo=bookstack&color=grey)](https://github.com/Raphire/Win11Debloat/wiki/)

> **这是 [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat) 的第三方中文镜像。** 脚本代码与上游完全一致，仅提供简体中文 README。
>
> For English, please visit the upstream repository: [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat)

Win11Debloat 是一个轻量级、易于使用的 PowerShell 脚本，无需安装即可快速清理和自定义您的 Windows 体验！您可以使用它来移除预装应用、禁用遥测、移除侵入性界面元素等等。无需费时费力地逐一调整设置或逐个卸载应用，Win11Debloat 让整个过程变得快速而简单！

该脚本还包含许多系统管理员和高级用户会喜欢的功能，例如强大的命令行界面、支持 Windows 审核模式以及能够为其他 Windows 用户应用更改。您还可以轻松导出和导入您的偏好设置，以便在所有系统上快速应用相同的设置。请参阅 [wiki](https://github.com/Raphire/Win11Debloat/wiki) 获取更多详细信息。

![Win11Debloat 菜单](/Assets/Images/menu.png)

#### 这个脚本帮到了您吗？请考虑买我一杯咖啡以支持原作者的工作

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M5C6UPC)

## 使用方法

> [!Warning]
> 我们在确保此脚本不会无意中破坏任何操作系统功能方面付出了极大的努力，但使用风险自负！如果您遇到任何问题，请在[上游仓库](https://github.com/Raphire/Win11Debloat/issues)报告。

### 快速方法

通过 PowerShell 自动下载并运行脚本。

1. 打开 PowerShell 或终端（管理员身份）。
2. 将以下命令复制并粘贴到 PowerShell 中：

```PowerShell
& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))
```

3. 等待脚本自动下载并启动 Win11Debloat。
4. 仔细阅读并遵循屏幕上的说明。

此方法支持[命令行参数](https://github.com/Raphire/Win11Debloat/wiki/Command%E2%80%90line-Interface#parameters)来自定义运行行为。

### 传统方法

<details>
  <summary>手动下载并运行脚本。</summary><br/>

  1. [下载脚本的最新版本](https://github.com/HSSkyBoy/Win11DebloatCN/releases/latest)，将 .ZIP 文件解压到您希望的位置。
  2. 导航到 Win11Debloat 文件夹。
  3. 双击 `Run.bat` 文件启动脚本。注意：如果控制台窗口立即关闭且没有任何反应，请尝试下面的高级方法。
  4. 接受 Windows UAC 提示以管理员身份运行脚本。
  5. 仔细阅读并遵循屏幕上的说明。
</details>

### 高级方法

<details>
  <summary>手动下载并通过 PowerShell 运行。建议高级用户使用。</summary><br/>

  1. [下载脚本的最新版本](https://github.com/HSSkyBoy/Win11DebloatCN/releases/latest)，将 .ZIP 文件解压到您希望的位置。
  2. 以管理员身份打开 PowerShell 或终端。
  3. 输入以下命令临时启用 PowerShell 执行：

  ```PowerShell
  Set-ExecutionPolicy Unrestricted -Scope Process -Force
  ```

  4. 导航到文件解压的目录。例如：`cd c:\Win11Debloat`
  5. 运行脚本：

  ```PowerShell
  .\Win11Debloat.ps1
  ```

  6. 仔细阅读并遵循屏幕上的说明。

  此方法同样支持[命令行参数](https://github.com/Raphire/Win11Debloat/wiki/Command%E2%80%90line-Interface#parameters)。
</details>

## 功能

以下是 Win11Debloat 提供的核心功能概述。您可以访问 [wiki](https://github.com/Raphire/Win11Debloat/wiki) 获取更多详细信息。

> [!Tip]
> Win11Debloat 所做的所有更改都可以轻松撤销，几乎所有应用都可以通过 Microsoft Store 重新安装。请参阅[撤销更改指南](https://github.com/Raphire/Win11Debloat/wiki/Reverting-Changes)。

#### 应用移除

- 移除各种预装应用。[查看更多](https://github.com/Raphire/Win11Debloat/wiki/App-Removal)

#### 隐私与推荐内容

- 禁用遥测、诊断数据、活动历史、应用启动跟踪和定向广告。
- 禁用 Windows、锁屏和 Microsoft Edge 中的提示、技巧、建议和广告。
- 禁用 Windows 位置服务、应用位置访问和"查找我的设备"位置跟踪。
- 隐藏设置"主页"页面上的 Microsoft 365 广告，或完全隐藏"主页"页面。

#### AI 功能

- 禁用并移除 Microsoft Copilot、Windows 回想（Recall）和 Click to Do。
- 阻止 AI 服务（WSAIFabricSvc）自动启动。
- 禁用 Edge、画图和记事本中的 AI 功能。

#### 系统

- 禁用用于分享和移动文件的拖拽托盘。
- 恢复旧版 Windows 10 风格的上下文菜单。
- 关闭增强指针精度（鼠标加速）。
- 禁用粘滞键键盘快捷键。
- 禁用存储感知自动磁盘清理。
- 禁用快速启动以确保完全关机。
- 禁用 BitLocker 自动设备加密。
- 禁用现代待机期间的网络连接以减少电池消耗。

#### Windows 更新

- 阻止 Windows 在更新可用后立即获取更新。
- 防止在已登录状态下的自动更新重启。
- 禁用传递优化（在电脑之间共享下载的更新）。
- 阻止 Windows 自动安装设备配套应用。

#### 外观

- 为系统和应用启用暗黑模式。
- 禁用透明度、动画和视觉效果。

#### 开始菜单与搜索

- 自定义开始菜单：移除固定应用、隐藏推荐内容、自定义"所有应用"布局。
- 禁用开始菜单中的 Phone Link 移动设备集成。
- 禁用 Windows 搜索中的 Bing 网页搜索、Copilot 集成和 Microsoft Store 应用建议。

#### 任务栏

- 更改任务栏对齐方式。
- 自定义或隐藏任务栏按钮（搜索栏、任务视图等）。
- 禁用任务栏和锁屏上的小组件。
- 在任务栏右键菜单中启用"结束任务"选项以快速强制关闭应用。
- 启用"上次活动点击"行为，反复点击任务栏图标即可在该应用的窗口间切换焦点。
- 自定义任务栏应用按钮的合并方式。

#### 文件资源管理器

- 更改文件资源管理器打开的默认位置。
- 显示已知文件类型的文件扩展名。
- 显示隐藏的文件、文件夹和驱动器。
- 从导航窗格中隐藏"主页"、"图库"或 OneDrive 部分。
- 从导航窗格中隐藏重复的可移动驱动器条目，仅保留"此电脑"下的条目。
- 将所有常用文件夹（桌面、下载等）添加回"此电脑"。
- 更改驱动器号的显示位置或可见性。

#### 多任务处理

- 禁用窗口贴靠。
- 禁用贴靠辅助和贴靠布局建议。
- 更改贴靠窗口或按 Alt+Tab 时是否显示标签页。

#### 可选 Windows 功能

- 启用 Windows 沙盒，在隔离环境中安全运行应用。
- 启用适用于 Linux 的 Windows 子系统 (WSL)。

#### 其他

- 禁用 Xbox Game Bar 集成和游戏/屏幕录制。
- 禁用 Brave 浏览器中的冗余功能（AI、加密货币、新闻等）。

#### 高级功能

- [将更改应用于其他用户](https://github.com/Raphire/Win11Debloat/wiki/Advanced-Features#running-as-another-user)，而非仅当前登录用户。
- [Sysprep 模式](https://github.com/Raphire/Win11Debloat/wiki/Advanced-Features#sysprep-mode)将更改应用于 Windows 默认用户配置文件，确保所有新用户自动应用这些更改。

## 许可证

Win11Debloat 遵循 MIT 许可证。有关更多信息，请参阅 LICENSE 文件。
