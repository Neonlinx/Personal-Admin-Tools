// ============================================================================
// Nilesoft Shell - V13.1 DROPBOX BLOCK
//
// Risultato dei test V13:
// gli handler Dropbox possono essere riordinati, ma non accettano parent=.
// La soluzione stabile è raccoglierli in un unico blocco consecutivo.
//
// Il riconoscimento avviene tramite il titolo delle azioni Dropbox, non tramite
// sel.path. In questo modo vengono intercettati anche i collegamenti simbolici
// sul Desktop che puntano a file dentro Dropbox.
// ============================================================================


// ---------------------------------------------------------------------------
// FILE SINGOLO
// ---------------------------------------------------------------------------

modify(type='file' mode='single'
       find='Copia link Dropbox'
       pos=70 sep='before')

modify(type='file' mode='single'
       find='Condividi...'
       pos=71)

modify(type='file' mode='single'
       find='Informazioni sul file...'
       pos=72)

modify(type='file' mode='single'
       find='Rendi Solo online'
       pos=73)

modify(type='file' mode='single'
       find='Rendi solo online'
       pos=73)

modify(type='file' mode='single'
       find='Rendi disponibile offline'
       pos=74)

modify(type='file' mode='single'
       find='Visualizza su Dropbox.com'
       pos=75)

modify(type='file' mode='single'
       find='Cronologia delle versioni'
       pos=76)

modify(type='file' mode='single'
       find='Ottieni firme'
       pos=77)

modify(type='file' mode='single'
       find='Firma'
       pos=78)

modify(type='file' mode='single'
       find='Azioni con il pulsante destro...'
       pos=79 sep='after')


// ---------------------------------------------------------------------------
// CARTELLA SINGOLA
// ---------------------------------------------------------------------------

modify(type='dir' mode='single'
       find='Copia link Dropbox'
       pos=70 sep='before')

modify(type='dir' mode='single'
       find='Condividi...'
       pos=71)

modify(type='dir' mode='single'
       find='Informazioni sul file...'
       pos=72)

modify(type='dir' mode='single'
       find='Rendi Solo online'
       pos=73)

modify(type='dir' mode='single'
       find='Rendi solo online'
       pos=73)

modify(type='dir' mode='single'
       find='Rendi disponibile offline'
       pos=74)

modify(type='dir' mode='single'
       find='Visualizza su Dropbox.com'
       pos=75)

modify(type='dir' mode='single'
       find='Cronologia delle versioni'
       pos=76)

modify(type='dir' mode='single'
       find='Gestisci accesso alle cartelle'
       pos=77 sep='after')

modify(type='dir' mode='single'
       find='Azioni con il pulsante destro...'
       pos=78 sep='after')


// ---------------------------------------------------------------------------
// MULTISELEZIONE
// ---------------------------------------------------------------------------

modify(type='file|dir' mode='multiple'
       find='Copia link Dropbox'
       pos=70 sep='before')

modify(type='file|dir' mode='multiple'
       find='Condividi...'
       pos=71)

modify(type='file|dir' mode='multiple'
       find='Informazioni sul file...'
       pos=72)

modify(type='file|dir' mode='multiple'
       find='Rendi Solo online'
       pos=73)

modify(type='file|dir' mode='multiple'
       find='Rendi solo online'
       pos=73)

modify(type='file|dir' mode='multiple'
       find='Rendi disponibile offline'
       pos=74)

modify(type='file|dir' mode='multiple'
       find='Visualizza su Dropbox.com'
       pos=75)

modify(type='file|dir' mode='multiple'
       find='Cronologia delle versioni'
       pos=76)

modify(type='file|dir' mode='multiple'
       find='Gestisci accesso alle cartelle'
       pos=77)

modify(type='file|dir' mode='multiple'
       find='Azioni con il pulsante destro...'
       pos=78 sep='after')
