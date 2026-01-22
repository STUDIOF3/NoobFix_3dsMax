/*
    NoobFix v1.6.0
    Versao Profissional com Feedback Visual.
    
    Novidades:
    - Barra de Progresso (ProgressBar) real.
    - Rodapé com Creditos e Link para GitHub.
    - Ajustes finos de layout.
*/
try( destroyDialog rlt_NoobFix ) catch()
global NoobFixINI = ( getDir #userScripts )+ "\\NoobFix_Config.ini"
-- Escala automatica
global noobScale = try( GetUIScaleFactor() ) catch( 1.0 )
fn s val = ( val * noobScale )
fn p x y = [x * noobScale, y * noobScale]
rollout rlt_NoobFix "NoobFix v1.6.0" width:( s 400 ) height:( s 660 )

(	
	-- --- AREA 1: ONDE PROCURAR ---
	groupBox grp_source "1. Biblioteca" pos:( p 10 10 ) width:( s 380 ) height:( s 70 )
	edittext edt_currentPath "" pos:( p 20 30 ) width:( s 300 ) readOnly: true
	dotNetControl btn_browse "System.Windows.Forms.Button" pos:( p 330 29 ) width:( s 50 ) height:( s 22 )
	label lbl_status "Selecione a pasta raiz" pos:( p 20 55 ) style_sunkenedge: false
	-- --- AREA 2: FAVORITOS ---
	groupBox grp_favs "2. Favoritos" pos:( p 10 90 ) width:( s 380 ) height:( s 150 )
	listbox lbx_favorites "" pos:( p 20 110 ) width:( s 300 ) height: 8
	dotNetControl btn_addFav "System.Windows.Forms.Button" pos:( p 330 110 ) width:( s 50 ) height:( s 30 )
	dotNetControl btn_delFav "System.Windows.Forms.Button" pos:( p 330 145 ) width:( s 50 ) height:( s 30 )
	-- --- AREA 3: DIAGNOSTICO ---
	groupBox grp_missing "3. Diagnostico" pos:( p 10 250 ) width:( s 380 ) height:( s 200 )
	dotNetControl btn_scan "System.Windows.Forms.Button" pos:( p 20 270 ) width:( s 360 ) height:( s 30 )
	listbox lbx_missing "" pos:( p 20 310 ) width:( s 360 ) height: 8
	edittext edt_selectedMissing "" pos:( p 18 425 ) width:( s 360 ) readOnly: true text: "Caminho completo aparece aqui" border: false
	-- --- AREA 4: ACAO ---
	groupBox grp_action "4. Executar" pos:( p 10 460 ) width:( s 380 ) height:( s 150 )
	checkbox chk_ext "Ignorar Extensao" pos:( p 20 480 ) checked: true
	checkbox chk_sub "Incluir Subpastas" pos:( p 200 480 ) checked: true
	label lbl_info_files "Aguardando..." pos:( p 20 505 ) width:( s 350 ) height:( s 20 )
	-- Barra de Progresso
	progressbar pb_status "" pos:( p 20 525 ) width:( s 360 ) height:( s 10 ) color:( color 100 180 110 ) value: 0
	dotNetControl btn_relink "System.Windows.Forms.Button" pos:( p 20 545 ) width:( s 360 ) height:( s 45 )
	-- --- AREA 5: RODAPÉ (GitHub) ---
	label lbl_dev "Desenvolvido por NoobDev" pos:( p 20 625 )
	hyperLink hl_git "Visitar GitHub" address: "https://github.com/STUDIOF3/NoobFix_3dsMax" pos:( p 300 625 ) color:( color 230 140 80 ) hoverColor:( color 255 255 255 ) visitedColor:( color 230 140 80 )
	-- Variaveis
	local searchPath = ""
	local foundLibraryFiles = #()
	-- --- ESTILOS E CORES ---
	local col_OrangeSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 230 140 80
	local col_GreenSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 100 180 110
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
	-- --- LOGICA ---
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
		(			
			setINISetting NoobFixINI "Favoritos"( "Path_" +( i as string ) ) lbx_favorites.items[i]
		)
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
				(					
					getFilesSafe d.FullName true list
				)
			)
		)
		catch()
	)
	fn getSupportedMaps = 
	(		
		local mapsToCheck = #()
		append mapsToCheck #( BitmapTexture, #filename )
		if( VRayBitmap != undefined ) do
			append mapsToCheck #( VRayBitmap, #HDRIMapName )
		if( VRayHDRI != undefined ) do
			append mapsToCheck #( VRayHDRI, #HDRIMapName )
		if( CoronaBitmap != undefined ) do
			append mapsToCheck #( CoronaBitmap, #filename )
		if( ai_Image != undefined ) do
			append mapsToCheck #( ai_Image, #filename )
		if( Redshift_Bitmap != undefined ) do
			append mapsToCheck #( Redshift_Bitmap, #filename )
		if( OSLMap != undefined ) do
			append mapsToCheck #( OSLMap, #filename )
		return mapsToCheck
	)
	fn scanMissingFiles = 
	(		
		local missingPaths = #()
		local definitions = getSupportedMaps()
		for def in definitions do
		(			
			local mapClass = def[1]
			local propName = def[2]
			local sceneMaps = getClassInstances mapClass
			for map in sceneMaps do
			(				
				local currentPath = getProperty map propName
				if currentPath != undefined and currentPath != "" and not( doesFileExist currentPath ) do
				(					
					appendIfUnique missingPaths currentPath
				)
			)
		)
		sort missingPaths
		lbx_missing.items = missingPaths
		if missingPaths.count == 0 then
		(			
			lbx_missing.items = #( "-- CENA LIMPA --" )
			edt_selectedMissing.text = ""
		)
	)
	fn runRelink = 
	(		
		searchPath = cleanPath searchPath
		pb_status.value = 0 -- Reseta barra
		if searchPath == "" or not( doesDirectoryExist searchPath ) do
		(			
			messageBox "Selecione uma pasta valida."
			return false
		)
		lbl_info_files.text = "Lendo disco..."
		windows.processPostedMessages()
		local fileDict = dotNetObject "System.Collections.Hashtable"
		foundLibraryFiles = #()
		-- Fase 1: Leitura (0 a 30%)
		getFilesSafe searchPath chk_sub.checked foundLibraryFiles
		pb_status.value = 30
		lbl_info_files.text = "Biblio: " +( foundLibraryFiles.count as string )+ " arqs. Indexando..."
		windows.processPostedMessages()
		if foundLibraryFiles.count == 0 then
		(			
			messageBox( "ALERTA: 0 arquivos encontrados em:\n" + searchPath ) title: "Pasta Vazia?"
			pb_status.value = 0
			return false
		)
		-- Fase 2: Indexacao (30 a 60%)
		local totalFiles = foundLibraryFiles.count
		for i = 1 to totalFiles do
		(			
			local f = foundLibraryFiles[i]
			local key = toLower( getFilenameFile f.Name )
			if not( fileDict.ContainsKey key ) do
				fileDict.Add key f.FullName
			-- Atualiza barra a cada 100 arquivos pra nao travar
			if( mod i 100 )== 0 do
			(				
				local pct = 30.0 +( ( i as float / totalFiles as float )* 30.0 )
				pb_status.value = pct
			)
		)
		pb_status.value = 60
		lbl_info_files.text = "Relinkando..."
		local definitions = getSupportedMaps()
		local relinkedCount = 0
		local totalDefs = definitions.count
		undo "NoobFix" on 
		(			
			-- Fase 3: Relink (60 a 100%)
			for dIdx = 1 to totalDefs do
			(				
				local def = definitions[dIdx]
				local mapClass = def[1]
				local propName = def[2]
				local sceneMaps = getClassInstances mapClass
				for map in sceneMaps do
				(					
					local currentPath = getProperty map propName
					if currentPath != undefined and currentPath != "" and not( doesFileExist currentPath ) do
					(						
						local missingName = filenameFromPath currentPath
						local searchKey = toLower( getFilenameFile missingName )
						if( fileDict.ContainsKey searchKey ) then
						(							
							local newPath = fileDict.Item[searchKey]
							local validMatch = true
							if not chk_ext.checked do
							(								
								if( toLower( getFilenameType currentPath ) )!=( toLower( getFilenameType newPath ) ) do
									validMatch = false
							)
							if validMatch do
							(								
								setProperty map propName newPath
								relinkedCount += 1
							)
						)
					)
				)
				-- Atualiza progresso baseado nos tipos de mapa
				local pct = 60.0 +( ( dIdx as float / totalDefs as float )* 40.0 )
				pb_status.value = pct
			)
		)
		pb_status.value = 100
		freeSceneBitmaps()
		completeRedraw()
		scanMissingFiles()
		lbl_info_files.text = "Sucesso: " +( relinkedCount as string )+ " recuperados."
		messageBox( "Sucesso!\nRecuperados: " +( relinkedCount as string ) ) title: "NoobFix"
	)
	-- --- EVENTOS ---
	on rlt_NoobFix open do
	(		
		loadFavoritesFromINI()
		scanMissingFiles()
		styleButton btn_browse "..." col_DarkGray fontSize: 8
		styleButton btn_addFav "+" col_DarkGray fontSize: 12
		styleButton btn_delFav "-" col_DarkGray fontSize: 12
		styleButton btn_scan "ESCANEAR CENA" col_OrangeSoft fontSize: 9
		styleButton btn_relink "BUSCAR" col_GreenSoft fontSize: 11
		btn_relink.Enabled = false
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
			lbl_info_files.text = "Pasta pronta. Clique em BUSCAR."
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
	on lbx_missing selected index do
	(		
		if index != undefined and index > 0 and index <= lbx_missing.items.count do
		(			
			edt_selectedMissing.text = lbx_missing.items[index]
		)
	)
	on btn_relink Click args do( runRelink() )
)
createDialog rlt_NoobFix style: #( #style_titlebar, #style_sysmenu, #style_minimizebox )