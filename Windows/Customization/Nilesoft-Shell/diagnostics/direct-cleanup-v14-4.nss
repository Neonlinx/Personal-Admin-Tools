// ============================================================================
// V14.4 - DIRECT CLEANUP
//
// Nessun filtro per tipo o attributo.
// Rimuove soltanto voci già considerate indesiderate globalmente.
// ============================================================================

remove(mode='single' find='Aggiungi a Preferiti*')
remove(mode='single' find='Sovrascrivi con BleachBit')
remove(mode='single' find='New folder with selection')
remove(mode='single' find='Converti a Adobe PDF')
remove(mode='single' find='Combina file in Acrobat*')
remove(mode='single' find='Stampa')

remove(mode='single' find='Change owner*')
remove(mode='single' find='Take Ownership*')
remove(mode='single' find='View owner*')

// Comandi utili sui link: li portiamo in una zona più ordinata.
modify(mode='single' find='Apri percorso file' pos=40 sep='before')
modify(mode='single' find='Copia come percorso' pos=41)
modify(mode='single' find='Crea collegamento' pos=42)

// Proprietà: per ora tentiamo solo il posizionamento in fondo.
modify(mode='single' find='Proprietà' pos=bottom sep='before')
