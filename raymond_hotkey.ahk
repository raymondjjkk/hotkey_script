#Requires AutoHotkey v2.0
#SingleInstance Force
ListLines 0

; ==============================================================================
; 0. 全局配置、变量初始化与 GUI 创建
; ==============================================================================
global isImageReadyToUpload := false
global isTextReadyToSearch := false
global g_ClipboardLastChangeTime := 0 
global g_LastImageCopyTime := 0  ; 记录最近一次复制图片的时间戳

; 路径配置
global geminiLnkPath   := "C:\Users\Raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\Gemini.lnk"
global iconPath        := "C:\Users\Raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\photo\gemini.png"
global youglishIconPath := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\photo\youglish_auto_load.png"
global copiedIconPath  := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\photo\copied.png"

; --- Gemini 悬浮窗 ---
; 🌟 在这里自定义 Gemini 悬浮窗相对于鼠标的位置
global geminiOffsetX := -60  ; X轴偏移量：正数向鼠标右侧偏移，负数向左侧偏移
global geminiOffsetY := -60  ; Y轴偏移量：正数向鼠标下方偏移，负数向上方偏移

global FloatingGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "GeminiUploader")
FloatingGui.BackColor := "EEAA99"  
WinSetTransColor("EEAA99", FloatingGui) 
if !FileExist(iconPath) {
    MsgBox("未能找到图片！`n`n请确保路径正确：`n" iconPath, "缺少文件", "Iconx")
    ExitApp()
}
iconBtn := FloatingGui.Add("Picture", "w48 h48 BackgroundTrans", iconPath)
iconBtn.OnEvent("Click", TriggerUpload)

; --- YouGlish 悬浮窗 ---
global YouGlishGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "YouGlishUploader")
YouGlishGui.BackColor := "EEAA99"
WinSetTransColor("EEAA99", YouGlishGui)
if !FileExist(youglishIconPath) {
    MsgBox("未能找到 YouGlish 图片！`n`n请确保路径正确：`n" youglishIconPath, "缺少文件", "Iconx")
} else {
    ; 高度缩小至 44（原48），宽度自适应按原图比例缩放
    global ygIconBtn := YouGlishGui.Add("Picture", "h32 w-1 BackgroundTrans", youglishIconPath)
    ygIconBtn.OnEvent("Click", TriggerYouGlish)
    
    ; 获取缩放后的真实宽高，用于精准计算定位坐标
    global ygIconWidth := 0, ygIconHeight := 0
    ygIconBtn.GetPos(,, &ygIconWidth, &ygIconHeight)
}

; --- Copied 提示悬浮窗 ---
global CopiedGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "CopiedIcon")
CopiedGui.BackColor := "EEAA99"
WinSetTransColor("EEAA99", CopiedGui)
if !FileExist(copiedIconPath) {
    MsgBox("未能找到 Copied 图片！`n`n请确保路径正确：`n" copiedIconPath, "缺少文件", "Iconx")
} else {
    ; 高度 37，宽度按原比例自适应
    CopiedGui.Add("Picture", "h37 w-1 BackgroundTrans", copiedIconPath)
}

; 监听剪贴板变化
OnClipboardChange(ClipboardChangedHandler)

; ==============================================================================
; 开发辅助：在编辑器中按 Ctrl+S 保存脚本时自动热重载
; ==============================================================================
if (A_Args.Length > 0 && A_Args[1] == "/reloaded") {
    ShowTip("Script successfully reloaded")
}
#HotIf WinActive(A_ScriptName)
~^s:: {
    Sleep(200) 
    Run('"' . A_AhkPath . '" "' . A_ScriptFullPath . '" /reloaded')
    ExitApp()
}
#HotIf

; ==============================================================================
; 1. 基础快捷键映射
; ==============================================================================
F1::Send("^z")
F3::Send("^c")
F4::Send("^v")
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

