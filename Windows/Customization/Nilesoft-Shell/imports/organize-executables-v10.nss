// ============================================================================
// Nilesoft Shell - V10 EXECUTABLES & SCRIPTS
//
// Famiglie:
//   EXE
//   MSI
//   DLL
//   BAT / CMD
// ============================================================================


// ============================================================================
// EXE
// ============================================================================

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Apri' pos=0)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Esegui come amministratore' pos=1)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Monitorizza con Total Uninstall' pos=2 sep='after')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Taglia' pos=3)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Copia' pos=4)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Elimina' pos=5)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Rinomina' pos=6)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Proprietà' pos=7)

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.exe') && this.disabled) find='TeraCopy*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='TeraCopy*' pos=8)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='WinRAR*' pos=9)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Usa come origine del collegamento*' pos=10 sep='after')

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') title='Programmi' image=icon.manage)
{
}
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Kaspersky' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='SmartFTP*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Apri con Code' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Acronis True Image' parent='Programmi')

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') title='Explorer' image=icon.file_explorer)
{
}
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Aggiungi alla barra delle applicazioni' parent='Explorer')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Aggiungi al menu Start' parent='Explorer')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Change owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='View owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Take Ownership*' vis=hidden)

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') title='Sistema' image=icon.settings)
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

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Altre opzioni*' pos=bottom)
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Aggiungi a Preferiti*')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='New folder with selection')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.exe') find='Sovrascrivi con BleachBit')


// ============================================================================
// MSI
// ============================================================================

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Installa' pos=0)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Ripristina' pos=1)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Disinstalla' pos=2)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Monitorizza con Total Uninstall' pos=3 sep='after')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Taglia' pos=4)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Copia' pos=5)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Elimina' pos=6)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Rinomina' pos=7)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Proprietà' pos=8)

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.msi') && this.disabled) find='TeraCopy*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='TeraCopy*' pos=9)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='WinRAR*' pos=10)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Usa come origine del collegamento*' pos=11 sep='after')

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') title='Programmi' image=icon.manage)
{
}
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Kaspersky' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='SmartFTP*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Apri con Code' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Acronis True Image' parent='Programmi')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Change owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='View owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Take Ownership*' vis=hidden)

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') title='Sistema' image=icon.settings)
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

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Apri con*' pos=bottom)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Altre opzioni*' pos=bottom)
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Aggiungi a Preferiti*')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='New folder with selection')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.msi') find='Sovrascrivi con BleachBit')


// ============================================================================
// DLL
// ============================================================================

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Taglia' pos=0)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Copia' pos=1)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Elimina' pos=2)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Rinomina' pos=3)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Proprietà' pos=4)

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.dll') && this.disabled) find='TeraCopy*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='TeraCopy*' pos=5)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='WinRAR*' pos=6)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Usa come origine del collegamento*' pos=7 sep='after')

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') title='Programmi' image=icon.manage)
{
}
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Kaspersky' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='SmartFTP*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Apri con Code' parent='Programmi')
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Acronis True Image' parent='Programmi')

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Change owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='View owner*' vis=hidden)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Take Ownership*' vis=hidden)

menu(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') title='Sistema' image=icon.settings)
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

modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Apri con*' pos=bottom)
modify(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Altre opzioni*' pos=bottom)
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Aggiungi a Preferiti*')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='New folder with selection')
remove(type='file' where=str.equals(str.lower(sel.file.ext), '.dll') find='Sovrascrivi con BleachBit')


// ============================================================================
// BAT / CMD
// ============================================================================

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Apri' pos=0)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Modifica' pos=1)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Esegui come amministratore' pos=2 sep='after')

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Taglia' pos=3)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Copia' pos=4)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Elimina' pos=5)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Rinomina' pos=6)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Proprietà' pos=7)

modify(type='file' where=((str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) && this.disabled) find='TeraCopy*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='TeraCopy*' pos=8)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='WinRAR*' pos=9)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Usa come origine del collegamento*' pos=10 sep='after')

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) title='Programmi' image=icon.manage)
{
}
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Trasferisci copia*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Sposta in Dropbox*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Modifica con Notepad++*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Kaspersky' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='SmartFTP*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Modifica nel Blocco note*' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Apri con Code' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Monitorizza con Total Uninstall' parent='Programmi')
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Acronis True Image' parent='Programmi')

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Change owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='View owner*' vis=hidden)
modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Take Ownership*' vis=hidden)

menu(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) title='Sistema' image=icon.settings)
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

modify(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Altre opzioni*' pos=bottom)
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Converti a Adobe PDF*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Crea e condividi Adobe PDF*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Aggiungi a Preferiti*')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='New folder with selection')
remove(type='file' where=(str.equals(str.lower(sel.file.ext), '.bat') || str.equals(str.lower(sel.file.ext), '.cmd')) find='Sovrascrivi con BleachBit')
