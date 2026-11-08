// ============================================================================
// Nilesoft Shell - V12.3 FOLDER BACKGROUND
//
// Scope:
//   - clic destro sullo spazio vuoto di cartelle normali in Esplora file;
//   - Desktop escluso;
//   - percorsi Dropbox esclusi.
//
// Obiettivo:
//   raggruppare sviluppo e terminali senza alterare le funzioni native.
//
// Novità V12.1:
//   - sottomenu "Programmi" con WizFile, WizTree, MobaFind, MobaXterm;
//   - icone SVG (icon.nome) al posto dei glifi \uE..., che non venivano disegnati.
//
// Novità V12.2:
//   - tolti i pos= numerici da Programmi, Sviluppo e Terminale (come sul desktop:
//     senza pos le voci nuove si mettono nell'ordine in cui sono scritte).
//
// Novità V12.3:
//   - Mp3tag -> Programmi; Apri con Code -> Sviluppo; Apri nel Terminale -> Terminale.
//   - "Trasferisci copia..." (Dropbox) resta nativa: le voci Dropbox non accettano parent=.
// ============================================================================


// ---------------------------------------------------------------------------
// BLOCCO NATIVO SUPERIORE
// ---------------------------------------------------------------------------

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Visualizza*' pos=0)

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Ordina per*' pos=1)

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Raggruppa per*' pos=2)

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Aggiorna' pos=3 sep='after')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Incolla' pos=4)

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Incolla collegamento' pos=5)

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Annulla*' pos=6 sep='after')


// ---------------------------------------------------------------------------
// NUOVO
// ---------------------------------------------------------------------------

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Nuovo*' pos=7 sep='after')


// ---------------------------------------------------------------------------
// PROGRAMMI
// ---------------------------------------------------------------------------

menu(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
     title='Programmi' image=icon.manage sep='before')
{
}

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='WizFile'
       parent='Programmi')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='WizTree'
       parent='Programmi')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Find text using MobaFind'
       parent='Programmi')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Open MobaXterm terminal here'
       parent='Programmi')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Mp3tag'
       parent='Programmi')


// ---------------------------------------------------------------------------
// SVILUPPO
// ---------------------------------------------------------------------------

menu(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
     title='Sviluppo' image=icon.code)
{
}

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Open with Visual Studio'
       parent='Sviluppo')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Open Git GUI here'
       parent='Sviluppo')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Open Git Bash here'
       parent='Sviluppo')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Apri con Code'
       parent='Sviluppo')


// ---------------------------------------------------------------------------
// TERMINALE
// ---------------------------------------------------------------------------

menu(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
     title='Terminale' image=icon.command_prompt sep='after')
{
}

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Prompt dei comandi (Administrator)'
       parent='Terminale')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Windows PowerShell (Esegui come amministratore)'
       parent='Terminale')

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Apri nel Terminale'
       parent='Terminale')


// ---------------------------------------------------------------------------
// CHIUSURA
// ---------------------------------------------------------------------------

modify(type='back.directory' mode='none' where=(
    !window.is_desktop
    && !str.contains(str.lower(sel.path), '\\dropbox')
)
       find='Proprietà' pos=bottom)