; ==============================================================================
; 2. 应用程序快捷启动映射
; ==============================================================================
AppDir          := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\"
GeminiPath      := AppDir "gemini.lnk"
DouYinPath      := AppDir "抖音.lnk"
YoutubePath     := AppDir "YouTube.lnk"
bilibiliPath    := AppDir "bilibili.lnk"
global youglishPath := AppDir "youglish.lnk"
chromePath      := "C:\Program Files\Google\Chrome\Application\chrome.exe"
wpsPath         := AppDir "WPS听记.lnk"
wxsrfPath       := AppDir "微信输入法.lnk"
telegramPath    := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\Telegram Desktop\Telegram.exe"
zhihuPath       := AppDir "知乎.lnk"
redditPath      := AppDir "Reddit.lnk"
ethernetPath    := AppDir "Toggle_Ethernet.bat"
shutdownPath    := AppDir "shutdown_30second.bat"
restartPath     := AppDir "restart_30second.bat"
notepadPath     := "C:\WINDOWS\notepad.exe"
screentogifPath := "C:\Program Files\WindowsApps\33823Nicke.ScreenToGif_2.43.2.0_x64__99xjgbc30gqtw\ScreenToGif.exe"
everythingPath  := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\Everything\Everything.exe"
anytxtPath      := "C:\Program Files\Anytxt Searcher\ATGUI.exe"

; 数字键联动组合键启动
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

; 字母键联动组合键启动
` & n::SmartRun(ethernetPath)
` & g::SmartRun(screentogifPath)

SmartRun(Path) {
    if FileExist(Path) {
        Run(Path)
    } else {
        ShowTip("File not found:`n" . Path)
    }
}

; ==============================================================================
; 3. 基础按键恢复（消除组合键后对原按键输入的影响）
; ==============================================================================
`::SendText("``")
+`::SendText("~")

; ==============================================================================
; 4. 系统化【多击按键】注册与触发响应区
; ==============================================================================
RegisterMultiTap("Space", 4, QuadSpaceAction)
RegisterMultiTap("n", 5, PentaNAction)
RegisterMultiTap("z", 3, TripleZAction)
RegisterMultiTap("r", 3, TripleRAction)
RegisterMultiTap("y", 3, TripleYAction)  
RegisterMultiTap("e", 3, TripleEAction)
RegisterMultiTap("a", 3, TripleAAction)
RegisterMultiTap("g", 4, QuadGAction)
RegisterMultiTap("d", 4, QuadDAction)  ; 紧急恢复：清空剪贴板

; ---【多击触发的具体执行函数】---
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
    SmartRun(YoutubePath)
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
    Send("{Backspace 4}") 
    Sleep(30)
    
    if (isImageReadyToUpload) {
        TriggerUpload()
    } else {
        ShowTip("剪贴板中无有效图片")
    }
}

QuadDAction() {
    Send("{Backspace 4}") 
    A_Clipboard := ""
    ShowTip("🗑️ 剪贴板已强制清空")
    Sleep(30)
}

ShowTip(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -1000)
}

; ==============================================================================
; 5. 多击检测核心引擎（通用回调处理）
; ==============================================================================
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

; ==============================================================================
; 6. Win11 记事本静默自动保存机制
; ==============================================================================
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
; 7. 划词选中文本自动复制（带 8秒图片保护机制与误触防拦截）
; ==============================================================================
MIN_DRAG_X       := 35   
MIN_DRAG_Y       := 45   
MAX_DRAG_TIME_MS := 15000 
MIN_DRAG_TIME_MS := 50   

global g_AutoCopy_StartX := 0
global g_AutoCopy_StartY := 0
global g_AutoCopy_StartTime := 0

~LButton:: {
    global g_AutoCopy_StartX, g_AutoCopy_StartY, g_AutoCopy_StartTime
    MouseGetPos(&g_AutoCopy_StartX, &g_AutoCopy_StartY)
    g_AutoCopy_StartTime := A_TickCount
}

