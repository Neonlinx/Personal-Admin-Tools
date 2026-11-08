// ============================================================================
// V14.1 - DIAGNOSTICA TIPO OGGETTO
//
// Nessun type sul menu principale: deve comparire su qualsiasi oggetto
// selezionato, esclusi i contesti senza selezione.
// ============================================================================

menu(mode='single'
     title='[DIAGNOSTICA TIPO OGGETTO]'
     image=\uE9D9
     pos=top sep='after')
{
    item(title='A - Menu universale attivo')

    separator

    item(type='file'
         title='TIPO = FILE')

    item(type='dir'
         title='TIPO = DIRECTORY')

    item(type='namespace'
         title='TIPO = NAMESPACE')

    item(type='unknown'
         title='TIPO = UNKNOWN')

    item(type='drive'
         title='TIPO = DRIVE')

    item(type='desktop'
         title='TIPO = DESKTOP')

    separator

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
