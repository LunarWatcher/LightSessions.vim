vim9script

def SetupVariables()
    if !exists("g:LightSessionsDir")
        g:LightSessionsDir = $HOME .. (has("win32") ? "/vimfiles" : "/.vim") .. "/sessions"
    endif
    if !exists("g:LightSessionsCurrSession")
        g:LightSessionsCurrSession = ""
    endif
    if !exists("g:LightSessionsCaseInsensitive")
        g:LightSessionsCaseInsensitive = 1
    endif
    if !exists("g:LightSessionsAutoSave")
        g:LightSessionsAutoSave = 1
    endif

    if !isdirectory(g:LightSessionsDir)
        mkdir(g:LightSessionsDir)
    endif
enddef
SetupVariables()

export def ListSessions(): list<string>
    if isdirectory(g:LightSessionsDir)
        var sessions = glob(g:LightSessionsDir .. "/*.vim", 0, 1)
            ->filter("!isdirectory(v:val)")
            ->map('fnamemodify(v:val, ":t:r")')

        return sessions
    else
        return []
    endif
enddef

export def SaveSession(_sessName = "")
    var sessName = _sessName
    if (sessName == "" && g:LightSessionsCurrSession != "")
        sessName = g:LightSessionsCurrSession
    elseif (sessName == "")
        echoerr "Session name required: no existing session exists to infer the name from"
        return
    endif
    g:LightSessionsCurrSession = sessName

    exec "mksession!" g:LightSessionsDir .. "/" .. sessName .. ".vim"
enddef

export def LoadSession(sessName: string)
    var file = g:LightSessionsDir .. "/" .. sessName .. ".vim"
    if !filereadable(file)
        echoerr "File doesn't exist: " .. file
        return
    endif
    g:LightSessionsCurrSession = sessName
    exec "source" file
enddef

export def AutoSaveCurrSess()
    if g:LightSessionsCurrSession != "" && g:LightSessionsAutoSave == 1
        SaveSession()
    endif
enddef

export def StartifyList(): list<any>
    var sessions = ListSessions()

    return sessions->mapnew((_, v) => {
        return {"line": v, "cmd": ":LoadSession " .. v}
    })
enddef
