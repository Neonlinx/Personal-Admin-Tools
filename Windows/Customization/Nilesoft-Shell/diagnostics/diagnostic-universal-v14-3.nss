// ============================================================================
// V14.3 - DIAGNOSTICA UNIVERSALE
//
// Nessuna proprietà type=.
// Nessuna modifica alle voci esistenti.
// ============================================================================

menu(mode='single'
     title='[DIAGNOSTICA UNIVERSALE]'
     image=\uE9D9
     pos=top
     sep='after')
{
    item(title='Mostra percorso selezionato'
         cmd=msg(sel.path))

    item(title='Mostra attributi'
         cmd=msg(sel.meta('System.FileAttributes')))

    item(title='Mostra nome'
         cmd=msg(sel.file.name))

    item(title='Mostra estensione'
         cmd=msg(sel.file.ext))

    item(title='Mostra cartella padre'
         cmd=msg(sel.parent))
}
