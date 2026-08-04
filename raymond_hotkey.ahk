#Requires AutoHotkey v2.0
#SingleInstance Force
ListLines 0

; ==========================================
; 0. 全局配置与变量 & GUI 初始化 (Gemini Uploader)
; ==========================================
global isImageReadyToUpload := false
global geminiLnkPath := "C:\Users\Raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\Gemini.lnk"
global iconPath := "C:\Users\Raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\photo\gemini.png"

; 创建悬浮窗 UI
global FloatingGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "GeminiUploader")
FloatingGui.BackColor := "EEAA99"  
WinSetTransColor("EEAA99", FloatingGui) ; 背景透明抠图，实现真正的无边框悬浮

; 启动前检测：如果没找到图片，会弹窗提醒
if !FileExist(iconPath) {
    MsgBox("未能找到图片！`n`n请确保路径正确：`n" iconPath, "缺少文件", "Iconx")
    ExitApp()
}

; 渲染精致小巧的 48x48 悬浮图标
iconBtn := FloatingGui.Add("Picture", "w48 h48 BackgroundTrans", iconPath)
iconBtn.OnEvent("Click", TriggerUpload)

; 监听剪贴板变化
OnClipboardChange(ClipboardChangedHandler)

; ==========================================
; 开发辅助：在编辑器中按 Ctrl+S 保存脚本时自动重新加载
; ==========================================
if (A_Args.Length > 0 && A_Args[1] == "/reloaded") {
    ShowTip("Script successfully reloaded")
}

#HotIf WinActive(A_ScriptName)
~^s:: {
    Sleep(200) ; 留出 200ms 给磁盘完成写入
    Run('"' . A_AhkPath . '" "' . A_ScriptFullPath . '" /reloaded')
    ExitApp()
}
#HotIf

; ==========================================
; 1. 基础快捷键 
; ==========================================
F1::Send("^z")
F3::Send("^v")
F4::Send("^c")
F5::Send("^a")
F6::Send("!q")
F8::SendLevel(1), Send("^+8")
F9::Send("^+9")
F10::Send("^+p")
F11::Send("^w")
F12::Send("^+{Esc}")

End::Send("#+{Right}")
PgUp::Send("^{Enter}")
PgDn::Send("^v")

; ==========================================
; 2. 软件快捷启动
; ==========================================
AppDir       := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\"
GeminiPath   := AppDir "gemini.lnk"
DouYinPath   := AppDir "抖音.lnk"
YoutubePath  := AppDir "YouTube.lnk"
bilibiliPath := AppDir "bilibili.lnk"
youglishPath := AppDir "youglish.lnk"
chromePath   := "C:\Program Files\Google\Chrome\Application\chrome.exe"
wpsPath      := AppDir "WPS听记.lnk"
wxsrfPath    := AppDir "微信输入法.lnk"
telegramPath := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\Telegram Desktop\Telegram.exe"
zhihuPath    := AppDir "知乎.lnk"
redditPath   := AppDir "Reddit.lnk"
ethernetPath := AppDir "Toggle_Ethernet.bat"
;===========================================
shutdownPath := AppDir "shutdown_30second.bat"
restartPath  := AppDir "restart_30second.bat"
;===========================================
notepadPath  := "C:\WINDOWS\notepad.exe"
screentogifPath := "C:\Program Files\WindowsApps\33823Nicke.ScreenToGif_2.43.2.0_x64__99xjgbc30gqtw\ScreenToGif.exe"
everythingPath := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\Everything\Everything.exe"
anytxtPath := "C:\Program Files\Anytxt Searcher\ATGUI.exe"
;===========================================

` & 1::SmartRun(chromePath)
` & 2::SmartRun(GeminiPath)
` & 3::SmartRun(wpsPath)
` & 4::SmartRun(bilibiliPath)
` & 5::SmartRun(YoutubePath)
` & 6::SmartRun(youglishPath)
` & 7::SmartRun(douyinPath)
` & 8::SmartRun(telegramPath)
` & 9::SmartRun(restartPath)
` & 0::SmartRun(shutdownPath)

