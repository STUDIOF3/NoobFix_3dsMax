/*
    NoobFix v2.3.0
    
    Funcionalidades Adicionadas:
    1. Visual Feedback: Duplo clique na lista seleciona os objetos 3D.
    2. Suporte Total: Redshift, FStorm, Arnold, Corona, VRay, OSL.
    3. Auto-Search: Define automaticamente a pasta do projeto ao abrir.
    4. Collect Files: Botao para copiar texturas relinkadas para pasta local.
    5. UNC Fix: Botao para converter caminhos de drive para rede.
    
    Interface: Mantida Classica (v1.6/v2.2) com ajustes minimos de altura.
*/
try( destroyDialog rlt_NoobFix ) catch()
global NoobFixINI = ( getDir #userScripts )+ "\\NoobFix_Config.ini"
global noobScale = try( GetUIScaleFactor() ) catch( 1.0 )
fn s val = ( val * noobScale )
fn p x y = [x * noobScale, y * noobScale]
fn noobLog msg = ( format "[NoobFix]: %\n" msg )
-- Altura ajustada levemente para caber os 2 novos botoes necessarios
rollout rlt_NoobFix "NoobFix v2.3 (Ultimate)" width:( s 400 ) height:( s 760 )

(	
	-- --- AREA 1: BIBLIOTECA ---
	groupBox grp_source "1. Biblioteca" pos:( p 10 10 ) width:( s 380 ) height:( s 70 )
	edittext edt_currentPath "" pos:( p 20 30 ) width:( s 300 ) readOnly: true
	dotNetControl btn_browse "System.Windows.Forms.Button" pos:( p 330 29 ) width:( s 50 ) height:( s 22 )
	label lbl_status "Selecione a pasta raiz" pos:( p 20 55 ) style_sunkenedge: false
	-- --- AREA 2: FAVORITOS ---
	groupBox grp_favs "2. Favoritos" pos:( p 10 90 ) width:( s 380 ) height:( s 140 )
	listbox lbx_favorites "" pos:( p 20 110 ) width:( s 300 ) height: 7
	dotNetControl btn_addFav "System.Windows.Forms.Button" pos:( p 330 110 ) width:( s 50 ) height:( s 30 )
	dotNetControl btn_delFav "System.Windows.Forms.Button" pos:( p 330 145 ) width:( s 50 ) height:( s 30 )
	-- --- AREA 3: DIAGNOSTICO ---
	-- Altura aumentada para comportar UNC e Strip
	groupBox grp_missing "3. Diagnostico" pos:( p 10 240 ) width:( s 380 ) height:( s 270 )
	dotNetControl btn_scan "System.Windows.Forms.Button" pos:( p 20 260 ) width:( s 360 ) height:( s 30 )
	listbox lbx_missing "" pos:( p 20 295 ) width:( s 360 ) height: 8
	-- Legenda de ajuda para o Duplo Clique
	label lbl_help "(Duplo clique na lista para selecionar objetos)" pos:( p 20 415 ) style_sunkenedge: false enabled: false
	edittext edt_selectedMissing "" pos:( p 18 435 ) width:( s 360 ) readOnly: true text: "..." border: false
	-- Botoes de Ferramentas (Strip e UNC)
	dotNetControl btn_strip "System.Windows.Forms.Button" pos:( p 20 460 ) width:( s 250 ) height:( s 30 )
	dotNetControl btn_unc "System.Windows.Forms.Button" pos:( p 280 460 ) width:( s 100 ) height:( s 30 )
	-- --- AREA 4: ACAO ---
	groupBox grp_action "4. Executar" pos:( p 10 520 ) width:( s 380 ) height:( s 190 )
	checkbox chk_ext "Ignorar Extensao" pos:( p 20 540 ) checked: true
	checkbox chk_sub "Incluir Subpastas" pos:( p 200 540 ) checked: true
	label lbl_info_files "Aguardando..." pos:( p 20 565 ) width:( s 350 ) height:( s 20 )
	progressbar pb_status "" pos:( p 20 585 ) width:( s 360 ) height:( s 10 ) color:( color 100 180 110 ) value: 0
	-- Botoes de Acao (Relink e Collect)
	dotNetControl btn_relink "System.Windows.Forms.Button" pos:( p 20 605 ) width:( s 360 ) height:( s 45 )
	dotNetControl btn_collect "System.Windows.Forms.Button" pos:( p 20 655 ) width:( s 360 ) height:( s 30 )
	-- --- AREA 5: RODAPÉ ---
	label lbl_dev "Desenvolvido por NoobDev v2.3" pos:( p 20 720 )
	hyperLink hl_git "GitHub" address: "https://github.com/STUDIOF3/NoobFix_3dsMax" pos:( p 340 720 ) color:( color 230 140 80 )
	-- Variaveis Locais
	local searchPath = ""
	local foundLibraryFiles = #()
	local missingAssetsList = #()
	-- --- ESTILOS ---
	local col_OrangeSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 230 140 80
	local col_GreenSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 100 180 110
	local col_RedSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 200 80 80
	local col_BlueSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 80 140 200
	local col_DarkGray = ( dotNetClass "System.Drawing.Color" ).fromArgb 60 60 60
	local col_Text = ( dotNetClass "System.Drawing.Color" ).fromArgb 220 220 220
	fn styleButton btn text backColor fontSize: 9 = 
	(		
		btn.Flatstyle = ( dotNetClass "System.Windows.Forms.Flatstyle" ).Flat
		btn.FlatAppearance.BorderSize = 0
		btn.Text = text
		btn.BackColor = backColor
		btn.ForeColor = col_Text
		local scaledFont = fontSize * noobScale
		btn.Font = dotNetObject "System.Drawing.Font" "Segoe UI" scaledFont( dotNetClass "System.Drawing.FontStyle" ).Bold
		btn.Cursor = ( dotNetClass "System.Windows.Forms.Cursors" ).Hand
	)
	-- --- UTILITARIOS ---
	fn cleanPath p = 
	(		
		if p == undefined or p == "" then
			return ""
		local clean = p
		if( substring clean clean.count 1 )== "\\" do
			clean = substring clean 1( clean.count - 1 )
		return clean
	)
	fn saveFavoritesToINI = 
	(		
		if( doesFileExist NoobFixINI ) do
			delIniSetting NoobFixINI "Favoritos"
		for i = 1 to lbx_favorites.items.count do
			setINISetting NoobFixINI "Favoritos"( "Path_" +( i as string ) ) lbx_favorites.items[i]
	)
	fn loadFavoritesFromINI = 
	(		
		if( doesFileExist NoobFixINI ) then
		(			
			local keys = getINISetting NoobFixINI "Favoritos"
			local paths = #()
			sort keys
			for k in keys do
				append paths( getINISetting NoobFixINI "Favoritos" k )
			lbx_favorites.items = paths
		)
	)
	fn getFilesSafe dir recursive list = 
	(		
		try
		(			
			local dirInfo = dotNetObject "System.IO.DirectoryInfo" dir
			if not dirInfo.Exists then
				return undefined
			local files = dirInfo.GetFiles "*.*"( dotNetClass "System.IO.SearchOption" ).TopDirectoryOnly
			for f in files do
				append list f
			if recursive then
			(				
				local subDirs = dirInfo.GetDirectories()
				for d in subDirs do
					getFilesSafe d.FullName true list
			)
		)
		catch()
	)
	-- Definição Global de Tipos Suportados (Para Strip, Select, etc)
	fn getSupportedMapClasses = 
	(		
		-- Formato: #(Classe, #PropriedadeCaminho)
		local types = #(			
			#( BitmapTexture, #filename ),
			#( VRayBitmap, #HDRIMapName ), #( VRayBitmap, #filename ),
			#( CoronaBitmap, #filename ),
			#( ai_Image, #filename ),
			#( OSLMap, #filename ),
			#( PhysicalMaterial, #base_color_map )
		)
		-- Adiciona Redshift/FStorm se existirem (seguranca)
		if( Redshift_Bitmap != undefined ) do
			append types #( Redshift_Bitmap, #filename )
		if( FStormBitmap != undefined ) do
			append types #( FStormBitmap, #filename )
		if( FStormTexture != undefined ) do
			append types #( FStormTexture, #filename )
		return types
	)
	-- --- FUNCIONALIDADE 1: VISUAL FEEDBACK (SELECT OBJECTS) ---
	fn selectObjectsFromMissing pathString = 
	(		
		if pathString == undefined or pathString == "" do
			return false
		noobLog( "Procurando objetos usando: " + pathString )
		local foundMats = #()
		local types = getSupportedMapClasses()
		-- 1. Encontrar o material/mapa que usa este caminho
		for t in types do
		(			
			try
			(				
				local instances = getClassInstances t[1]
				for m in instances do
				(					
					if isProperty m t[2] do
					(						
						local val = getProperty m t[2]
						if val == pathString do
							appendIfUnique foundMats m
					)
				)
			)
			catch()
		)
		if foundMats.count == 0 do
		(			
			messageBox "Nao foi possivel encontrar o material na cena.\n(Pode estar dentro de um XRef ou Container bloqueado)."
			return false
		)
		-- 2. Encontrar objetos dependentes
		local finalObjs = #()
		for m in foundMats do
		(			
			-- refs.dependents procura quem usa este mapa
			local deps = refs.dependents m
			for d in deps do
			(				
				if isValidNode d and not isDeleted d do
					appendIfUnique finalObjs d
			)
		)
		if finalObjs.count > 0 then
		(			
			clearSelection()
			select finalObjs
			messageBox( "Selecionados " + finalObjs.count as string + " objetos na viewport." ) title: "Visual Feedback"
			redrawViews()
		)
		else
		(			
			messageBox "Mapa encontrado, mas nao parece estar aplicado a nenhum objeto 3D direto.\n(Pode estar no Environment ou Slot nao usado)." title: "Info"
		)
	)
	-- --- FUNCIONALIDADE 5: CONVERTER UNC ---
	fn convertToUNC = 
	(		
		local count = 0
		local types = getSupportedMapClasses()
		undo "Convert UNC" on 
		(			
			for t in types do
			(				
				try
				(					
					local instances = getClassInstances t[1]
					for m in instances do
					(						
						if isProperty m t[2] do
						(							
							local val = getProperty m t[2]
							if val != undefined and val != "" and( val[2] == ":" ) do
							(								
								-- Eh um caminho de drive (ex: Z:\), tenta converter
								local unc = pathConfig.convertPathToUnc val
								if unc != undefined and unc != val do
								(									
									setProperty m t[2] unc
									count += 1
								)
							)
						)
					)
				)
				catch()
			)
		)
		if count > 0 then
		(			
			messageBox( "Convertidos " + count as string + " caminhos para UNC (Rede)." ) title: "Sucesso"
			scanMissingFiles()
		)
		else
		(			
			messageBox "Nenhum caminho local (Drive Letter) encontrado para converter." title: "UNC"
		)
	)
	-- --- FUNCIONALIDADE 4: COLLECT FILES ---
	fn collectFiles = 
	(		
		local saveDir = maxfilepath + "Maps\\"
		if maxfilepath == "" do
		(			
			messageBox "Salve a cena primeiro!"
			return false
		)
		if not( makeDir saveDir ) do
		(			
			messageBox "Erro ao criar pasta Maps."
			return false
		)
		if queryBox( "Isso vai COPIAR todas as texturas encontradas para:\n" + saveDir + "\n\nE atualizar os caminhos na cena.\nContinuar?" )== false do
			return false
		local count = 0
		local types = getSupportedMapClasses()
		undo "Collect Files" on 
		(			
			for t in types do
			(				
				try
				(					
					local instances = getClassInstances t[1]
					for m in instances do
					(						
						if isProperty m t[2] do
						(							
							local originalPath = getProperty m t[2]
							-- So copia se o arquivo existe
							if originalPath != undefined and originalPath != "" and( doesFileExist originalPath ) do
							(								
								local fName = filenameFromPath originalPath
								local newPath = saveDir + fName
								-- Copia o arquivo
								if( copyFile originalPath newPath ) or( doesFileExist newPath ) do
								(									
									-- Atualiza o caminho no max
									setProperty m t[2] newPath
									count += 1
								)
							)
						)
					)
				)
				catch()
			)
		)
		messageBox( "Coletados " + count as string + " arquivos para a pasta do projeto." ) title: "Collect Concluido"
	)
	-- --- BACKEND v2.1 (Status Check) ---
	fn getMissingViaStatus = 
	(		
		noobLog "Scan: Checando Status ATSOps..."
		try
		(
			ATSOps.Visible = true
			ATSOps.Visible = false
		)
		catch()
		ATSOps.Refresh()
		local allAssets = #()
		ATSOps.GetFiles &allAssets
		local mList = #()
		for f in allAssets do
		(			
			if f != undefined and f != "" do
			(				
				local fname = filenameFromPath f
				if fname != "" and fname != undefined do
				(					
					local statusArray = ATSOps.GetFileSystemStatus f
					local isMissing = false
					if statusArray != undefined do
					(
						for s in statusArray do
							if s == #missing do
							isMissing = true
					)
					if not isMissing and not( doesFileExist f ) do
						isMissing = true
					if isMissing do
						appendIfUnique mList f
				)
			)
		)
		return mList
	)
	fn scanMissingFiles = 
	(		
		missingAssetsList = getMissingViaStatus()
		sort missingAssetsList
		lbx_missing.items = missingAssetsList
		if missingAssetsList.count == 0 then
		(			
			lbx_missing.items = #( "-- CENA LIMPA --" )
			edt_selectedMissing.text = ""
			btn_strip.Enabled = false
			btn_strip.BackColor = col_DarkGray
		)
		else
		(			
			btn_strip.Enabled = true
			btn_strip.BackColor = col_RedSoft
			edt_selectedMissing.text = "Encontrados: " +( missingAssetsList.count as string )
		)
	)
	fn stripMissingPaths = 
	(		
		if missingAssetsList.count == 0 do
			return false
		local count = 0
		local searchTypes = getSupportedMapClasses()
		undo "Strip Paths NoobFix" on 
		(			
			for type in searchTypes do
			(				
				try
				(					
					local maps = getClassInstances type[1]
					for m in maps do
					(						
						if isProperty m type[2] do
						(							
							local val = getProperty m type[2]
							local fname = if val != undefined then
								val
							else
								""
							-- Dupla checagem de seguranca
							if( findItem missingAssetsList fname )> 0 and( not doesFileExist fname ) do
							(								
								setProperty m type[2] ""
								count += 1
							)
						)
					)
				)
				catch()
			)
		)
		scanMissingFiles()
		messageBox( "Caminhos removidos: " + count as string ) title: "Strip Result"
	)
	fn runRelink = 
	(		
		searchPath = cleanPath searchPath
		pb_status.value = 0
		if searchPath == "" or not( doesDirectoryExist searchPath ) do
		(			
			messageBox "Selecione uma pasta valida."
			return false
		)
		lbl_info_files.text = "Lendo disco..."
		windows.processPostedMessages()
		-- 1. Indexar
		local fileDict = dotNetObject "System.Collections.Hashtable"
		foundLibraryFiles = #()
		getFilesSafe searchPath chk_sub.checked foundLibraryFiles
		pb_status.value = 30
		if foundLibraryFiles.count == 0 then
		(			
			messageBox "Pasta de busca vazia!"
			return false
		)
		lbl_info_files.text = "Indexando..."
		windows.processPostedMessages()
		local totalFiles = foundLibraryFiles.count
		for i = 1 to totalFiles do
		(			
			local f = foundLibraryFiles[i]
			local key = toLower( getFilenameFile f.Name )
			if not( fileDict.ContainsKey key ) do
				fileDict.Add key f.FullName
			if( mod i 200 )== 0 do
				pb_status.value = 30.0 +( ( i as float / totalFiles )* 20.0 )
		)
		pb_status.value = 50
		-- 2. Relink via ATSOps
		lbl_info_files.text = "Relinkando..."
		scanMissingFiles()
		if missingAssetsList.count == 0 do
		(			
			messageBox "Nada faltando!"
			return true
		)
		local relinkCount = 0
		try( ATSOps.Visible = true ) catch()
		ATSOps.ClearSelection()
		for i = 1 to missingAssetsList.count do
		(			
			local missingPath = missingAssetsList[i]
			local missingName = filenameFromPath missingPath
			local searchKey = toLower( getFilenameFile missingName )
			if( fileDict.ContainsKey searchKey ) do
			(				
				local newPath = fileDict.Item[searchKey]
				local validMatch = true
				if not chk_ext.checked do
				(					
					if( toLower( getFilenameType missingPath ) )!=( toLower( getFilenameType newPath ) ) do
						validMatch = false
				)
				if validMatch do
				(					
					ATSOps.ClearSelection()
					ATSOps.SelectFiles #( missingPath )
					ATSOps.RetargetSelection newPath
					relinkCount += 1
				)
			)
			pb_status.value = 50.0 +( ( i as float / missingAssetsList.count )* 50.0 )
		)
		ATSOps.Refresh()
		scanMissingFiles()
		pb_status.value = 100
		lbl_info_files.text = "Recuperados: " +( relinkCount as string )
		messageBox( "Arquivos Relinkados: " + relinkCount as string ) title: "Resultado"
	)
	-- --- EVENTOS ---
	on rlt_NoobFix open do
	(		
		loadFavoritesFromINI()
		-- FUNCIONALIDADE 3: AUTO SEARCH
		if maxfilepath != "" and searchPath == "" do
		(			
			searchPath = cleanPath maxfilepath
			edt_currentPath.text = searchPath
			btn_relink.Enabled = true
			btn_relink.BackColor = col_GreenSoft
			noobLog "Auto-Search: Pasta do projeto detectada."
		)
		scanMissingFiles()
		-- Estilos
		styleButton btn_browse "..." col_DarkGray fontSize: 8
		styleButton btn_addFav "+" col_DarkGray fontSize: 12
		styleButton btn_delFav "-" col_DarkGray fontSize: 12
		styleButton btn_scan "ESCANEAR CENA" col_OrangeSoft fontSize: 9
		styleButton btn_strip "LIMPAR CAMINHOS (Strip)" col_RedSoft fontSize: 9
		styleButton btn_unc "UNC (Rede)" col_BlueSoft fontSize: 9
		styleButton btn_relink "BUSCAR E RELINKAR" col_GreenSoft fontSize: 11
		styleButton btn_collect "COLETAR (Copy to Project)" col_BlueSoft fontSize: 9
		if btn_relink.Enabled == false do
			btn_relink.BackColor = col_DarkGray
	)
	on btn_browse Click args do
	(		
		local dir = getSavePath caption: "Biblioteca" initialDir: searchPath
		if dir != undefined do
		(			
			searchPath = cleanPath dir
			edt_currentPath.text = searchPath
			btn_relink.Enabled = true
			btn_relink.BackColor = col_GreenSoft
		)
	)
	on lbx_favorites selected index do
	(		
		local selectedPath = cleanPath lbx_favorites.items[index]
		if( doesDirectoryExist selectedPath ) then
		(			
			searchPath = selectedPath
			edt_currentPath.text = selectedPath
			btn_relink.Enabled = true
			btn_relink.BackColor = col_GreenSoft
			lbl_info_files.text = "Pasta pronta."
		)
	)
	on btn_addFav Click args do
	(		
		if searchPath != "" and( doesDirectoryExist searchPath ) do
		(			
			local clean = cleanPath searchPath
			if( findItem lbx_favorites.items clean )== 0 do
			(				
				local temp = lbx_favorites.items
				append temp clean
				lbx_favorites.items = temp
				saveFavoritesToINI()
			)
		)
	)
	on btn_delFav Click args do
	(		
		if lbx_favorites.selection > 0 do
		(			
			local temp = lbx_favorites.items
			deleteItem temp lbx_favorites.selection
			lbx_favorites.items = temp
			saveFavoritesToINI()
		)
	)
	on btn_scan Click args do( scanMissingFiles() )
	on btn_strip Click args do
	(		
		if queryBox "Remover caminhos quebrados? (Irreversivel)" do
			stripMissingPaths()
	)
	on btn_unc Click args do
	(		
		if queryBox "Converter caminhos locais (Z:\\) para rede (\\\\Servidor)?\nIsso facilita render em rede." do
			convertToUNC()
	)
	on lbx_missing selected index do
	(		
		if index != undefined and index > 0 and index <= lbx_missing.items.count do
		(			
			edt_selectedMissing.text = lbx_missing.items[index]
		)
	)
	-- FUNCIONALIDADE 1: DUPLO CLIQUE SELECT
	on lbx_missing doubleClicked args do
	(		
		-- args.Button nao funciona bem em listbox padrao maxscript, usando selecao
		local idx = lbx_missing.selection
		if idx > 0 do
		(			
			local txt = lbx_missing.items[idx]
			if txt != "-- CENA LIMPA --" do
				selectObjectsFromMissing txt
		)
	)
	on btn_relink Click args do( runRelink() )
	on btn_collect Click args do( collectFiles() )
)
createDialog rlt_NoobFix style: #( #style_titlebar, #style_sysmenu, #style_minimizebox )