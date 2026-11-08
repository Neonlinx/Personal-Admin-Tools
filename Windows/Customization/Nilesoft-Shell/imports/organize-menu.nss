// ============================================================================
// Nilesoft Shell - Organizzazione menu contestuale - V2.2
// ============================================================================


// ---------------------------------------------------------------------------
// OPERAZIONI PRINCIPALI SU FILE/CARTELLE
// ---------------------------------------------------------------------------

// Questi comandi restano tutti nello stesso blocco principale.
modify(find='Taglia' pos=0)
modify(find='Copia' pos=1)
modify(find='Incolla' pos=2)
modify(find='Rinomina' pos=3)
modify(find='Elimina' pos=4)
modify(find='Proprietà' pos=5)
modify(find='WinRAR*' pos=6)
modify(find='Usa come origine del collegamento*' pos=7 sep='after')


// ---------------------------------------------------------------------------
// PROGRAMMI
// ---------------------------------------------------------------------------

menu(title='Programmi' image=\uE71D)
{
    menu(title='MusicBee')
    {
    }

    menu(title='VLC')
    {
    }
}

modify(find='WizTree' parent='Programmi')
modify(find='Sovrascrivi con BleachBit' parent='Programmi')
modify(find='MediaInfo' parent='Programmi')
modify(find='Trasferisci copia*' parent='Programmi')
modify(find='Kaspersky' parent='Programmi')
modify(find='Mp3tag' parent='Programmi')
modify(find='Apri con Code' parent='Programmi')
modify(find='Open with Visual Studio' parent='Programmi')
modify(find='Browse with IrfanView' parent='Programmi')
modify(find='Open Git GUI here' parent='Programmi')
modify(find='Open Git Bash here' parent='Programmi')
modify(find='Combina file in Acrobat*' parent='Programmi')
modify(find="Assembla un'immagine ISO" parent='Programmi')
modify(find='Acronis True Image' parent='Programmi')

// MusicBee
modify(find='Riproduci con MusicBee' parent='MusicBee')
modify(find='Accoda come prossimo in MusicBee' parent='MusicBee')
modify(find='Accoda per ultimo in MusicBee' parent='MusicBee')

// VLC
modify(find='Aggiungi alla scaletta del lettore multimediale VLC' parent='VLC')
modify(find='Riproduci con il lettore multimediale VLC' parent='VLC')


// ---------------------------------------------------------------------------
// SISTEMA
// ---------------------------------------------------------------------------

menu(title='Sistema' image=\uE770)
{
    import 'terminal.nss'
    import 'file-manage.nss'
    import 'goto.nss'

    separator

    // Creiamo qui direttamente Take ownership, perché questa è una nostra voce
    // controllabile e non dipende dalla shell extension esterna.
    menu(title='Owner e permessi' image=\uE194)
    {
        item(type='file|dir|back.dir|drive' title='Take ownership'
             image=[\uE194,#f00] admin
             cmd args='/K takeown /f "@sel.path" @if(sel.type==1,null,"/r /d y") && icacls "@sel.path" /grant *S-1-5-32-544:F @if(sel.type==1,"/c /l","/t /c /l /q")')
    }
}

modify(find='Prompt dei comandi*' parent='Sistema')
modify(find='Windows PowerShell*' parent='Sistema')
modify(find='Apri nel Terminale' parent='Sistema')

// Se presenti, proviamo a raccogliere anche le shell extension di ownership.
modify(find='Change owner*' parent='Owner e permessi')
modify(find='View owner*' parent='Owner e permessi')


// ---------------------------------------------------------------------------
// EXPLORER - comandi usati raramente
// ---------------------------------------------------------------------------

menu(title='Explorer' image=\uE8B7)
{
}

// Portiamo qui i comandi poco usati.
modify(find='Apri in una nuova scheda' parent='Explorer')
modify(find='Apri in una nuova finestra' parent='Explorer')
modify(find='Aggiungi ad Accesso rapido' parent='Explorer')
modify(find='Altre opzioni*' parent='Explorer')
modify(find='Aggiungi a Start*' parent='Explorer')


// ---------------------------------------------------------------------------
// VOCI DA ELIMINARE
// ---------------------------------------------------------------------------

remove(find='New folder with selection')

// TeraCopy resta ancora intenzionalmente invariato.
// Dobbiamo prima distinguere in modo affidabile la voce attiva dalla voce grigia.