;================================
; 字母区软件快捷启动
;================================
` & n::SmartRun(ethernetPath)
` & g::SmartRun(screentogifPath)

SmartRun(Path) {
    if FileExist(Path) {
        Run(Path)
    } else {
        ShowTip("File not found:`n" . Path)
    }
}

; ==========================================
; 3. 核心修复：强制恢复反引号和波浪线
; ==========================================
`::SendText("``")
+`::SendText("~")

; ==============================================================================
; 4. 系统化【多击按键】注册配置区
; ==========================================
RegisterMultiTap("LAlt", 3, TripleAltAction)  
RegisterMultiTap("RAlt", 3, TripleAltAction)  
RegisterMultiTap("Space", 4, QuadSpaceAction)
RegisterMultiTap("n", 5, PentaNAction)
RegisterMultiTap("z", 3, TripleZAction)
RegisterMultiTap("r", 3, TripleRAction)
RegisterMultiTap("y", 3, TripleYAction)
RegisterMultiTap("e", 3, TripleEAction)
RegisterMultiTap("a", 3, TripleAAction)

; ---【多击调用的具体函数】---
TripleAltAction() {
    Send("{Control}")     
    Send("^v")            
    ShowTip("📋 已粘贴")
}

QuadSpaceAction() {
    Send("{Ctrl Up}{Shift Up}{Alt Up}")
    Send("{Backspace 4}")
    Sleep(150)
    SendLevel 1
    SendEvent "{Ctrl Down}{Shift Down}{7}{Shift Up}{Ctrl Up}"
    SendLevel 0
    ShowTip("⚡ activated QuadSpaceAction")
}

PentaNAction() {
    Send("{Backspace 5}")
    SmartRun(notepadPath)
    Sleep(30)
}

TripleZAction() {
    Send("{Backspace 3}")
    SmartRun(zhihuPath)
    Sleep(30)
}

TripleRAction() {
    Send("{Backspace 3}")
    SmartRun(redditPath)
    Sleep(30)
}

TripleYAction() {
    Send("{Backspace 3}")
    SmartRun(YouTubePath)
    Sleep(30)
}

TripleEAction() {
    Send("{Backspace 3}")
    SmartRun(everythingPath)
    Sleep(30)
}

TripleAAction() {
    Send("{Backspace 3}")
    SmartRun(anytxtPath)
    Sleep(30)
}

ShowTip(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -1000)
}

; ==========================================
; 5. 多击逻辑的核心通用引擎
; ==========================================
RegisterMultiTap(key, targetCount, callback, maxSpeedInterval := 200) {
    static stateMap := Map()
    stateMap[key] := { count: 0, lastTime: 0, triggered: false }

    Hotkey("~" . key, (*) => ProcessTap(key, targetCount, callback, maxSpeedInterval))

    ProcessTap(k, target, cb, maxSpeed) {
        st := stateMap[k]
        now := A_TickCount
        diff := now - st.lastTime

        if (st.lastTime == 0 || diff > maxSpeed || st.triggered) {
            st.count := 1
            st.triggered := false
        } else {
            st.count++
        }
        
        st.lastTime := now

        if (st.count == target) {
            st.triggered := true 
            st.count := 0
            st.lastTime := 0        
            cb()                 
        }
    }
}

; ==========================================
; 6. Windows 11 记事本智能静默自动保存
; ==========================================
#HotIf WinActive("ahk_class Notepad") || WinActive("ahk_exe Notepad.exe")
SetTimer AutoSaveNotepad, 3000

