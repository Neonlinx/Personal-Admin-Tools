// ============================================================================
// V14 - DIAGNOSTICA COLLEGAMENTI SIMBOLICI
//
// Non rimuove, non sposta e non modifica nessuna voce esistente.
// Aggiunge soltanto un sottomenu temporaneo "[DIAGNOSTICA LINK]" sui file
// selezionati singolarmente.
// ============================================================================

menu(type='file' mode='single'
     title='[DIAGNOSTICA LINK]'
     image=\uE9D9
     pos=top sep='after')
{
    item(title='A - Sempre visibile')

    item(
        where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
        title='B - REPARSE POINT rilevato'
    )

    item(
        where=@str.contains(str.lower(sel.path), '\desktop\')
        title='C - Percorso contiene DESKTOP'
    )

    item(
        where=@str.contains(str.lower(sel.path), '\dropbox\')
        title='D - Percorso contiene DROPBOX'
    )

    item(
        where=@(sel.file.ext == '.txt')
        title='E - Estensione TXT'
    )

    separator

    item(
        title='Mostra percorso selezionato'
        cmd=msg(sel.path)
    )

    item(
        title='Mostra attributi numerici'
        cmd=msg(sel.meta('System.FileAttributes'))
    )

    item(
        title='Mostra nome file'
        cmd=msg(sel.file.name)
    )

    item(
        title='Mostra cartella padre'
        cmd=msg(sel.parent)
    )
}
