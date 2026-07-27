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
telegramPath    := AppDir "Telegram.lnk"
zhihuPath := AppDir "知乎.lnk"
redditPath := AppDir "Reddit.lnk"
ethernetPath := AppDir "Toggle_Ethernet.bat"
;===========================================
shutdownPath := AppDir "shutdown_30second.bat"
restartPath  := AppDir "restart_30second.bat"
;===========================================
notepadPath  := "C:\WINDOWS\notepad.exe"
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
` & n::SmartRun(ethernetPath)

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
; ==============================================================================

; 配置 1: 连续按 3 次 Alt -> 擦除菜单焦点并触发粘贴
RegisterMultiTap("Alt", 3, TripleAltAction)

; 配置 2: 连续按 4 次空格 -> 擦除 4 个空格并精准触发 Ctrl + Shift + 6
RegisterMultiTap("Space", 4, QuadSpaceAction)

; 配置 3: 连续按 3 次 n -> 擦除 3 个 n 并打开记事本
RegisterMultiTap("n", 3, TripleNAction)

; 配置 3: 连续按 3 次 z -> 擦除 3 个 z打开知乎
RegisterMultiTap("z", 3, TripleZAction)

; 配置 3: 连续按 3 次 r -> 擦除 3 个 r 并打开reddit
RegisterMultiTap("r", 3, TripleRAction)

RegisterMultiTap("y", 3, TripleYAction)

; ---【多击调用的具体函数】---
TripleAltAction() {
    Send("{Control}")     ; 清除 Alt 激活的系统菜单栏焦点
    Send("^v")            ; 执行粘贴
    ShowTip("📋 已粘贴")
}

QuadSpaceAction() {
    Send("{Backspace 4}") ; 擦除输入的 4 个空格
    Sleep(30)             ; 给系统 30 毫秒处理物理按键释放缓冲
    
    Send("^+p")
    ShowTip("⚡ activated QuadSpaceAction")
}

TripleNAction() {
    Send("{Backspace 3}") ; 擦除输入的 3 个 n
    SmartRun(notepadPath)
    Sleep(30)
}

TripleZAction() {
    Send("{Backspace 3}") ; 擦除输入的 3 个 n
    SmartRun(zhihuPath)
    Sleep(30)
}

TripleRAction() {
    Send("{Backspace 3}") ; 擦除输入的 3 个 n
    SmartRun(redditPath)
    Sleep(30)
}

TripleYAction() {
    Send("{Backspace 3}") ; 擦除输入的 3 个 n
    SmartRun(YouTubePath)
    Sleep(30)
}


; 通用轻量气泡提示
ShowTip(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -1000)
}

; ==========================================
; 5. 多击逻辑的核心通用引擎（支持自定义连击次数）
; ==========================================
RegisterMultiTap(key, targetCount, callback, maxInterval := 400) {
    static stateMap := Map()
    stateMap[key] := { count: 0, lastTime: 0, triggered: false }

    Hotkey("~" . key, (*) => ProcessTap(key, targetCount, callback, maxInterval))

    ProcessTap(k, target, cb, interval) {
        st := stateMap[k]
        now := A_TickCount
        
        if (now - st.lastTime > interval) {
            st.count := 0
            st.triggered := false
        }
        
        st.lastTime := now

        if (st.triggered) {
            return
        }

        st.count++
        
        if (st.count == target) {
            st.triggered := true 
            st.count := 0        
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
; 7. 划词选中文本自动复制（VS Code 深度优化版）
; ==============================================================================
MIN_DRAG_DISTANCE := 30    ; 位移门槛提升至 30px（更有效防止微小手抖）
MAX_DRAG_TIME_MS  := 2000  ; 拖拽时长限制 2 秒

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

    ; 1. 基础过滤：截图界面不触发
    if WinActive("ahk_class Windows.UI.Core.CoreWindow") 
    || WinActive("ahk_exe SnippingTool.exe") 
    || WinActive("ahk_exe SnippingToolApp.exe")
        return

    ; 2. 过滤：Chrome 顶部工具栏/扩展图标区域（Y < 120 像素）
    if WinActive("ahk_exe chrome.exe") && (g_AutoCopy_StartY < 120)
        return

    ; 3. 专为 VS Code 优化：过滤左侧侧边栏、行号区(X < 80) 以及 顶部Tab区(Y < 70)
    if WinActive("ahk_exe Code.exe") {
        if (g_AutoCopy_StartX < 80 || g_AutoCopy_StartY < 70)
            return
    }

    ; 4. 过滤：按住 Shift/Ctrl/Alt 键拖拽时不触发
    if GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P")
        return

    ; 5. 过滤：拖拽时长过长（如拖拽滚动条、拖动窗口）
    dragTime := A_TickCount - g_AutoCopy_StartTime
    if (dragTime > MAX_DRAG_TIME_MS)
        return

    ; 6. 位移判定：计算拖拽距离
    MouseGetPos(&endX, &endY)
    deltaX := Abs(endX - g_AutoCopy_StartX)
    deltaY := Abs(endY - g_AutoCopy_StartY)

    if (deltaX > MIN_DRAG_DISTANCE || deltaY > MIN_DRAG_DISTANCE) {
        
        ; 7. 保护：剪贴板中有图片数据时绝对不去重写
        if DllCall("IsClipboardFormatAvailable", "UInt", 2) || DllCall("IsClipboardFormatAvailable", "UInt", 8)
            return

        ; 记录复制前剪贴板中的文本
        priorText := A_Clipboard

        ; 给系统 80ms 渲染高亮，同时判断用户是否紧接着按了删除/粘贴键（避免想替换代码时被复制覆盖）
        Sleep(80) 
        if GetKeyState("Backspace", "P") || GetKeyState("Delete", "P") || GetKeyState("v", "P")
            return

        ; 备份完整剪贴板
        oldClip := ClipboardAll()
        A_Clipboard := ""

        Send("^c")

        if ClipWait(0.15, 1) {
            currentText := Trim(A_Clipboard)
            
            ; 核心校验：真的选中了非空文本，且内容发生了改变
            if (currentText != "" && currentText != priorText) {
                ShowTip("Copied")
            } else {
                ; 没选中有效新文本，无缝还原原剪贴板
                A_Clipboard := oldClip 
            }
        } else {
            ; 复制超时，还原原剪贴板
            A_Clipboard := oldClip 
        }
    }
}
; ==============================================================================
; 8. 鼠标右键连击触发粘贴（修正版）
; ==============================================================================

RClick_TargetCount := 3     ; 触发所需连击次数 (3 = 连续点 3 次右键)
RClick_TimeLimit   := 450   ; 连击判断的最大时间间隔(毫秒)

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
        clickCount := 0 ; 清零计数
        
        ; 核心修正：先触发粘贴，随后把弹出的右键菜单按 Esc 关掉
        Send("^v")
        Sleep(50)
        Send("{Esc}")
        
        ; 尝试调用已有 ShowTip，若不存在则使用默认 ToolTip
        try {
            ShowTip("📋 已粘贴")
        } catch {
            ToolTip("📋 已粘贴")
            SetTimer(() => ToolTip(), -1000)
        }
    }
}