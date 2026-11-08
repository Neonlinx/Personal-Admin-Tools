// ============================================================================
// Nilesoft Shell - V9 PDF BASE
// Scope: SOLO file .PDF
// ============================================================================

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Apri con Adobe Acrobat' pos=0)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Modifica con Adobe Acrobat' pos=1)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Combina file in Acrobat*' pos=2 sep='after')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Taglia' pos=3)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Copia' pos=4)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Elimina' pos=5)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Rinomina' pos=6)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Proprietà' pos=7)

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.pdf') && this.disabled) find='TeraCopy*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='TeraCopy*' pos=8)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='WinRAR*' pos=9)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Usa come origine del collegamento*' pos=10 sep='after')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Altre opzioni*' pos=11)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Apri con*' pos=12)

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') title='Programmi' image=icon.manage pos=13)
{
}
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Kaspersky' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='SmartFTP*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Apri con Code' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Acronis True Image' parent='Programmi')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Change owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='View owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Take Ownership*' vis=hidden)

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') title='Sistema' image=icon.settings pos=14)
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

remove(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Condividi con Adobe Acrobat*')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Aggiungi a Preferiti*')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='New folder with selection')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.pdf') find='Sovrascrivi con BleachBit')
