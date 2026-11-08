// V14.2 - diagnostica tipo oggetto corretta

menu(type='file' mode='single' title='[DIAGNOSTICA: FILE]' image=\uE9D9 pos=top sep='after')
{
    item(title='Mostra percorso selezionato' cmd=msg(sel.path))
    item(title='Mostra attributi' cmd=msg(sel.meta('System.FileAttributes')))
    item(title='Mostra nome' cmd=msg(sel.file.name))
    item(title='Mostra estensione' cmd=msg(sel.file.ext))
    item(title='Mostra cartella padre' cmd=msg(sel.parent))
}

menu(type='dir' mode='single' title='[DIAGNOSTICA: DIRECTORY]' image=\uE9D9 pos=top sep='after')
{
    item(title='Mostra percorso selezionato' cmd=msg(sel.path))
    item(title='Mostra attributi' cmd=msg(sel.meta('System.FileAttributes')))
    item(title='Mostra nome' cmd=msg(sel.file.name))
    item(title='Mostra estensione' cmd=msg(sel.file.ext))
    item(title='Mostra cartella padre' cmd=msg(sel.parent))
}

menu(type='namespace' mode='single' title='[DIAGNOSTICA: NAMESPACE]' image=\uE9D9 pos=top sep='after')
{
    item(title='Mostra percorso selezionato' cmd=msg(sel.path))
    item(title='Mostra attributi' cmd=msg(sel.meta('System.FileAttributes')))
    item(title='Mostra nome' cmd=msg(sel.file.name))
    item(title='Mostra estensione' cmd=msg(sel.file.ext))
    item(title='Mostra cartella padre' cmd=msg(sel.parent))
}

menu(type='unknown' mode='single' title='[DIAGNOSTICA: UNKNOWN]' image=\uE9D9 pos=top sep='after')
{
    item(title='Mostra percorso selezionato' cmd=msg(sel.path))
    item(title='Mostra attributi' cmd=msg(sel.meta('System.FileAttributes')))
    item(title='Mostra nome' cmd=msg(sel.file.name))
    item(title='Mostra estensione' cmd=msg(sel.file.ext))
    item(title='Mostra cartella padre' cmd=msg(sel.parent))
}