~LButton Up:: {
    global g_AutoCopy_StartX, g_AutoCopy_StartY, g_AutoCopy_StartTime, isTextReadyToSearch, g_LastImageCopyTime
    releaseTime := A_TickCount 

    ; 特殊窗口/工具中禁用划词复制
    if WinActive("ahk_class Windows.UI.Core.CoreWindow") 
    || WinActive("ahk_exe SnippingTool.exe") 
    || WinActive("ahk_exe SnippingToolApp.exe")
    || WinActive("ahk_exe Snipaste.exe")
    || WinActive("ahk_exe PixPin.exe")
        return

    ; 截图或特殊光标状态下禁用
    if (A_Cursor = "Cross")
        return

    ; Chrome 顶部标签页区域禁用
    if WinActive("ahk_exe chrome.exe") && (g_AutoCopy_StartY < 120)
        return

    ; VS Code 侧边栏/顶部标题栏禁用
    if WinActive("ahk_exe Code.exe") {
        if (g_AutoCopy_StartX < 80 || g_AutoCopy_StartY < 70)
            return
    }

    ; 修饰键按下时禁用
    if GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P")
        return

    dragTime := A_TickCount - g_AutoCopy_StartTime
    
    if (dragTime < MIN_DRAG_TIME_MS || dragTime > MAX_DRAG_TIME_MS)
        return

    MouseGetPos(&endX, &endY)
    deltaX := Abs(endX - g_AutoCopy_StartX)
    deltaY := Abs(endY - g_AutoCopy_StartY)

    if (deltaX > MIN_DRAG_X || deltaY > MIN_DRAG_Y) {
        
        ; 防误触保护：若 8 秒内曾复制过图片，屏蔽划词复制以保护剪贴板图像
        if (g_LastImageCopyTime > 0 && (A_TickCount - g_LastImageCopyTime) < 8000) {
            return
        }
        
        ; 检查剪贴板竞争状态
        isClipboardBusy := false
        Loop 2 {
            Sleep(40) 
            
            if (g_ClipboardLastChangeTime > releaseTime) {
                isClipboardBusy := true
                break
            }
        }
        
        if (isClipboardBusy) {
            return 
        }

        priorText := ""
        try priorText := A_Clipboard

        if GetKeyState("Backspace", "P") || GetKeyState("Delete", "P") || GetKeyState("v", "P")
            return

        oldClip := ClipboardAll()
        A_Clipboard := ""
        Send("^c")

        if ClipWait(0.15, 1) {
            ; 1. 过滤文件及文件夹拖拽 (CF_HDROP = 15)
            if DllCall("IsClipboardFormatAvailable", "UInt", 15) {
                A_Clipboard := oldClip
                return
            }

            ; 2. 过滤图像格式 (CF_BITMAP=2, CF_DIB=8, CF_DIBV5=17)
            if (DllCall("IsClipboardFormatAvailable", "UInt", 2) 
             || DllCall("IsClipboardFormatAvailable", "UInt", 8) 
             || DllCall("IsClipboardFormatAvailable", "UInt", 17)) {
                return 
            }

            ; 3. 处理文本数据并清洗空白字符
            currentText := A_Clipboard
            trimmedText := Trim(currentText, " `t`r`n") 

            if (trimmedText == "") {
                A_Clipboard := oldClip
                return
            }

            ; 单行划词但包含换行符时取消复制
            isSingleLineDrag := (deltaY < 25)
            hasNewline := InStr(currentText, "`n") || InStr(currentText, "`r")
            if (isSingleLineDrag && hasNewline) {
                A_Clipboard := oldClip
                return
            }

            ; 成功提取有效文本，触发 Copied 悬浮提示与 YouGlish 按钮
            if (trimmedText != priorText) {
                ShowCopiedIcon()
                isTextReadyToSearch := true
                ShowYouGlishIcon()
            } else {
                A_Clipboard := oldClip 
            }
        } else {
            A_Clipboard := oldClip
        }
    }
}

