#Requires AutoHotkey v2.0
#SingleInstance Force
ListLines 0

; ==========================================
; 0. 开发辅助：在编辑器中按 Ctrl+S 保存脚本时自动重新加载
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
F8::Send("^+8")
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
chromePath   := AppDir "Google Chrome.lnk"
wpsPath      := AppDir "WPS听记.lnk"
wxsrfPath    := AppDir "微信输入法.lnk"
telegramPath := AppDir "Telegram.lnk"
zhihuPath    := AppDir "知乎.lnk"
redditPath   := AppDir "Reddit.lnk"
ethernetPath := AppDir "Toggle_Ethernet.bat"
;===========================================
shutdownPath := AppDir "shutdown_30second.bat"
restartPath  := AppDir "restart_30second.bat"
;===========================================
notepadPath  := "C:\WINDOWS\notepad.exe"
screentogifPath := AppDir "screentogif.lnk"
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
; 4. 系统化【多击按键】注册配置区（全部享受快速连击限制）
; ==========================================

RegisterMultiTap("LAlt", 3, TripleAltAction)  
RegisterMultiTap("RAlt", 3, TripleAltAction)  
RegisterMultiTap("Space", 4, QuadSpaceAction)
RegisterMultiTap("n", 5, PentaNAction)
RegisterMultiTap("z", 3, TripleZAction)
RegisterMultiTap("r", 3, TripleRAction)
RegisterMultiTap("y", 3, TripleYAction)

; ---【多击调用的具体函数】---
TripleAltAction() {
    Send("{Control}")     
    Send("^v")            
    ShowTip("📋 已粘贴")
}

QuadSpaceAction() {
    ; 1. 强制清空修饰键，避免系统残留按键
    Send("{Ctrl Up}{Shift Up}{Alt Up}")
    
    ; 2. 删除输入的 4 个空格
    Send("{Backspace 4}")
    
    ; 3. 核心修复：给系统输入框 150ms 的喘息时间，确保退格完成且光标聚焦
    Sleep(150)
    
    ; 4. 跨脚本触发翻译脚本的 Ctrl+Shift+7
    SendLevel(1)
    SendEvent("^+7")
    SendLevel(0)
    
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

; 通用轻量气泡提示
ShowTip(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -1000)
}

; ==========================================
; 5. 多击逻辑的核心通用引擎（已内置“快速触发”限制）
; ==========================================
RegisterMultiTap(key, targetCount, callback, maxSpeedInterval := 200) {
    static stateMap := Map()
    stateMap[key] := { count: 0, lastTime: 0, triggered: false }

    Hotkey("~" . key, (*) => ProcessTap(key, targetCount, callback, maxSpeedInterval))

    ProcessTap(k, target, cb, maxSpeed) {
        st := stateMap[k]
        now := A_TickCount
        diff := now - st.lastTime

        ; 如果两次按键间隔太久（超过了最大允许速度间隔），或者已经触发过，则重置计数
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

    title := WinGetTitle("A")
    if InStr(title, "•") || InStr(title, "*") {
        ControlSend("^s",, "ahk_exe Notepad.exe")
        ShowTip("已自动保存")
    }
}
#HotIf

; ==============================================================================
; 7. 划词选中文本自动复制（VS Code 深度优化版 + 核心 Bug 修复）
; ==============================================================================
MIN_DRAG_DISTANCE := 30
MAX_DRAG_TIME_MS  := 2000

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
    if (dragTime > MAX_DRAG_TIME_MS)
        return

    MouseGetPos(&endX, &endY)
    deltaX := Abs(endX - g_AutoCopy_StartX)
    deltaY := Abs(endY - g_AutoCopy_StartY)

    if (deltaX > MIN_DRAG_DISTANCE || deltaY > MIN_DRAG_DISTANCE) {
        priorText := ""
        try priorText := A_Clipboard

        Sleep(80) 
        if GetKeyState("Backspace", "P") || GetKeyState("Delete", "P") || GetKeyState("v", "P")
            return

        oldClip := ClipboardAll()
        A_Clipboard := ""

        Send("^c")

        if ClipWait(0.15, 0) {
            currentText := Trim(A_Clipboard)
            
            if (currentText != "" && currentText != priorText) {
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