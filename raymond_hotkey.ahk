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
RegisterMultiTap("g", 4, QuadGAction) ; 🌟 新增：4次g连击

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

QuadGAction() {
    Send("{Backspace 4}") ; 自动擦除输入框里打出的4个g
    Sleep(30)
    
    ; 检查悬浮窗是否就绪
    if (isImageReadyToUpload) {
        TriggerUpload()
    } else {
        ShowTip("剪贴板中无有效图片")
    }
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
; 7. 终极防冲突版：划词选中文本自动复制
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

    ; 🌟 保护锁 1：扩展已知截图软件的窗口屏蔽
    if WinActive("ahk_class Windows.UI.Core.CoreWindow") 
    || WinActive("ahk_exe SnippingTool.exe") 
    || WinActive("ahk_exe SnippingToolApp.exe")
    || WinActive("ahk_exe Snipaste.exe")
    || WinActive("ahk_exe PixPin.exe")
        return

    ; 🌟 保护锁 2：行为特征拦截！
    if (A_Cursor = "Cross")
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

        if ClipWait(0.15, 1) {
            if (DllCall("IsClipboardFormatAvailable", "UInt", 2) 
             || DllCall("IsClipboardFormatAvailable", "UInt", 8) 
             || DllCall("IsClipboardFormatAvailable", "UInt", 17)) {
                return 
            }

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
            if !(DllCall("IsClipboardFormatAvailable", "UInt", 2) || DllCall("IsClipboardFormatAvailable", "UInt", 8)) {
                A_Clipboard := oldClip 
            }
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
; 9. 状态锁定版：剪贴板图片监听与 Gemini 自动上传 (Vimium 极速对焦版)
; ==========================================
ClipboardChangedHandler(DataType) {
    if (DataType == 0)
        return
        
    SetTimer(CheckClipboardForImage, -150)
}

CheckClipboardForImage() {
    global isImageReadyToUpload
    
    if (DllCall("IsClipboardFormatAvailable", "UInt", 2) 
     || DllCall("IsClipboardFormatAvailable", "UInt", 8) 
     || DllCall("IsClipboardFormatAvailable", "UInt", 17)) {
        isImageReadyToUpload := true
        ShowFloatingIcon()
    } else {
        isImageReadyToUpload := false
        HideFloatingIcon()
    }
}

ShowFloatingIcon() {
    FloatingGui.Show("Center NoActivate")
    SetTimer(HideFloatingIcon, -5000) ; 🌟 修改：5秒后自动隐藏悬浮窗
}

HideFloatingIcon() {
    FloatingGui.Hide()
}

TriggerUpload(*) {
    global isImageReadyToUpload
    
    SetTimer(HideFloatingIcon, 0)
    FloatingGui.Hide()
    isImageReadyToUpload := false
    
    try {
        oldTitleMatchMode := A_TitleMatchMode
        SetTitleMatchMode(2) ; 包含匹配
        
        targetWinTitle := "Gemini ahk_exe chrome.exe"
        
        if WinActive(targetWinTitle) {
            ; 场景 A: 当前窗口已经是最近使用的 Gemini，直接利用 Vimium
            Send("{Esc}") ; 先发 Esc 退回正常模式，防止原本就在输入框里打出"gi"
            Sleep(50)
            Send("gi")    ; Vimium 极速对焦
            Sleep(200)    ; 给 Vimium 寻址和聚焦一点缓冲时间
        } 
        else if WinExist(targetWinTitle) {
            ; 场景 B: 存在未激活的 Gemini 窗口，按系统 Z-order 唤醒最近使用的那一个
            WinActivate(targetWinTitle)
            WinWaitActive(targetWinTitle, , 2)
            Send("{Esc}")
            Sleep(50)
            Send("gi")
            Sleep(200) 
        } 
        else {
            ; 场景 C: 完全没有 Gemini 窗口，启动新窗口 (冷启动不需要 Vimium 对焦，且需要留足加载时间)
            Run(geminiLnkPath)
            if WinWait(targetWinTitle, , 5) {
                WinActivate(targetWinTitle)
                WinWaitActive(targetWinTitle, , 2)
                Sleep(2000) ; 首次冷启动需要等待网页加载 DOM 结构完成
            } else {
                Sleep(1000) 
            }
        }
        
        SetTitleMatchMode(oldTitleMatchMode)
        
        ; 此时光标已被 Vimium 精准绑定在输入框内
        Send("^v")  
        Sleep(400)  ; 图片在网页端解析也需要几百毫秒，缓冲一下防止回车过早
        Send("{Enter}") 
        
    } catch {
        MsgBox("无法启动 Gemini，请检查快捷方式路径：`n" geminiLnkPath, "路径错误", "Iconx")
        return
    }
}

; --- 悬浮窗相关热键 ---
#+g:: {
    if (isImageReadyToUpload) {
        TriggerUpload()
    }
}

~Esc:: {
    HideFloatingIcon() 
}
