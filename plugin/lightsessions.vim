vim9script

if exists("g:LightSessionsLoaded")
    finish
endif
g:LightSessionsLoaded = 1

import autoload "lightsessions.vim" as lsa

#echom lsa.ListSessions()

def SortByStridx(a: string, b: string, search: string): number
    var aidx = a->stridx(search)
    var bidx = b->stridx(search)

    # Not sure if 
    if (aidx == bidx)
        return 0
    elseif (aidx > bidx)
        return 1
    else
        return -1
    endif
enddef

def FilterSessionsPredicate(item: string, ArgLead: string): bool
    if ArgLead == ""
        return true
    endif

    var _item = item
    if g:LightSessionsCaseInsensitive
        return item->tolower()->stridx(ArgLead->tolower()) != -1
    endif

    return _item->stridx(ArgLead) != -1
enddef

def CompleteSessions(ArgLead: string, CmdLine: any, CursorPos: any): list<string>
    echo lsa.ListSessions()
    return lsa.ListSessions()
        ->filter((_, item) => FilterSessionsPredicate(item, ArgLead))
        ->sort((a, b) => SortByStridx(a, b, ArgLead))
enddef

command! -complete=customlist,<SID>CompleteSessions -nargs=? SaveSession :call <SID>lsa.SaveSession(<f-args>)
command! -complete=customlist,<SID>CompleteSessions -nargs=1 LoadSession :call <SID>lsa.LoadSession(<f-args>)

augroup LightSessions
    au!
    autocmd VimLeavePre * call <SID>lsa.AutoSaveCurrSess()
augroup END
