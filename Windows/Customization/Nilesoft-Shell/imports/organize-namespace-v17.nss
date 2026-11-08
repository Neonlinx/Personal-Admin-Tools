// ============================================================================
// Nilesoft Shell - V17 NAMESPACE (Questo PC, Rete, Cestino)
//
// Scope:
//   - icone "virtuali" del desktop e di Esplora risorse: Questo PC, Rete,
//     Cestino (oggetti di tipo 'namespace', non sono file né cartelle vere).
//
// Obiettivo:
//   - togliere WizTree, che lì non ha senso.
//
// Note:
//   - type='namespace' è un valore accettato da Nilesoft (verificato con la
//     diagnostica V14.6). Se questi oggetti non fossero 'namespace', la regola
//     semplicemente non si applica: nessun errore.
//   - File salvato con UN SOLO BOM.
// ============================================================================

remove(type='namespace' find='WizTree')
