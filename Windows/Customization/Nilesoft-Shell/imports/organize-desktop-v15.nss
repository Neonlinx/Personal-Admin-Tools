// ============================================================================
// Nilesoft Shell - V15.3 DESKTOP BACKGROUND
//
// Scope:
//   - clic destro sullo spazio vuoto del Desktop (type='desktop');
//   - le icone sul Desktop NON sono coinvolte (sono type='file'/'dir').
//
// Risultati dei test V15.1:
//   - le voci NUOVE senza pos= compaiono dopo WizTree, nell'ordine
//     in cui sono scritte in questo file;
//   - pos=bottom funziona per le voci nuove, NON sposta quelle native;
//   - pos=indexof(...) non ha effetto; i pos= numerici sono imprevedibili;
//   - le icone SVG icon.nome (da images.nss) funzionano, i glifi \uE... no;
//   - ATTENZIONE: il file deve avere UN SOLO BOM, altrimenti Nilesoft
//     scarta tutta la configurazione (errore "line[1] column[1]").
//
// Novità V15.2:
//   - sottomenu "Programmi" con WizFile, WizTree, MobaFind, MobaXterm.
//
// Novità V15.3:
//   - Mp3tag -> Programmi; Apri con Code -> Sviluppo; Apri nel Terminale -> Terminale.
//   - "Trasferisci copia..." (Dropbox) resta nativa: le voci Dropbox non accettano parent=.
//
// Note:
//   - Restart Explorer, Safe Mode, Appearance: voci di Winaero Tweaker (registro).
//   - I percorsi usano "/" invece di "\": Windows li accetta uguali.
// ============================================================================


// ---------------------------------------------------------------------------
// PERCORSO DELLO SCRIPT
//   FASE DI SVILUPPO : cartella del repository (attuale)
//   FASE 7           : sostituire con 'C:/Program Files/Software-Update-Checker/Software-Update-Checker.ps1'
// ---------------------------------------------------------------------------

$suc_script = 'C:/Users/Nirva/source/repos/Personal-Admin-Tools/Windows/Software-Updates/Software-Update-Checker.ps1'


// ---------------------------------------------------------------------------
// VOCI NATIVE: solo separatori, l'ordine di Windows va già bene
// ---------------------------------------------------------------------------

modify(type='desktop' find='Aggiorna' sep='after')
modify(type='desktop' find='Nuovo*' sep='both')


// ---------------------------------------------------------------------------
// PROGRAMMI
// ---------------------------------------------------------------------------

menu(type='desktop' title='Programmi' image=icon.manage sep='before')
{
}

modify(type='desktop' find='WizFile' parent='Programmi')
modify(type='desktop' find='WizTree' parent='Programmi')
modify(type='desktop' find='Find text using MobaFind' parent='Programmi')
modify(type='desktop' find='Open MobaXterm terminal here' parent='Programmi')
modify(type='desktop' find='Mp3tag' parent='Programmi')


// ---------------------------------------------------------------------------
// SVILUPPO
// ---------------------------------------------------------------------------

menu(type='desktop' title='Sviluppo' image=icon.code)
{
}

modify(type='desktop' find='Open with Visual Studio' parent='Sviluppo')
modify(type='desktop' find='Open Git GUI here' parent='Sviluppo')
modify(type='desktop' find='Open Git Bash here' parent='Sviluppo')
modify(type='desktop' find='Apri con Code' parent='Sviluppo')


// ---------------------------------------------------------------------------
// TERMINALE
// ---------------------------------------------------------------------------

menu(type='desktop' title='Terminale' image=icon.command_prompt)
{
}

modify(type='desktop' find='Prompt dei comandi (Administrator)' parent='Terminale')
modify(type='desktop' find='Windows PowerShell (Esegui come amministratore)' parent='Terminale')
modify(type='desktop' find='Apri nel Terminale' parent='Terminale')


// ---------------------------------------------------------------------------
// SOFTWARE UPDATE CHECKER
//   Compare solo se lo script esiste davvero nel percorso indicato sopra.
// ---------------------------------------------------------------------------

menu(type='desktop' where=path.exists(suc_script)
     title='Software Update Checker' image=icon.install sep='after')
{
    item(title='Esegui controllo completo'
         image=icon.run_as_administrator
         admin
         cmd='powershell.exe'
         args='-NoProfile -NoExit -File "@suc_script" -Forza -Dettagli')

    // Finestra in sola consultazione (attivata con la fase 5a)
    item(title='Situazione attuale (Info)'
         image=icon.details
         cmd='powershell.exe'
         args='-NoProfile -WindowStyle Hidden -File "@suc_script" -Info')

    separator

    item(title='Apri report del mese'
         image=icon.edit
         cmd='powershell.exe'
         args='-NoProfile -WindowStyle Hidden -File "@suc_script" -ApriReport')

    item(title='Apri cartella report'
         image=icon.open_folder
         cmd='powershell.exe'
         args='-NoProfile -WindowStyle Hidden -File "@suc_script" -ApriCartella')
}
