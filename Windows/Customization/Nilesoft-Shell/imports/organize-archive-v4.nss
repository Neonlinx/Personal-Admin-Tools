// ============================================================================
// Nilesoft Shell - V4 ARCHIVE BASE
//
// Scope:
//   SOLO file .ZIP / .RAR / .7Z
//
// La V3.1.1 Directory resta indipendente.
// ============================================================================


// ---------------------------------------------------------------------------
// BLOCCO PRINCIPALE - ARCHIVI
// ---------------------------------------------------------------------------

// Azioni specifiche dell'archivio sempre subito visibili.
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Apri' pos=0)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='WinRAR*' pos=1)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Estrai tutto*' pos=2 sep='after')

// Operazioni standard sul file.
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Taglia' pos=3)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Copia' pos=4)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Elimina' pos=5)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Rinomina' pos=6)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Proprietà' pos=7)

// Comando usato spesso: resta nel livello principale.
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Usa come origine del collegamento*' pos=8 sep='after')


// ---------------------------------------------------------------------------
// PROGRAMMI - ARCHIVI
// ---------------------------------------------------------------------------

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) title='Programmi' image=icon.manage)
{
}

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Kaspersky' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='SmartFTP*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Apri con Code' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Acronis True Image' parent='Programmi')

// TeraCopy: sposta la voce attiva sotto Programmi e ignora eventuali istanze disabled.
modify(type='file' where=((str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) && !this.disabled) find='TeraCopy*' parent='Programmi')
modify(type='file' where=((str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) && this.disabled) find='TeraCopy*' vis=hidden)


// ---------------------------------------------------------------------------
// SISTEMA - ARCHIVI
// ---------------------------------------------------------------------------

// Le originali Winaero vengono nascoste SOLTANTO sugli archivi.
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Change owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='View owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Take Ownership*' vis=hidden)

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) title='Sistema' image=icon.settings)
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
// VOCI CHE RESTANO NEL LIVELLO PRINCIPALE
// ---------------------------------------------------------------------------

// Non forziamo queste voci in sottomenù: sono utili e/o speciali.
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Apri con*' pos=bottom)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Altre opzioni*' pos=bottom)


// ---------------------------------------------------------------------------
// PULIZIA - ARCHIVI
// ---------------------------------------------------------------------------

remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Aggiungi a Preferiti*')

remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='New folder with selection')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.zip') || str.equals(str.lower(sel.file.ext), '.rar') || str.equals(str.lower(sel.file.ext), '.7z')) find='Sovrascrivi con BleachBit')
