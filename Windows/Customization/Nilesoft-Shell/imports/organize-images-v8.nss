// ============================================================================
// Nilesoft Shell - V8 IMAGES BASE
//
// Scope:
//   JPG/JPEG/JFIF, PNG, GIF, BMP, WEBP, HEIC/HEIF,
//   TIFF, ICO e AVIF.
//
// Note:
//   - "Altre opzioni" resta visibile perché contiene rotazione, stampa
//     e impostazione dello sfondo.
//   - "Apri con" resta visibile perché contiene IrfanView e altre app.
//   - Le voci Adobe compaiono solo nei formati per cui Windows le espone.
// ============================================================================


// ---------------------------------------------------------------------------
// AZIONI IMMAGINE PRINCIPALI
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Apri' pos=0)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='MediaInfo' pos=1)


// ---------------------------------------------------------------------------
// OPERAZIONI FILE
// ---------------------------------------------------------------------------

// Il separatore prima di Taglia chiude la sezione immagine anche quando
// una o entrambe le voci Adobe non sono disponibili.
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Taglia' pos=4 sep='before')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Copia' pos=5)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Elimina' pos=6)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Rinomina' pos=7)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Proprietà' pos=8)

// TeraCopy rimane l'handler originale; nascondiamo solo copie disabilitate.
modify(type='file' where=((str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) && this.disabled) find='TeraCopy*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='TeraCopy*' pos=9)

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='WinRAR*' pos=10)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Usa come origine del collegamento*' pos=11 sep='after')


// ---------------------------------------------------------------------------
// COMANDI IMMAGINE WINDOWS: SEMPRE ACCESSIBILI
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Altre opzioni*' pos=12)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Apri con*' pos=13)


// ---------------------------------------------------------------------------
// PROGRAMMI
// ---------------------------------------------------------------------------

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) title='Programmi' image=icon.manage pos=14)
{
}

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Kaspersky' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='SmartFTP*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Apri con Code' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Acronis True Image' parent='Programmi')


// ---------------------------------------------------------------------------
// SISTEMA
// ---------------------------------------------------------------------------

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Change owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='View owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Take Ownership*' vis=hidden)

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) title='Sistema' image=icon.settings pos=15)
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

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Trasmetti su dispositivo*' pos=bottom)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Aggiungi a un album condiviso*' pos=bottom)


// ---------------------------------------------------------------------------
// PULIZIA
// ---------------------------------------------------------------------------

remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Converti a Adobe PDF*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Combina file in Acrobat*')

remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Aggiungi a Preferiti*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='New folder with selection')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.jpg') || str.equals(str.lower(sel.file.ext), '.jpeg') || str.equals(str.lower(sel.file.ext), '.jfif') || str.equals(str.lower(sel.file.ext), '.png') || str.equals(str.lower(sel.file.ext), '.gif') || str.equals(str.lower(sel.file.ext), '.bmp') || str.equals(str.lower(sel.file.ext), '.webp') || str.equals(str.lower(sel.file.ext), '.heic') || str.equals(str.lower(sel.file.ext), '.heif') || str.equals(str.lower(sel.file.ext), '.tif') || str.equals(str.lower(sel.file.ext), '.tiff') || str.equals(str.lower(sel.file.ext), '.ico') || str.equals(str.lower(sel.file.ext), '.avif')) find='Sovrascrivi con BleachBit')
