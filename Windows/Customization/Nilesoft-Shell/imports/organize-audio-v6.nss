// ============================================================================
// Nilesoft Shell - V6.4 AUDIO PRACTICAL FINAL
// Scope: SOLO .MP3 / .FLAC / .WAV
//
// Strategia:
// - MusicBee originale nascosto e ricreato come submenu Nilesoft.
// - VLC originale nascosto e ricreato come item Nilesoft.
// - Windows Media Player Legacy rimosso dal contesto audio.
// - TeraCopy / WinRAR / Usa come origine NON vengono più forzati di posizione.
// ============================================================================


// ---------------------------------------------------------------------------
// NASCONDI / RIMUOVI LE VOCI ORIGINALI RIBELLI
// ---------------------------------------------------------------------------

// MusicBee originale
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Riproduci con MusicBee' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Accoda come prossimo in MusicBee' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Accoda per ultimo in MusicBee' vis=hidden)

// VLC originale
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Aggiungi alla scaletta del lettore multimediale VLC' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Riproduci con il lettore multimediale VLC' vis=hidden)

// Windows Media Player Legacy / Media Player Windows:
// rimosso nel solo contesto audio; resta comunque disponibile via Apri con.
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Riproduci con Windows Media Player Legacy')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Aggiungi all*Windows Media Player Legacy*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Aggiungi alla coda di riproduzione del lettore multimediale')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Riproduci con il lettore multimediale')


// ---------------------------------------------------------------------------
// SEZIONE AUDIO CONTROLLATA DA NILESOFT
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Play' pos=0)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Riproduci' pos=0)

// MusicBee ricreato direttamente.
menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) title='MusicBee' pos=1)
{
    item(title='Riproduci con MusicBee'
         cmd='C:\Program Files (x86)\MusicBee\MusicBee.exe'
         args='"@sel.path" /Play')

    item(title='Accoda come prossimo in MusicBee'
         cmd='C:\Program Files (x86)\MusicBee\MusicBee.exe'
         args='"@sel.path" /QueueNext')

    item(title='Accoda per ultimo in MusicBee'
         cmd='C:\Program Files (x86)\MusicBee\MusicBee.exe'
         args='"@sel.path" /QueueLast')
}

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='MediaInfo' pos=2)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Mp3tag' pos=3)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='dBpoweramp*' pos=4)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Convert To' pos=5)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Edit ID Tags' pos=6)

// VLC ricreato.
item(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav'))
     title='Aggiungi alla scaletta VLC'
     image='C:\Program Files\VideoLAN\VLC\vlc.exe'
     pos=7
     cmd='C:\Program Files\VideoLAN\VLC\vlc.exe'
     args='--started-from-file --playlist-enqueue "@sel.path"')

item(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav'))
     title='Riproduci con VLC'
     image='C:\Program Files\VideoLAN\VLC\vlc.exe'
     pos=8
     sep='after'
     cmd='C:\Program Files\VideoLAN\VLC\vlc.exe'
     args='--started-from-file --no-playlist-enqueue "@sel.path"')


// ---------------------------------------------------------------------------
// OPERAZIONI FILE
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Taglia' pos=9)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Copia' pos=10)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Elimina' pos=11)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Rinomina' pos=12)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Proprietà' pos=13)

// TeraCopy: manteniamo l'originale attivo; nascondiamo solo eventuali duplicati disabled.
modify(type='file' where=((str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) && this.disabled) find='TeraCopy*' vis=hidden)

// WinRAR e "Usa come origine del collegamento" restano originali.
// Non imponiamo più posizioni aggressive.


// ---------------------------------------------------------------------------
// PROGRAMMI
// ---------------------------------------------------------------------------

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) title='Programmi' image=icon.manage)
{
}

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Kaspersky' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='SmartFTP*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Apri con Code' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Acronis True Image' parent='Programmi')


// ---------------------------------------------------------------------------
// SISTEMA
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Change owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='View owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Take Ownership*' vis=hidden)

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) title='Sistema' image=icon.settings)
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

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Trasmetti su dispositivo*' pos=bottom)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Apri con*' pos=bottom)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Altre opzioni*' pos=bottom)


// ---------------------------------------------------------------------------
// PULIZIA
// ---------------------------------------------------------------------------

remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Aggiungi a Preferiti*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='New folder with selection')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.mp3') || str.equals(str.lower(sel.file.ext), '.flac') || str.equals(str.lower(sel.file.ext), '.wav')) find='Sovrascrivi con BleachBit')
