<div align="center" markdown="1">
   <sup>Special thanks to:</sup>
   <br>
   <br>
   <a href="https://www.warp.dev/windebloat">
      <img alt="Warp sponsorship" width="400" src="https://github.com/user-attachments/assets/c21102f7-bab9-4344-a731-0cf6b341cab2">
   </a>

### [Warp, the intelligent terminal for developers](https://www.warp.dev/windebloat)
[Available for MacOS, Linux, & Windows](https://www.warp.dev/windebloat)<br>

</div>
<hr>

[[English]](README.md) **[简体中文]**


# Win11Debloat

[![GitHub Release](https://img.shields.io/github/v/release/Raphire/Win11Debloat?style=for-the-badge&label=Latest%20release)](https://github.com/Raphire/Win11Debloat/releases/latest) [![Join the Discussion](https://img.shields.io/badge/Join-the%20Discussion-2D9F2D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Raphire/Win11Debloat/discussions) [![Static Badge](https://img.shields.io/badge/Documentation-_?style=for-the-badge&logo=bookstack&color=grey)](https://github.com/Raphire/Win11Debloat/wiki/)

Win11Debloat 是一个简单、易用且轻量级的 PowerShell 脚本，它允许你快速清理并提升你的 Windows 体验。它可以移除预装的冗余应用、禁用遥测功能、移除侵入式界面元素等。无需自己费劲地逐个设置或逐个移除应用。Win11Debloat 让整个过程变得快速而简单！

该脚本还包含许多系统管理员会喜欢的功能。例如支持 Windows 审计模式、允许修改其他 Windows 用户设置以及无需在运行时输入用户信息即可执行脚本的能力。请参阅我们的 [Wiki](https://github.com/Raphire/Win11Debloat/wiki/) 了解更多详情。

![Win11Debloat Menu](/Assets/menu.png)

#### 这个脚本帮到你了吗？请考虑给我买杯咖啡来支持我的工作

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M5C6UPC)

## 使用方法

\[!警告\] 确保此脚本不会无意中破坏任何操作系统功能，但请自行承担风险！如果遇到任何问题，请[在此处](https://github.com/Raphire/Win11Debloat/issues)报告。

### 快速方法

通过 PowerShell 自动下载并运行脚本。

1.  打开 PowerShell 或终端，最好以管理员身份运行。
2.  将以下命令复制并粘贴到 PowerShell 中：

```PowerShell
& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))
```

3.  等待脚本自动下载 Win11Debloat。
4.  仔细阅读并按照屏幕上的说明操作。

此方法支持参数以自定义脚本的运行行为。请点击 [此处](https://github.com/Raphire/Win11Debloat/wiki/How-To-Use#parameters) 获取更多信息。

### 传统方法

手动下载并运行脚本。

1.  下载脚本的最新版本，并将.ZIP 文件解压到您想要的位置。
2.  导航到 Win11Debloat 文件夹
3.  双击 `Run.bat` 文件以启动脚本。注意：如果控制台窗口立即关闭且没有任何反应，请尝试以下高级方法。
4.  接受 Windows UAC 提示以管理员身份运行脚本，这是脚本正常运行所必需的。
5.  仔细阅读并按照屏幕上的指示操作。

### 高级方法

手动下载脚本并通过 PowerShell 运行。推荐给高级用户。

1.  下载脚本的最新版本，并将 .ZIP 文件解压到您想要的位置。
2.  以管理员身份打开 PowerShell 或终端。
3.  通过输入以下命令暂时启用 PowerShell 执行：

```PowerShell
Set-ExecutionPolicy Unrestricted -Scope Process -Force
```

4.  在 PowerShell 中，导航到文件解压的目录。示例：`cd c:\Win11Debloat`
5.  现在通过输入以下命令运行脚本：

```PowerShell
.\Win11Debloat.ps1
```

6.  仔细阅读并按照屏幕上的说明进行操作。

此方法支持参数以自定义脚本的行为。请点击此处获取更多信息。

## 特性

以下是 Win11Debloat 提供的主要特性和功能概述。如需了解默认模式下包含哪些特性，请参阅下方的 [本节](#default-settings) 。

> \[!提示\] Win11Debloat 所做的所有更改都可以轻松撤销，而且几乎所有应用程序都可以通过 Microsoft Store 重新安装。有关如何撤销更改的完整指南，请 [点击此处](https://github.com/Raphire/Win11Debloat/wiki/Reverting-Changes) 查看。

#### 应用程序移除

*   移除多种预装应用。点击[此处](https://github.com/Raphire/Win11Debloat/wiki/App-Removal)获取更多信息。
*   移除或替换当前用户或所有现有及新用户的开始界面所有固定应用。（仅限 W11）

#### 遥测、跟踪与推荐内容

*   禁用遥测、诊断数据、活动历史、应用启动跟踪和定向广告。
*   禁用开始、设置、通知、文件资源管理器和锁屏中的提示、技巧、建议和广告。
*   禁用“Windows Spotlight”桌面背景选项。

#### 必应网络搜索、Copilot & AI 功能

*   禁用并从 Windows 搜索中移除必应网络搜索、必应 AI 和 Cortana。
*   禁用并删除 Microsoft Copilot。(仅限 W11)
*   禁用 Windows Recall 快照。(仅限 W11)
*   禁用画图中的 AI 功能 (仅限 W11)
*   禁用记事本中的 AI 功能 (仅限 W11)

#### 个性化设置

*   为系统和应用程序启用暗黑模式。
*   关闭透明度、动画和视觉效果。
*   关闭增强指针精度，也称为鼠标加速。
*   禁用粘滞键键盘快捷键。（仅限 W11）
*   恢复旧的 Windows 10 样式上下文菜单。（仅限 W11）
*   从上下文菜单中隐藏“包含在库中”、“授予访问权限”和“共享”选项。（仅限 W10）

#### 文件资源管理器

*   更改文件资源管理器默认打开的位置。
*   显示隐藏的文件、文件夹和驱动器。
*   显示已知文件类型的文件扩展名。
*   从文件资源管理器导航窗格中隐藏“主页”或“画廊”部分。（仅限 Windows 11）
*   隐藏 3D 对象、音乐或 OneDrive 文件夹在文件资源管理器导航窗格中。（仅限 Windows 10）
*   从文件资源管理器导航窗格中隐藏重复的移动驱动器条目，以便仅在'This PC'下保留条目。

#### 任务栏

*   将任务栏图标对齐到左侧。（仅限 Windows 11）
*   隐藏或更改任务栏上的搜索图标/框。（仅限 W11）
*   从任务栏中隐藏任务视图按钮。（仅限 W11）
*   禁用小部件服务并隐藏任务栏上的图标。
*   从任务栏中隐藏聊天（立即会议）图标。
*   在任务栏右键菜单中启用"结束任务"选项。（仅限 W11）
*   在任务栏应用区域启用"上次点击的应用"行为。这允许您通过反复点击任务栏中的应用图标来在打开的应用窗口之间切换焦点。

#### 开始

*   禁用开始菜单中的推荐部分。（仅限 W11）
*   禁用开始菜单中的手机链接移动设备集成。（仅限 W11）

#### 其他

*   禁用 Xbox 游戏/屏幕录制，这将停止游戏覆盖弹出窗口。
*   禁用快速启动以确保完全关机。
*   选项将更改应用于[其他用户](https://github.com/Raphire/Win11Debloat/wiki/Advanced-Features#running-as-another-user) ，而不是当前登录用户。
*   [系统准备模式](https://github.com/Raphire/Win11Debloat/wiki/Advanced-Features#sysprep-mode)用于将更改应用于 Windows 默认用户配置文件。之后，所有新用户将自动应用这些更改。

### 默认设置

Win11Debloat 提供了一种默认模式，允许您快速轻松地应用大多数人都推荐的更改。这包括卸载大多数人都认为是冗余软件的应用程序、移除许多烦人的干扰，并禁用遥测和跟踪。要应用默认设置，请像平常一样启动脚本，并在脚本菜单中选择选项 `1`。或者，您可以使用 `-RunDefaults` 参数启动脚本。示例：

```Powershell
& ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) -RunDefaults
```

#### 默认模式中包含的更改

*   移除默认的预装冗余应用。（详见下文完整列表）
*   禁用遥测、诊断数据、活动历史记录、应用启动跟踪和定向广告。
*   禁用开始菜单、设置、通知、文件资源管理器和锁屏上的提示、技巧、建议和广告。
*   禁用并删除 Windows 搜索中的 Bing 网页搜索、Bing AI 和 Cortana。
*   禁用并删除 Microsoft Copilot。（仅限 Windows 11）
*   禁用快速启动以确保完全关机。
*   显示已知文件类型的文件扩展名。
*   隐藏 '此电脑' 下 3D 对象文件夹，在文件资源管理器中。 （仅限 W10）
*   禁用小部件服务并隐藏任务栏图标。
*   隐藏任务栏中的聊天（立即会议）图标。

#### 默认模式下被移除的应用程序



<details>
  <summary>点击展开</summary>
  <blockquote>
    
    Microsoft bloat:
    - Clipchamp.Clipchamp  
    - Microsoft.3DBuilder  
    - Microsoft.549981C3F5F10 (Cortana app)
    - Microsoft.BingFinance  
    - Microsoft.BingFoodAndDrink 
    - Microsoft.BingHealthAndFitness
    - Microsoft.BingNews  
    - Microsoft.BingSearch* (Bing web search in Windows)
    - Microsoft.BingSports  
    - Microsoft.BingTranslator  
    - Microsoft.BingTravel   
    - Microsoft.BingWeather  
    - Microsoft.Copilot
    - Microsoft.Getstarted (Cannot be uninstalled in Windows 11)
    - Microsoft.Messaging  
    - Microsoft.Microsoft3DViewer  
    - Microsoft.MicrosoftJournal
    - Microsoft.MicrosoftOfficeHub  
    - Microsoft.MicrosoftPowerBIForWindows  
    - Microsoft.MicrosoftSolitaireCollection  
    - Microsoft.MicrosoftStickyNotes  
    - Microsoft.MixedReality.Portal  
    - Microsoft.NetworkSpeedTest  
    - Microsoft.News  
    - Microsoft.Office.OneNote (Discontinued UWP version only, does not remove new MS365 versions)
    - Microsoft.Office.Sway  
    - Microsoft.OneConnect  
    - Microsoft.Print3D  
    - Microsoft.SkypeApp  
    - Microsoft.Todos  
    - Microsoft.WindowsAlarms  
    - Microsoft.WindowsFeedbackHub  
    - Microsoft.WindowsMaps  
    - Microsoft.WindowsSoundRecorder  
    - Microsoft.XboxApp (Old Xbox Console Companion App, no longer supported)
    - Microsoft.ZuneVideo  
    - MicrosoftCorporationII.MicrosoftFamily (Microsoft Family Safety)
    - MicrosoftTeams (Old personal version of MS Teams from the MS Store)
    - MSTeams (New MS Teams app)

    Third party bloat:
    - ACGMediaPlayer  
    - ActiproSoftwareLLC  
    - AdobeSystemsIncorporated.AdobePhotoshopExpress  
    - Amazon.com.Amazon  
    - AmazonVideo.PrimeVideo
    - Asphalt8Airborne   
    - AutodeskSketchBook  
    - CaesarsSlotsFreeCasino  
    - COOKINGFEVER  
    - CyberLinkMediaSuiteEssentials  
    - DisneyMagicKingdoms  
    - Disney 
    - Dolby  
    - DrawboardPDF  
    - Duolingo-LearnLanguagesforFree  
    - EclipseManager  
    - Facebook  
    - FarmVille2CountryEscape  
    - fitbit  
    - Flipboard  
    - HiddenCity  
    - HULULLC.HULUPLUS  
    - iHeartRadio  
    - Instagram
    - king.com.BubbleWitch3Saga  
    - king.com.CandyCrushSaga  
    - king.com.CandyCrushSodaSaga  
    - LinkedInforWindows  
    - MarchofEmpires  
    - Netflix  
    - NYTCrossword  
    - OneCalendar  
    - PandoraMediaInc  
    - PhototasticCollage  
    - PicsArt-PhotoStudio  
    - Plex  
    - PolarrPhotoEditorAcademicEdition  
    - Royal Revolt  
    - Shazam  
    - Sidia.LiveWallpaper  
    - SlingTV  
    - Speed Test  
    - Spotify  
    - TikTok
    - TuneInRadio  
    - Twitter  
    - Viber  
    - WinZipUniversal  
    - Wunderlist  
    - XING
    
    * App is removed when disabling Bing in Windows search.
</blockquote>
</details>

#### 默认模式中未移除的应用

<details>
  <summary>点击展开</summary>
  <blockquote>

    General apps that are not removed by default:
    - Microsoft.Edge (Edge browser, only removeable in the EEA)
    - Microsoft.GetHelp (Required for some Windows 11 Troubleshooters)
    - Microsoft.MSPaint (Paint 3D)
    - Microsoft.OutlookForWindows* (New mail app)
    - Microsoft.OneDrive (OneDrive consumer)
    - Microsoft.Paint (Classic Paint)
    - Microsoft.People* (Required for & included with Mail & Calendar)
    - Microsoft.ScreenSketch (Snipping Tool)
    - Microsoft.Whiteboard (Only preinstalled on devices with touchscreen and/or pen support)
    - Microsoft.Windows.Photos
    - Microsoft.WindowsCalculator
    - Microsoft.WindowsCamera
    - Microsoft.WindowsNotepad
    - Microsoft.windowscommunicationsapps* (Mail & Calendar)
    - Microsoft.WindowsStore (Microsoft Store, NOTE: This app cannot be reinstalled!)
    - Microsoft.WindowsTerminal (New default terminal app in Windows 11)
    - Microsoft.YourPhone (Phone Link)
    - Microsoft.Xbox.TCUI (UI framework, removing this may break MS store, photos and certain games)
    - Microsoft.ZuneMusic (Modern Media Player)
    - MicrosoftWindows.CrossDevice (Phone integration within File Explorer, Camera and more)

    HP apps that are not removed by default:
    - AD2F1837.HPAIExperienceCenter*
    - AD2F1837.HPConnectedMusic*
    - AD2F1837.HPConnectedPhotopoweredbySnapfish*
    - AD2F1837.HPDesktopSupportUtilities*
    - AD2F1837.HPEasyClean*
    - AD2F1837.HPFileViewer*
    - AD2F1837.HPJumpStarts*
    - AD2F1837.HPPCHardwareDiagnosticsWindows*
    - AD2F1837.HPPowerManager*
    - AD2F1837.HPPrinterControl*
    - AD2F1837.HPPrivacySettings*
    - AD2F1837.HPQuickDrop*
    - AD2F1837.HPQuickTouch*
    - AD2F1837.HPRegistration*
    - AD2F1837.HPSupportAssistant*
    - AD2F1837.HPSureShieldAI*
    - AD2F1837.HPSystemInformation*
    - AD2F1837.HPWelcome*
    - AD2F1837.HPWorkWell*
    - AD2F1837.myHP*

    Gaming related apps that are not removed by default:
    - Microsoft.GamingApp* (Modern Xbox Gaming App, required for installing some games)
    - Microsoft.XboxGameOverlay* (Game overlay, required for some games)
    - Microsoft.XboxGamingOverlay* (Game overlay, required for some games)
    - Microsoft.XboxIdentityProvider (Xbox sign-in framework, required for some games)
    - Microsoft.XboxSpeechToTextOverlay (Might be required for some games, NOTE: This app cannot be reinstalled!)

    Developer related apps that are not removed by default:
    - Microsoft.PowerAutomateDesktop*
    - Microsoft.RemoteDesktop*
    - Windows.DevHome*

    * Can be removed by running the script with the relevant parameter. (Please refer to the wiki for more details)
</blockquote>
</details>

## 许可证

Win11Debloat 采用 MIT 许可证。有关更多信息，请参阅 LICENSE 文件。