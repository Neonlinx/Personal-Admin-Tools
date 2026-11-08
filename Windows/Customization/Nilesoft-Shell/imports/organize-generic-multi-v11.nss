// ============================================================================
// Nilesoft Shell - V11 GENERIC FILES & MULTI-SELECTION
//
// A) File singoli generici:
//    senza estensione, NSS, BAK, MD, YAML/YML, TOML, CONF.
//
// B) Selezione multipla:
//    menu uniforme e prudente, indipendente dall'elemento cliccato.
// ============================================================================


// ============================================================================
// A) FILE GENERICI - SOLO SELEZIONE SINGOLA
// ============================================================================

modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Apri' pos=0)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Modifica' pos=1)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Modifica con Notepad++*' pos=2)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Modifica nel Blocco note*' pos=3 sep='after')

modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Taglia' pos=4)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Copia' pos=5)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Elimina' pos=6)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Rinomina' pos=7)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Proprietà' pos=8)

modify(type='file' mode='single' where=((
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) && this.disabled) find='TeraCopy*' vis=hidden)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='TeraCopy*' pos=9)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='WinRAR*' pos=10)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Usa come origine del collegamento*' pos=11 sep='after')

menu(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) title='Programmi' image=icon.manage)
{
}
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Trasferisci copia*' parent='Programmi')
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Kaspersky' parent='Programmi')
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='SmartFTP*' parent='Programmi')
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Apri con Code' parent='Programmi')
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Acronis True Image' parent='Programmi')
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Mp3tag' parent='Programmi')

modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Change owner*' vis=hidden)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='View owner*' vis=hidden)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Take Ownership*' vis=hidden)

menu(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) title='Sistema' image=icon.settings)
{
    menu(title='Owner e permessi' image=icon.run_as_administrator)
    {
        item(title='View owner'
             image='imageres.dll,-1029'
             cmd='powershell.exe'
             args="-NoExit -Command \"Get-ACL '@sel.path' | Format-List -Property Owner\"")

        menu(title='Change owner' image='imageres.dll,-1029')
        {
            item(title='Change to Administrators' admin
                 cmd args='/c icacls "@sel.path" /setowner "Administrators" /c & pause')
            item(title='Change to Everyone' admin
                 cmd args='/c icacls "@sel.path" /setowner "Everyone" /c & pause')
            item(title='Change to TrustedInstaller' admin
                 cmd args='/c icacls "@sel.path" /setowner "NT Service\TrustedInstaller" /c /l & pause')
        }

        separator

        item(title='Take ownership' image=icon.run_as_administrator admin
             cmd args='/K takeown /f "@sel.path" && icacls "@sel.path" /grant *S-1-5-32-544:F /c /l')
    }
}

modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Apri con*' pos=bottom)
modify(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Altre opzioni*' pos=bottom)

remove(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Aggiungi a Preferiti*')
remove(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='New folder with selection')
remove(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Sovrascrivi con BleachBit')
remove(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Converti a Adobe PDF*')
remove(type='file' mode='single' where=(
    str.equals(sel.file.ext, '')
    || str.equals(str.lower(sel.file.ext), '.nss')
    || str.equals(str.lower(sel.file.ext), '.bak')
    || str.equals(str.lower(sel.file.ext), '.md')
    || str.equals(str.lower(sel.file.ext), '.yaml')
    || str.equals(str.lower(sel.file.ext), '.yml')
    || str.equals(str.lower(sel.file.ext), '.toml')
    || str.equals(str.lower(sel.file.ext), '.conf')
) find='Combina file in Acrobat*')


// ============================================================================
// B) MULTISELEZIONE - QUALSIASI COMBINAZIONE DI FILE/CARTELLE
// ============================================================================

// Elimina le azioni che dipendono dal tipo dell'elemento cliccato.
remove(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Apri|Modifica|Riproduci*|Play|MediaInfo|Mp3tag|dBpoweramp*|Convert To|Edit ID Tags')

remove(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='*MusicBee*|*VLC*|Converti a Adobe PDF*|Combina file in Acrobat*|Condividi con Adobe Acrobat*')

remove(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Apri nel Terminale|Prompt dei comandi*|Windows PowerShell*|Aggiungi alla barra delle applicazioni|Aggiungi al menu Start')

remove(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Aggiungi a Preferiti*|Aggiungi ad Accesso rapido|New folder with selection|Sovrascrivi con BleachBit')

remove(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Change owner*|View owner*|Take Ownership*')

remove(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Usa come origine del collegamento*')

remove(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Rinomina')

// Operazioni di gruppo.
modify(type='file|dir' mode='multiple' where=@(sel.count > 1) find='Taglia' pos=0)
modify(type='file|dir' mode='multiple' where=@(sel.count > 1) find='Copia' pos=1)
modify(type='file|dir' mode='multiple' where=@(sel.count > 1) find='Elimina' pos=2)
modify(type='file|dir' mode='multiple' where=@(sel.count > 1) find='Proprietà' pos=3 sep='after')

// TeraCopy e WinRAR sono realmente utili sulle selezioni multiple.
modify(type='file|dir' mode='multiple' where=@(sel.count > 1 && this.disabled)
       find='TeraCopy*' vis=hidden)
modify(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='TeraCopy*' pos=4)
modify(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='WinRAR*' pos=5 sep='after')

// Programmi realmente sensati sull'intero gruppo.
menu(type='file|dir' mode='multiple' where=@(sel.count > 1)
     title='Programmi' image=icon.manage)
{
}
modify(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Kaspersky' parent='Programmi')
modify(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='SmartFTP*' parent='Programmi')
modify(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Trasferisci copia*' parent='Programmi')
modify(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Acronis True Image' parent='Programmi')

// Le opzioni native restano accessibili in fondo.
modify(type='file|dir' mode='multiple' where=@(sel.count > 1)
       find='Altre opzioni*' pos=bottom)
