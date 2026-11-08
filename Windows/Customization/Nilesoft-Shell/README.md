# Nilesoft-Shell

Configurazione personale di [Nilesoft Shell](https://nilesoft.org) per il menu contestuale di Windows 11.

Parte di `Personal-Admin-Tools/Windows/Customization/`.

## Struttura

| Percorso | Contenuto |
|---|---|
| `shell.nss` | File principale: impostazioni e `import` di tutti i file |
| `imports/` | Un file per ogni contesto del menu (vedi tabella versioni) + file di serie di Nilesoft |
| `diagnostics/` | File di diagnostica usati durante i test. **Non** vengono installati |
| `Deploy-NilesoftConfig.ps1` | Verifica la configurazione e la installa in `C:\Program Files\Nilesoft Shell` |
| `_backup/` | Backup automatici creati dallo script (esclusi da git tramite il `.gitignore` di questa cartella) |

## Come si lavora

1. Modifica i file **qui nel repository** (non in Program Files).
2. Controlla senza installare:
   ```powershell
   .\Deploy-NilesoftConfig.ps1 -SoloVerifica
   ```
3. Installa (PowerShell **come amministratore**):
   ```powershell
   .\Deploy-NilesoftConfig.ps1
   ```
4. Se qualcosa non va, torna alla versione precedente:
   ```powershell
   .\Deploy-NilesoftConfig.ps1 -Ripristina
   ```
5. Se il risultato è buono: **commit + push**.

## Regole d'oro (scoperte sul campo)

1. **Un solo BOM** all'inizio di ogni file. Con un BOM doppio Nilesoft scarta **tutta** la configurazione (errore `line[1] column[1]` nel log).
2. Un errore in **un** file fa scartare **tutta** la configurazione. Sintomi: voci doppie e icone sparite. Primo controllo: `shell.log`.
3. Prima si copiano i file in `imports/`, **poi** si salva `shell.nss`: Nilesoft ricarica appena `shell.nss` cambia (lo script lo fa da solo).
4. **Niente `pos=` numerici** nei menu degli sfondi: sono imprevedibili. Le voci nuove senza `pos` si dispongono nell'ordine in cui sono scritte.
5. `pos=bottom` funziona sulle voci **nuove**; sulle voci native solo in alcuni casi.
6. Icone: usare le SVG di `images.nss` (`icon.nome`). I glifi Segoe (`\uE7..`-`\uE9..`) non vengono disegnati; quelli del font di Nilesoft (`\uE0..`-`\uE2..`) sì.
7. `type='unknown'` **non esiste**: blocca tutta la configurazione.
8. Sui **link simbolici di file** Nilesoft non applica nessuna regola personalizzata (test V14.5-V14.7, novembre 2026).
9. I `.nss` dentro `imports/` importano altri file con percorso relativo alla propria cartella (`import 'terminal.nss'`).

## Versioni dei file

| File | Contesto |
|---|---|
| `organize-directory-v3.nss` | Cartelle |
| `organize-archive-v4.nss` | Archivi (zip, rar, 7z…) |
| `organize-text-v5.nss` | File di testo e configurazione |
| `organize-audio-v6.nss` | Audio |
| `organize-video-v7.nss` | Video |
| `organize-images-v8.nss` | Immagini |
| `organize-pdf-v9.nss` | PDF |
| `organize-executables-v10.nss` | Eseguibili e script |
| `organize-generic-multi-v11.nss` | File generici e selezione multipla |
| `organize-background-v12.nss` | Sfondo delle cartelle |
| `organize-dropbox-v13.nss` | Voci di Dropbox |
| `organize-symlink-v14.nss` | Link simbolici (sperimentale, **non importato**: vedi regola 8) |
| `organize-desktop-v15.nss` | Sfondo del desktop (con Software Update Checker) |
| `organize-office-v16.nss` | Documenti Office e OpenDocument |
| `organize-namespace-v17.nss` | Questo PC, Rete, Cestino |
