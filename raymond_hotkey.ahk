; ⚠️ 永远不删：遇到剪贴板卡死、状态异常或Bug时，请连续按 4 次 "d" 键强制清空剪贴板！
#Requires AutoHotkey v2.0
#SingleInstance Force
ListLines 0

; ==========================================
; 0. 全局配置与变量 & GUI 初始化
; ==========================================
global isImageReadyToUpload := false
global isTextReadyToSearch := false
global g_ClipboardLastChangeTime := 0 

; 路径配置
global geminiLnkPath := "C:\Users\Raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\Gemini.lnk"
global iconPath := "C:\Users\Raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\photo\gemini.png"

global youglishIconPath := "C:\Users\raymond\WPSDrive\1158436994\WPS云盘\Raymond_Workstation\chrome_app\programfiles\photo\youglish_auto_load.png"

; --- Gemini 悬浮窗 ---
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
    ; 🌟 核心修改：高度固定为 48，宽度设为 -1 让它按原图比例自适应缩放
    global ygIconBtn := YouGlishGui.Add("Picture", "h48 w-1 BackgroundTrans", youglishIconPath)
    ygIconBtn.OnEvent("Click", TriggerYouGlish)

    ; 获取缩放后的真实宽高，用于后续计算精准坐标
    global ygIconWidth := 0, ygIconHeight := 0
    ygIconBtn.GetPos(,, &ygIconWidth, &ygIconHeight)
}

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
    Sleep(200) 
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
global youglishPath := AppDir "youglish.lnk"
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
RegisterMultiTap("y", 3, TripleYAction)  ; 🌟 已恢复原本正常的 YouTube 唤醒
RegisterMultiTap("e", 3, TripleEAction)
RegisterMultiTap("a", 3, TripleAAction)
RegisterMultiTap("g", 4, QuadGAction)
RegisterMultiTap("d", 4, QuadDAction)    ; 🌟 新增：4次d清空剪贴板

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
    SmartRun(YoutubePath) ; 🌟 恢复 YouTube 路径调用
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
; 7. 终极防冲突版：划词选中文本自动复制 (双重保险完美版)
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
    global g_AutoCopy_StartX, g_AutoCopy_StartY, g_AutoCopy_StartTime, isTextReadyToSearch
    releaseTime := A_TickCount 

    if WinActive("ahk_class Windows.UI.Core.CoreWindow") 
    || WinActive("ahk_exe SnippingTool.exe") 
    || WinActive("ahk_exe SnippingToolApp.exe")
    || WinActive("ahk_exe Snipaste.exe")
    || WinActive("ahk_exe PixPin.exe")
        return

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
        
        isClipboardBusy := false
        Loop 10 {
            Sleep(40) 
            
            if (g_ClipboardLastChangeTime > releaseTime) {
                isClipboardBusy := true
                break
            }
            
            if (DllCall("IsClipboardFormatAvailable", "UInt", 2) 
             || DllCall("IsClipboardFormatAvailable", "UInt", 8) 
             || DllCall("IsClipboardFormatAvailable", "UInt", 17)) {
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

            ; 捕获纯文本，触发 YouGlish 悬浮窗
            if (trimmedText != "" && trimmedText != priorText) {
                ShowTip("Copied")
                isTextReadyToSearch := true
                ShowYouGlishIcon()
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
; 9. 状态锁定版：剪贴板图片监听与 Gemini 自动上传 
; ==========================================
ClipboardChangedHandler(DataType) {
    global g_ClipboardLastChangeTime, isImageReadyToUpload
    
    g_ClipboardLastChangeTime := A_TickCount
    
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
    ; 🌟 解决副屏漂移：强制获取跨显示器的全局绝对坐标
    oldCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    
    MouseGetPos(&mouseX, &mouseY)
    
    ; 恢复坐标模式
    CoordMode("Mouse", oldCoordMode) 
    
    ; 动态计算：鼠标右下方 45°，距离 50 像素 (X 和 Y 各偏移 35 像素)
    showX := mouseX + 35
    showY := mouseY + 35
    
    FloatingGui.Show("x" showX " y" showY " NoActivate")
    WinSetAlwaysOnTop(1, FloatingGui.Hwnd) ; 强制置顶，防止被新窗口遮挡
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

; ==========================================
; 10. YouGlish 划词搜索及自动触发 (Vimium 联动)
; ==========================================

; 🌟 新增：Ctrl+Shift+Y 直接触发 YouGlish
^+y::TriggerYouGlish()

ShowYouGlishIcon() {
    ; 🌟 解决副屏漂移的核心：强制获取跨显示器的全局绝对坐标
    oldCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    
    MouseGetPos(&mouseX, &mouseY)
    
    ; 恢复之前的坐标模式，避免影响脚本中的其他划词功能
    CoordMode("Mouse", oldCoordMode) 
    
    ; 动态计算：在鼠标左侧 50 像素，并扣除图片真实宽度，高度居中
    showX := mouseX - 50 - ygIconWidth
    showY := mouseY - (ygIconHeight / 2)
    
    YouGlishGui.Show("x" showX " y" showY " NoActivate")
    WinSetAlwaysOnTop(1, YouGlishGui.Hwnd) ; 置顶防遮挡
    SetTimer(HideYouGlishIcon, -2000)
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

; --- 全局清理悬浮窗快捷键 ---
#+g:: {
    if (isImageReadyToUpload) {
        TriggerUpload()
    }
}

~Esc:: {
    HideFloatingIcon() 
    HideYouGlishIcon()
}
