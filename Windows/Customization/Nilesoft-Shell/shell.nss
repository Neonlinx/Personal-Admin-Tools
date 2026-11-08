settings
{
	priority=1
	exclude.where = !process.is_explorer
	showdelay = 200
	// Options to allow modification of system items
	modify.remove.duplicate=1
	tip.enabled=true
}

import 'imports/theme.nss'
import 'imports/images.nss'

import 'imports/modify.nss'

menu(mode="multiple" title="Pin/Unpin" image=icon.pin)
{
}

menu(mode="multiple" title=title.more_options image=icon.more_options)
{
}

import 'imports/develop.nss'
import 'imports/taskbar.nss'

// Menu contestuale personalizzato - V3 BASE DIRECTORY
import 'imports/organize-directory-v3.nss'

// Menu contestuale archivi ZIP/RAR/7Z - V4 BASE
import 'imports/organize-archive-v4.nss'

// Menu contestuale file testo/config - V5 BASE
import 'imports/organize-text-v5.nss'

// Menu contestuale AUDIO - V6 BASE
import 'imports/organize-audio-v6.nss'

// Menu contestuale VIDEO - V7 BASE
import 'imports/organize-video-v7.nss'

// Menu contestuale IMMAGINI - V8 BASE
import 'imports/organize-images-v8.nss'

// Menu contestuale PDF - V9 BASE
import 'imports/organize-pdf-v9.nss'

// Menu contestuale ESEGUIBILI E SCRIPT - V10
import 'imports/organize-executables-v10.nss'

// File generici e multiselezione - V11
import 'imports/organize-generic-multi-v11.nss'

// Sfondo cartelle normali - V12
import 'imports/organize-background-v12.nss'

// Menu contestuale Dropbox - V13 BASE
import 'imports/organize-dropbox-v13.nss'

// Sfondo DESKTOP - V15
import 'imports/organize-desktop-v15.nss'

// Documenti OFFICE - V16
import 'imports/organize-office-v16.nss'

// Oggetti virtuali (Questo PC, Rete, Cestino) - V17
import 'imports/organize-namespace-v17.nss'

