// ============================================================================
// Nilesoft Shell - V3.1 DIRECTORY
//
// Obiettivo:
//   Rifinitura del menu per DIRECTORY selezionate.
//   Le regole di questo file NON devono riorganizzare ZIP/TXT/JPG/PDF/etc.
//
// Confermato dai test V3:
//   - type='dir' isola correttamente il contesto directory.
//   - TeraCopy: where=this.disabled nasconde soltanto la voce grigia.
//   - Programmi accetta correttamente le shell extension provate.
//   - Terminale/File manage/Vai a funzionano se importati dentro Sistema.
//   - Explorer raccoglie correttamente i tre comandi poco usati.
// ============================================================================


// ---------------------------------------------------------------------------
// OPERAZIONI PRINCIPALI
// ---------------------------------------------------------------------------

modify(type='dir' find='Taglia' pos=0)
modify(type='dir' find='Copia' pos=1)
modify(type='dir' find='Incolla' pos=2)
modify(type='dir' find='Rinomina' pos=3)
modify(type='dir' find='Elimina' pos=4)
modify(type='dir' find='Proprietà' pos=5)

// WinRAR e "Usa come origine del collegamento" fanno parte dello stesso
// blocco operativo principale.
modify(type='dir' find='WinRAR*' pos=6)
modify(type='dir' find='Usa come origine del collegamento*' pos=7 sep='after')


// ---------------------------------------------------------------------------
// TERACOPY
// ---------------------------------------------------------------------------

// Il Registro contiene due handler TeraCopy; uno dei due appare disabilitato.
// Nascondiamo esclusivamente il target realmente disabled.
modify(type='dir' find='TeraCopy*' where=this.disabled vis=hidden)


// ---------------------------------------------------------------------------
// PROGRAMMI
// ---------------------------------------------------------------------------

menu(type='dir' title='Programmi' image=icon.manage)
{
    menu(title='MusicBee')
    {
    }

    menu(title='VLC')
    {
    }
}

modify(type='dir' find='WizTree' parent='Programmi')
modify(type='dir' find='MediaInfo' parent='Programmi')

// Dropbox espone più comandi distinti: entrambi vanno in Programmi.
modify(type='dir' find='Trasferisci copia*' parent='Programmi')
modify(type='dir' find='Sposta in Dropbox*' parent='Programmi')

modify(type='dir' find='Kaspersky' parent='Programmi')
modify(type='dir' find='SmartFTP*' parent='Programmi')
modify(type='dir' find='Mp3tag' parent='Programmi')
modify(type='dir' find='Apri con Code' parent='Programmi')
modify(type='dir' find='Open with Visual Studio' parent='Programmi')
modify(type='dir' find='Browse with IrfanView' parent='Programmi')
modify(type='dir' find='Open Git GUI here' parent='Programmi')
modify(type='dir' find='Open Git Bash here' parent='Programmi')
modify(type='dir' find='Combina file in Acrobat*' parent='Programmi')
modify(type='dir' find="Assembla un'immagine ISO" parent='Programmi')
modify(type='dir' find='Acronis True Image' parent='Programmi')

// MusicBee
modify(type='dir' find='Riproduci con MusicBee' parent='MusicBee')
modify(type='dir' find='Accoda come prossimo in MusicBee' parent='MusicBee')
modify(type='dir' find='Accoda per ultimo in MusicBee' parent='MusicBee')

// VLC
modify(type='dir' find='Aggiungi alla scaletta del lettore multimediale VLC' parent='VLC')
modify(type='dir' find='Riproduci con il lettore multimediale VLC' parent='VLC')


// ---------------------------------------------------------------------------
// SISTEMA
// ---------------------------------------------------------------------------

// Prima nascondiamo le tre voci Winaero originali.
// Le ricreiamo più sotto, già organizzate sotto "Owner e permessi".
modify(type='dir' find='Change owner*' vis=hidden)
modify(type='dir' find='View owner*' vis=hidden)
modify(type='dir' find='Take Ownership*' vis=hidden)

menu(type='dir' title='Sistema' image=icon.settings)
{
    // Menu nativi Nilesoft: nascono direttamente dentro Sistema.
    import 'terminal.nss'
    import 'file-manage.nss'
    import 'goto.nss'

    separator

    menu(title='Owner e permessi' image=icon.run_as_administrator)
    {
        // Equivalente della funzione "View owner" registrata da Winaero.
        item(title='View owner'
             image='imageres.dll,-1029'
             cmd='powershell.exe'
             args="-NoExit -Command \"Get-ACL '@sel.path' | Format-List -Property Owner\"")

        menu(title='Change owner' image='imageres.dll,-1029')
        {
            // Le tre destinazioni sono quelle presenti nel menu Winaero.
            item(title='Change to Administrators'
                 admin
                 cmd args='/c icacls "@sel.path" /setowner "Administrators" /c & pause')

            item(title='Change to Everyone'
                 admin
                 cmd args='/c icacls "@sel.path" /setowner "Everyone" /c & pause')

            item(title='Change to TrustedInstaller'
                 admin
                 cmd args='/c icacls "@sel.path" /setowner "NT Service\TrustedInstaller" /t /c /l & pause')
        }

        separator

        // È lo stesso tipo di operazione che prima era dentro file-manage.nss;
        // ora viene presentata nel gruppo logico Owner e permessi.
        item(title='Take ownership'
             image=icon.run_as_administrator
             admin
             cmd args='/K takeown /f "@sel.path" /r /d y && icacls "@sel.path" /grant *S-1-5-32-544:F /t /c /l /q')
    }
}

// Comandi di console già esistenti nel Registro/Windows.
modify(type='dir' find='Prompt dei comandi*' parent='Sistema')
modify(type='dir' find='Windows PowerShell*' parent='Sistema')
modify(type='dir' find='Open MobaXterm terminal here' parent='Sistema')
modify(type='dir' find='Find text using MobaFind' parent='Sistema')
modify(type='dir' find='Compare using MobaDiff' parent='Sistema')
modify(type='dir' find='Apri nel Terminale' parent='Sistema')


// ---------------------------------------------------------------------------
// EXPLORER
// ---------------------------------------------------------------------------

menu(type='dir' title='Explorer' image=icon.file_explorer)
{
}

modify(type='dir' find='Apri in una nuova scheda' parent='Explorer')
modify(type='dir' find='Apri in una nuova finestra' parent='Explorer')
modify(type='dir' find='Aggiungi ad Accesso rapido' parent='Explorer')
modify(type='dir' find='Aggiungi a Start*' parent='Explorer')

// "Altre opzioni" resta intenzionalmente al livello principale.
// Nei test precedenti non si è comportato come una normale voce spostabile.


// ---------------------------------------------------------------------------
// PULIZIA
// ---------------------------------------------------------------------------

remove(type='dir' find='New folder with selection')
remove(type='dir' find='Sovrascrivi con BleachBit')
