// ============================================================================
// Nilesoft Shell - V7 VIDEO BASE
//
// Scope:
//   .MKV .AVI .MP4 .MOV .M4V .WMV .MPEG .MPG .WEBM .M2TS .MTS
//
// Scelte:
//   - VLC e MediaInfo restano in prima vista.
//   - WinRAR resta in prima vista.
//   - BleachBit viene eliminato.
//   - Windows Media Player resta accessibile da "Apri con".
// ============================================================================


// ---------------------------------------------------------------------------
// VIDEO - AZIONI PRINCIPALI
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Riproduci' pos=0)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Aggiungi alla scaletta del lettore multimediale VLC' pos=1)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Riproduci con il lettore multimediale VLC' pos=2)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='MediaInfo' pos=3 sep='after')


// ---------------------------------------------------------------------------
// OPERAZIONI FILE
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Taglia' pos=4)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Copia' pos=5)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Elimina' pos=6)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Rinomina' pos=7)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Proprietà' pos=8)

// TeraCopy resta originale; nascondiamo soltanto eventuali copie disabled.
modify(type='file' where=((str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) && this.disabled) find='TeraCopy*' vis=hidden)

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='WinRAR*' pos=9)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Usa come origine del collegamento*' pos=10 sep='after')


// ---------------------------------------------------------------------------
// PROGRAMMI
// ---------------------------------------------------------------------------

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) title='Programmi' image=icon.manage)
{
}

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Kaspersky' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='SmartFTP*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Mp3tag' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Apri con Code' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Acronis True Image' parent='Programmi')


// ---------------------------------------------------------------------------
// SISTEMA
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Change owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='View owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Take Ownership*' vis=hidden)

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) title='Sistema' image=icon.settings)
{
    menu(title='Owner e permessi' image=icon.run_as_administrator)
    {
        item(title='View owner'
             image='imageres.dll,-1029'
             cmd='powershell.exe'
             args="-NoExit -Command \"Get-ACL '@sel.path' | Format-List -Property Owner\"")

        menu(title='Change owner' image='imageres.dll,-1029')
        {
            item(title='Change to Administrators'
                 admin
                 cmd args='/c icacls "@sel.path" /setowner "Administrators" /c & pause')

            item(title='Change to Everyone'
                 admin
                 cmd args='/c icacls "@sel.path" /setowner "Everyone" /c & pause')

            item(title='Change to TrustedInstaller'
                 admin
                 cmd args='/c icacls "@sel.path" /setowner "NT Service\TrustedInstaller" /c /l & pause')
        }

        separator

        item(title='Take ownership'
             image=icon.run_as_administrator
             admin
             cmd args='/K takeown /f "@sel.path" && icacls "@sel.path" /grant *S-1-5-32-544:F /c /l')
    }
}


// ---------------------------------------------------------------------------
// PARTE BASSA
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Trasmetti su dispositivo*' pos=bottom)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Apri con*' pos=bottom)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Altre opzioni*' pos=bottom)


// ---------------------------------------------------------------------------
// PULIZIA
// ---------------------------------------------------------------------------

remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Aggiungi a Preferiti*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='New folder with selection')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mkv') || str.equals(str.lower(sel.file.ext), '.avi') || str.equals(str.lower(sel.file.ext), '.mp4') || str.equals(str.lower(sel.file.ext), '.mov') || str.equals(str.lower(sel.file.ext), '.m4v') || str.equals(str.lower(sel.file.ext), '.wmv') || str.equals(str.lower(sel.file.ext), '.mpeg') || str.equals(str.lower(sel.file.ext), '.mpg') || str.equals(str.lower(sel.file.ext), '.webm') || str.equals(str.lower(sel.file.ext), '.m2ts') || str.equals(str.lower(sel.file.ext), '.mts')) find='Sovrascrivi con BleachBit')