; ==============================================================================
; 8. 剪贴板图像监听与 Gemini 自动上传处理
; ==============================================================================
ClipboardChangedHandler(DataType) {
    global g_ClipboardLastChangeTime, isImageReadyToUpload
    
    g_ClipboardLastChangeTime := A_TickCount
    
    if (DataType == 0)
        return
        
    SetTimer(CheckClipboardForImage, -150)
}

CheckClipboardForImage() {
    global isImageReadyToUpload, g_LastImageCopyTime
    
    if (DllCall("IsClipboardFormatAvailable", "UInt", 2) 
     || DllCall("IsClipboardFormatAvailable", "UInt", 8) 
     || DllCall("IsClipboardFormatAvailable", "UInt", 17)) {
        isImageReadyToUpload := true
        g_LastImageCopyTime := A_TickCount
        ShowFloatingIcon()
    } else {
        isImageReadyToUpload := false
        g_LastImageCopyTime := 0  ; 清除图片时间戳，立即解除 8 秒保护
        HideFloatingIcon()
    }
}

ShowFloatingIcon() {
    oldCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    
    MouseGetPos(&mouseX, &mouseY)
    CoordMode("Mouse", oldCoordMode) 
    
    ; 🌟 使用刚才在开头设置的自定义坐标变量
    showX := mouseX + geminiOffsetX
    showY := mouseY + geminiOffsetY
    
    FloatingGui.Show("x" showX " y" showY " NoActivate")
    WinSetAlwaysOnTop(1, FloatingGui.Hwnd)
    SetTimer(HideFloatingIcon, -3000) 
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
        SetTitleMatchMode(2) 
        
        targetWinTitle := "Gemini ahk_exe chrome.exe"
        
        if WinActive(targetWinTitle) {
            Send("{Esc}") 
            Sleep(50)
            Send("gi")    
            Sleep(200)    
        } 
        else if WinExist(targetWinTitle) {
            WinActivate(targetWinTitle)
            WinWaitActive(targetWinTitle, , 2)
            Send("{Esc}")
            Sleep(50)
            Send("gi")
            Sleep(200) 
        } 
        else {
            Run(geminiLnkPath)
            if WinWait(targetWinTitle, , 5) {
                WinActivate(targetWinTitle)
                WinWaitActive(targetWinTitle, , 2)
                Sleep(2000) 
            } else {
                Sleep(1000) 
            }
        }
        
        SetTitleMatchMode(oldTitleMatchMode)
        
        Send("^v")  
        Sleep(400)  
        Send("{Enter}") 
        
    } catch {
        MsgBox("无法启动 Gemini，请检查快捷方式路径：`n" geminiLnkPath, "路径错误", "Iconx")
        return
    }
}

; ==============================================================================
; 9. YouGlish 划词搜索悬浮窗与快捷控制
; ==============================================================================
^+y::TriggerYouGlish()

ShowYouGlishIcon() {
    oldCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    
    MouseGetPos(&mouseX, &mouseY)
    CoordMode("Mouse", oldCoordMode) 
    
    ; 计算定位：位于鼠标左侧 50 像素，结合图片实际宽度水平对齐，垂直居中
    showX := mouseX - 40 - ygIconWidth
    showY := mouseY +15 - (ygIconHeight / 2)
    
    YouGlishGui.Show("x" showX " y" showY " NoActivate")
    WinSetAlwaysOnTop(1, YouGlishGui.Hwnd)
    SetTimer(HideYouGlishIcon, -3000)
}

HideYouGlishIcon() {
    YouGlishGui.Hide()
}

