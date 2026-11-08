// ============================================================================
// Nilesoft Shell - V14 SYMBOLIC LINKS TEST
//
// Target:
//   elementi con attributo FILE_ATTRIBUTE_REPARSE_POINT (1024).
//
// Questa è una versione di prova: il filtro usa System.FileAttributes letto
// tramite sel.meta(). L'obiettivo è intercettare i link simbolici NTFS senza
// modificare i normali file presenti sul Desktop.
// ============================================================================


// ---------------------------------------------------------------------------
// PULIZIA DELLE VOCI INDESIDERATE
// ---------------------------------------------------------------------------

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Aggiungi a Preferiti*')

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Sovrascrivi con BleachBit')

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='New folder with selection')

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Converti a Adobe PDF')

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Combina file in Acrobat*')

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Stampa')


// ---------------------------------------------------------------------------
// OWNER: NASCONDI LE VOCI SPARSE
// ---------------------------------------------------------------------------

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Change owner*')

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Take Ownership*')

remove(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='View owner*')


// ---------------------------------------------------------------------------
// COMANDI UTILI DEL LINK
// ---------------------------------------------------------------------------

modify(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Apri percorso file'
       pos=20 sep='before')

modify(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Copia come percorso'
       pos=21)

modify(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Crea collegamento'
       pos=22)


// ---------------------------------------------------------------------------
// PROPRIETÀ
//
// Alcuni reparse point espongono due handler con lo stesso titolo.
// Il modify tenta di portarli entrambi in fondo; il test ci dirà se Nilesoft
// li accorpa visivamente oppure se servirà identificare uno dei due per ID.
// ---------------------------------------------------------------------------

modify(type='file|dir' mode='single' where=@((sel.meta('System.FileAttributes') & 1024) == 1024)
       find='Proprietà'
       pos=bottom sep='before')
