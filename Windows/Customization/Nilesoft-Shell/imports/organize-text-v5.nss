// ============================================================================
// Nilesoft Shell - V5 TEXT BASE
// Scope: SOLO .TXT / .LOG / .INI / .JSON / .CSV / .TSV
// ============================================================================

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Apri' pos=0)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Modifica' pos=1)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Modifica con Notepad++*' pos=2)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Modifica nel Blocco note*' pos=3 sep='after')

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Taglia' pos=4)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Copia' pos=5)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Elimina' pos=6)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Rinomina' pos=7)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Proprietà' pos=8)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Usa come origine del collegamento*' pos=9 sep='after')

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) title='Programmi' image=icon.manage)
{
}

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Kaspersky' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='SmartFTP*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Apri con Code' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Acronis True Image' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Combina file in Acrobat*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Converti a Adobe PDF*' parent='Programmi')

// TeraCopy resta al livello principale: nei test il reparent dentro Programmi
// rendeva l'ExplorerCommandHandler grigio/disabilitato. Nascondiamo solo
// eventuali istanze realmente disabled.
modify(type='file' where=((str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) && this.disabled) find='TeraCopy*' vis=hidden)

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Change owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='View owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Take Ownership*' vis=hidden)

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) title='Sistema' image=icon.settings)
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

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Apri con*' pos=bottom)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Altre opzioni*' pos=bottom)

remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Aggiungi a Preferiti*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='New folder with selection')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.txt') || str.equals(str.lower(sel.file.ext), '.log') || str.equals(str.lower(sel.file.ext), '.ini') || str.equals(str.lower(sel.file.ext), '.json') || str.equals(str.lower(sel.file.ext), '.csv') || str.equals(str.lower(sel.file.ext), '.tsv')) find='Sovrascrivi con BleachBit')