TriggerYouGlish(*) {
    global isTextReadyToSearch, youglishPath
    
    SetTimer(HideYouGlishIcon, 0)
    YouGlishGui.Hide()
    isTextReadyToSearch := false
    
    try {
        oldTitleMatchMode := A_TitleMatchMode
        SetTitleMatchMode(2) 
        
        targetWinTitle := "youglish ahk_exe chrome.exe"
        
        if WinActive(targetWinTitle) {
            Send("{Esc}")
            Sleep(50)
            Send("gi")
            Sleep(200)
        } 
        else if WinExist(targetWinTitle) {
            WinActivate(targetWinTitle)
            WinWaitActive(targetWinTitle, , 2)
            Send("{Esc}")
            Sleep(50)
            Send("gi")
            Sleep(200)
        } 
        else {
            Run(youglishPath)
            if WinWait(targetWinTitle, , 5) {
                WinActivate(targetWinTitle)
                WinWaitActive(targetWinTitle, , 2)
                Sleep(1500) 
                Send("{Esc}")
                Sleep(50)
                Send("gi")
                Sleep(200)
            } else {
                Sleep(1000)
            }
        }
        
        SetTitleMatchMode(oldTitleMatchMode)
        
        Send("^a")  
        Sleep(50)
        Send("^v")  
        Sleep(400)
        Send("{Enter}") 
        
    } catch {
        MsgBox("无法启动 YouGlish，请检查快捷方式路径：`n" youglishPath, "路径错误", "Iconx")
        return
    }
}


ShowCopiedIcon() {
    oldCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    
    MouseGetPos(&mouseX, &mouseY)
    CoordMode("Mouse", oldCoordMode) 
    
    ; 动态坐标计算
    showX := mouseX +70
    showY := mouseY -2
    
    CopiedGui.Show("x" showX " y" showY " NoActivate")
    WinSetAlwaysOnTop(1, CopiedGui.Hwnd)
    SetTimer(HideCopiedIcon, -1500)
}

HideCopiedIcon() {
    CopiedGui.Hide()
}

; 快捷按键清理/触发图片上传
#+g:: {
    if (isImageReadyToUpload) {
        TriggerUpload()
    }
}

; ==============================================================================
; 10. 全局 Esc 综合管理区 (长按 Esc + 鼠标左键关闭窗口 & 关闭悬浮窗)
; ==============================================================================
global g_EscPressTime := 0            ; 记录 Esc 按下的时间戳
global ESC_LONG_PRESS_THRESHOLD := 400 ; 触发长按的时间阈值，单位：毫秒

; 拦截并处理 Esc 键按下（~ 保证 Esc 原生功能不受损）
~Esc:: {
    global g_EscPressTime
    
    ; 如果为 0，说明是第一次按下，防止按住不放时键盘自动重复刷新时间戳
    if (g_EscPressTime == 0) {
        g_EscPressTime := A_TickCount
    }
    
    ; 触发原有的 Esc 功能：关闭所有悬浮窗
    HideFloatingIcon() 
    HideYouGlishIcon()
    HideCopiedIcon()
}

; 拦截 Esc 键抬起，重置时间戳
~Esc up:: {
    global g_EscPressTime
    g_EscPressTime := 0
}

; 动态指令：只有在物理按住 Esc 键的情况下，才接管鼠标左键
#HotIf GetKeyState("Esc", "P")
$LButton:: {
    global g_EscPressTime, ESC_LONG_PRESS_THRESHOLD
    
    ; 1. 检查是否满足长按条件：Esc 已经按下，且持续时间超过了 400ms
    if (g_EscPressTime > 0 && (A_TickCount - g_EscPressTime >= ESC_LONG_PRESS_THRESHOLD)) {
        
        ; 获取当前鼠标指针下方的窗口句柄（防误关焦点窗口）
        MouseGetPos ,, &hoverWin
        
        ; 尝试关闭该窗口，try块防止管理员权限窗口导致的报错弹窗
        if hoverWin {
            try {
                WinClose hoverWin
            }
        }
    } 
    else {
        ; 2. 如果没达到长按时间，说明用户只是普通连按，放行鼠标点击
        Send "{Blind}{LButton down}"
        KeyWait "LButton"
        Send "{Blind}{LButton up}"
    }
}
#HotIf