AutoSaveNotepad() {
    if !WinActive("ahk_exe Notepad.exe")
        return
    if (A_TimeIdleKeyboard < 2000)
        return
    if GetKeyState("Ctrl") || GetKeyState("Shift") || GetKeyState("Alt")
        return

    title := WinGetTitle("A")
    if InStr(title, "•") || InStr(title, "*") {
        try {
            PostMessage(0x0111, 3, 0, , "ahk_exe Notepad.exe")
        } catch {
            SendKeyDelay := A_KeyDelay
            SetKeyDelay 10, 10
            ControlSend("{Ctrl down}s{Ctrl up}", , "ahk_exe Notepad.exe")
            SetKeyDelay SendKeyDelay
        }
        ShowTip("已自动保存")
    }
}
#HotIf

; ==============================================================================
; 7. 划词选中文本自动复制
; ==============================================================================
MIN_DRAG_X       := 35   
MIN_DRAG_Y       := 45   
MAX_DRAG_TIME_MS := 1500 
MIN_DRAG_TIME_MS := 80   

global g_AutoCopy_StartX := 0
global g_AutoCopy_StartY := 0
global g_AutoCopy_StartTime := 0

~LButton:: {
    global g_AutoCopy_StartX, g_AutoCopy_StartY, g_AutoCopy_StartTime
    MouseGetPos(&g_AutoCopy_StartX, &g_AutoCopy_StartY)
    g_AutoCopy_StartTime := A_TickCount
}

~LButton Up:: {
    global g_AutoCopy_StartX, g_AutoCopy_StartY, g_AutoCopy_StartTime

    if WinActive("ahk_class Windows.UI.Core.CoreWindow") 
    || WinActive("ahk_exe SnippingTool.exe") 
    || WinActive("ahk_exe SnippingToolApp.exe")
        return

    if WinActive("ahk_exe chrome.exe") && (g_AutoCopy_StartY < 120)
        return

    if WinActive("ahk_exe Code.exe") {
        if (g_AutoCopy_StartX < 80 || g_AutoCopy_StartY < 70)
            return
    }

    if GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P")
        return

    dragTime := A_TickCount - g_AutoCopy_StartTime
    
    if (dragTime < MIN_DRAG_TIME_MS || dragTime > MAX_DRAG_TIME_MS)
        return

    MouseGetPos(&endX, &endY)
    deltaX := Abs(endX - g_AutoCopy_StartX)
    deltaY := Abs(endY - g_AutoCopy_StartY)

    if (deltaX > MIN_DRAG_X || deltaY > MIN_DRAG_Y) {
        priorText := ""
        try priorText := A_Clipboard

        Sleep(50) 
        if GetKeyState("Backspace", "P") || GetKeyState("Delete", "P") || GetKeyState("v", "P")
            return

        oldClip := ClipboardAll()
        A_Clipboard := ""
        Send("^c")

        if ClipWait(0.12, 0) {
            currentText := A_Clipboard
            trimmedText := Trim(currentText)

            isSingleLineDrag := (deltaY < 25)
            hasNewline := InStr(currentText, "`n") || InStr(currentText, "`r")

            if (isSingleLineDrag && hasNewline) {
                A_Clipboard := oldClip
                return
            }

            if (trimmedText != "" && trimmedText != priorText) {
                ShowTip("Copied")
            } else {
                A_Clipboard := oldClip 
            }
        } else {
            A_Clipboard := oldClip 
        }
    }
}

; ==============================================================================
; 8. 鼠标右键连击触发粘贴
; ==========================================
RClick_TargetCount := 3
RClick_TimeLimit   := 450

~RButton:: {
    static lastTime := 0
    static clickCount := 0
    now := A_TickCount
    if (now - lastTime > RClick_TimeLimit) {
        clickCount := 1
    } else {
        clickCount++
    }
    lastTime := now
    if (clickCount >= RClick_TargetCount) {
        clickCount := 0
        Send("^v")
        Sleep(50)
        Send("{Esc}")
        ShowTip("📋 已粘贴")
    }
}

; ==========================================
; 9. 终极优化版：剪贴板图片监听与 Gemini 自动上传
; ==========================================
ClipboardChangedHandler(DataType) {
    ; 修复 Bug 2 (闪退问题)：加入 150 毫秒的“防抖” (Debounce) 定时器。
    ; 截图软件写入剪贴板时会产生多次震荡，延迟判断可以确保拿到最终稳态的数据。
    SetTimer(CheckClipboardForImage, -150)
}

CheckClipboardForImage() {
    global isImageReadyToUpload
    
    ; 检查系统底层标识：CF_BITMAP(2), CF_DIB(8), CF_DIBV5(17) 代表剪贴板内含有真正图像
    if (DllCall("IsClipboardFormatAvailable", "UInt", 2) 
     || DllCall("IsClipboardFormatAvailable", "UInt", 8) 
     || DllCall("IsClipboardFormatAvailable", "UInt", 17)) {
        isImageReadyToUpload := true
        ShowFloatingIcon()
    } else {
        ; 只有当剪贴板里明确【不是图片】时，才撤下图标
        isImageReadyToUpload := false
        HideFloatingIcon()
    }
}

ShowFloatingIcon() {
    FloatingGui.Show("Center NoActivate")
    SetTimer(HideFloatingIcon, -10000) ; 10秒后未操作则自动超时隐藏
}

HideFloatingIcon() {
    FloatingGui.Hide()
}

TriggerUpload(*) {
    global isImageReadyToUpload
    
    SetTimer(HideFloatingIcon, 0)
    FloatingGui.Hide()
    isImageReadyToUpload := false
    
    ; --- 修复 Bug 1：智能窗口排他与精准唤醒 ---
    try {
        ; 临时开启完全匹配模式，避免误匹配到带有 "Gemini" 名字的普通浏览器标签页
        oldTitleMatchMode := A_TitleMatchMode
        SetTitleMatchMode(3) ; 3 = Exact Match (精确匹配)
        
        ; 锁定目标特征：Chrome 独立应用 (PWA) 的标题通常纯净且类名为 Chrome_WidgetWin_1
        targetWinTitle := "Gemini ahk_exe chrome.exe"
        
        ; 情况 A: 用户当前就在使用 Gemini 窗口，直接就地粘贴，不打扰当前视野
        if WinActive(targetWinTitle) {
            ; 保持当前活动窗口状态
        } 
        ; 情况 B: 存在已经打开的 Gemini 窗口 (可能在后台, 或多个中的某一个)
        ; AHK 的 WinExist 默认总是获取“最近活跃的”那个窗口，完美规避群发并节省流量
        else if WinExist(targetWinTitle) {
            WinActivate(targetWinTitle)
            WinWaitActive(targetWinTitle, , 2)
        } 
        ; 情况 C: 未打开任何 Gemini，启动全新的
        else {
            Run(geminiLnkPath)
            if !WinWait(targetWinTitle, , 5) {
                Sleep(1000) ; 如果电脑极度卡顿 5 秒都没出现，做个 1 秒保底等待
            } else {
                WinActivate(targetWinTitle)
                WinWaitActive(targetWinTitle, , 2)
            }
        }
        
        ; 恢复原有匹配模式，以免影响系统其他热键逻辑
        SetTitleMatchMode(oldTitleMatchMode)
        
    } catch {
        MsgBox("无法启动 Gemini，请检查快捷方式路径：`n" geminiLnkPath, "路径错误", "Iconx")
        return
    }
    
    ; --- 确保系统输入焦点并稳定发送内容 ---
    Sleep(300)      ; 给页面输入框（如 Web 元素）一点获取焦点的微小缓冲时间
    Send("^v")      ; 触发粘贴
    Sleep(400)      ; 等待图片渲染/读取完毕，避免网速慢时瞬间被吞
    Send("{Enter}") ; 提交至网络
}

; --- 悬浮窗相关热键 ---
#+g:: {
    if (isImageReadyToUpload) {
        TriggerUpload()
    }
}

~Esc:: {
    HideFloatingIcon() ; 顺手隐藏图标，避免遮挡
}
