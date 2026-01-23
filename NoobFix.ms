/*
    NoobFix v1.2.6
    
    Fusão Definitiva:
    - INTERFACE: Visual da v1.6 (Cores suaves, Layout compacto).
    - MOTOR: Lógica da v2.1 (ATSOps Status Check - O unico que funcionou).
    - NOVIDADE: Botão "Strip Paths" integrado ao design antigo.
*/
try( destroyDialog rlt_NoobFix ) catch()

global NoobFixINI = ( getDir #userScripts )+ "\\NoobFix_Config.ini"
global noobScale = try( GetUIScaleFactor() ) catch( 1.0 )

fn s val = ( val * noobScale )
fn p x y = [x * noobScale, y * noobScale]

-- LOG DE DEBUG (Backend v2.6)
fn noobLog msg = ( format "[NoobFix]: %\n" msg )

rollout rlt_NoobFix "NoobFix v2.2 (Classic UI)" width:( s 400 ) height:( s 700 )
(	
	-- --- AREA 1: ONDE PROCURAR (UI v1.6) ---
	groupBox grp_source "1. Biblioteca" pos:( p 10 10 ) width:( s 380 ) height:( s 70 )
	edittext edt_currentPath "" pos:( p 20 30 ) width:( s 300 ) readOnly: true
	dotNetControl btn_browse "System.Windows.Forms.Button" pos:( p 330 29 ) width:( s 50 ) height:( s 22 )
	label lbl_status "Selecione a pasta raiz" pos:( p 20 55 ) style_sunkenedge: false

	-- --- AREA 2: FAVORITOS (UI v1.6) ---
	groupBox grp_favs "2. Favoritos" pos:( p 10 90 ) width:( s 380 ) height:( s 150 )
	listbox lbx_favorites "" pos:( p 20 110 ) width:( s 300 ) height: 8
	dotNetControl btn_addFav "System.Windows.Forms.Button" pos:( p 330 110 ) width:( s 50 ) height:( s 30 )
	dotNetControl btn_delFav "System.Windows.Forms.Button" pos:( p 330 145 ) width:( s 50 ) height:( s 30 )

	-- --- AREA 3: DIAGNOSTICO (UI v1.6 Adaptada para Strip) ---
	-- Aumentei a altura de 200 para 240 para caber o botao Strip
	groupBox grp_missing "3. Diagnostico" pos:( p 10 250 ) width:( s 380 ) height:( s 240 )
	
	dotNetControl btn_scan "System.Windows.Forms.Button" pos:( p 20 270 ) width:( s 360 ) height:( s 30 )
	listbox lbx_missing "" pos:( p 20 310 ) width:( s 360 ) height: 8
	edittext edt_selectedMissing "" pos:( p 18 425 ) width:( s 360 ) readOnly: true text: "..." border: false
	
	-- [NOVO] Botao Strip integrado no layout antigo
	dotNetControl btn_strip "System.Windows.Forms.Button" pos:( p 20 450 ) width:( s 360 ) height:( s 30 )

	-- --- AREA 4: ACAO (UI v1.6) ---
	-- Deslocado para baixo para compensar o aumento da Area 3
	groupBox grp_action "4. Executar" pos:( p 10 500 ) width:( s 380 ) height:( s 150 )
	checkbox chk_ext "Ignorar Extensao" pos:( p 20 520 ) checked: true
	checkbox chk_sub "Incluir Subpastas" pos:( p 200 520 ) checked: true
	label lbl_info_files "Aguardando..." pos:( p 20 545 ) width:( s 350 ) height:( s 20 )
	
	progressbar pb_status "" pos:( p 20 565 ) width:( s 360 ) height:( s 10 ) color:( color 100 180 110 ) value: 0
	dotNetControl btn_relink "System.Windows.Forms.Button" pos:( p 20 585 ) width:( s 360 ) height:( s 45 )

	-- --- AREA 5: RODAPÉ (UI v1.6) ---
	label lbl_dev "Desenvolvido por NoobDev" pos:( p 20 665 )
	hyperLink hl_git "Visitar GitHub" address: "https://github.com/STUDIOF3/NoobFix_3dsMax" pos:( p 300 665 ) color:( color 230 140 80 ) hoverColor:( color 255 255 255 ) visitedColor:( color 230 140 80 )

	-- Variaveis Locais
	local searchPath = ""
	local foundLibraryFiles = #()
	local missingAssetsList = #() 

	-- --- ESTILOS E CORES (V1.6 Originais) ---
	local col_OrangeSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 230 140 80
	local col_GreenSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 100 180 110
	local col_RedSoft = ( dotNetClass "System.Drawing.Color" ).fromArgb 200 80 80 -- Para o Strip
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
		if p == undefined or p == "" then return ""
		local clean = p
		if( substring clean clean.count 1 )== "\\" do clean = substring clean 1( clean.count - 1 )
		return clean
	)
	
	fn saveFavoritesToINI = 
	(		
		if( doesFileExist NoobFixINI ) do delIniSetting NoobFixINI "Favoritos"
		for i = 1 to lbx_favorites.items.count do setINISetting NoobFixINI "Favoritos"( "Path_" +( i as string ) ) lbx_favorites.items[i]
	)

	fn loadFavoritesFromINI = 
	(		
		if( doesFileExist NoobFixINI ) then
		(			
			local keys = getINISetting NoobFixINI "Favoritos"
			local paths = #()
			sort keys
			for k in keys do append paths( getINISetting NoobFixINI "Favoritos" k )
			lbx_favorites.items = paths
		)
	)

	fn getFilesSafe dir recursive list = 
	(		
		try (			
			local dirInfo = dotNetObject "System.IO.DirectoryInfo" dir
			if not dirInfo.Exists then return undefined
			local files = dirInfo.GetFiles "*.*"( dotNetClass "System.IO.SearchOption" ).TopDirectoryOnly
			for f in files do append list f
			if recursive then (				
				local subDirs = dirInfo.GetDirectories()
				for d in subDirs do getFilesSafe d.FullName true list
			)
		) catch()
	)

	-- --- BACKEND v2.1 (O QUE FUNCIONOU) ---
	
	fn getMissingViaStatus = 
	(
		noobLog "Scan v2.1: Checando Status ATSOps..."
		
		-- Tenta forcar refresh visual do Max
		try( ATSOps.Visible = true; ATSOps.Visible = false )catch() 
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
					-- O SEGREDINHO: GetFileSystemStatus
					local statusArray = ATSOps.GetFileSystemStatus f
					local isMissing = false
					
					if statusArray != undefined do (
						for s in statusArray do (
							if s == #missing do isMissing = true
						)
					)
					
					if not isMissing and not (doesFileExist f) do isMissing = true
					
					if isMissing do appendIfUnique mList f
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
			edt_selectedMissing.text = "Encontrados: " + (missingAssetsList.count as string)
		)
	)

	fn stripMissingPaths =
	(
		if missingAssetsList.count == 0 do return false
		
		local count = 0
		local searchTypes = #(
			#(BitmapTexture, #filename),
			#(VRayBitmap, #HDRIMapName), #(VRayBitmap, #filename),
			#(CoronaBitmap, #filename),
			#(ai_Image, #filename),
			#(OSLMap, #filename)
		)
		
		undo "Strip Paths" on
		(
			for type in searchTypes do
			(
				try (
					local maps = getClassInstances type[1]
					for m in maps do
					(
						if isProperty m type[2] do
						(
							local val = getProperty m type[2]
							local fname = if val != undefined then val else ""
							if (findItem missingAssetsList fname) > 0 do
							(
								setProperty m type[2] ""
								count += 1
							)
						)
					)
				) catch()
			)
		)
		
		scanMissingFiles()
		messageBox ("Caminhos removidos: " + count as string) title:"Strip Result"
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
		
		-- 1. Indexar Biblioteca
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
			if not( fileDict.ContainsKey key ) do fileDict.Add key f.FullName
			if( mod i 200 )== 0 do pb_status.value = 30.0 + ((i as float / totalFiles)*20.0)
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
		try( ATSOps.Visible = true )catch()
		ATSOps.ClearSelection()
		
		for i = 1 to missingAssetsList.count do
		(
			local missingPath = missingAssetsList[i]
			local missingName = filenameFromPath missingPath
			local searchKey = toLower( getFilenameFile missingName )
			
			if (fileDict.ContainsKey searchKey) do
			(
				local newPath = fileDict.Item[searchKey]
				local validMatch = true
				
				if not chk_ext.checked do
				(
					if (toLower (getFilenameType missingPath)) != (toLower (getFilenameType newPath)) do validMatch = false
				)
				
				if validMatch do
				(
					ATSOps.ClearSelection()
					ATSOps.SelectFiles #(missingPath)
					ATSOps.RetargetSelection newPath
					relinkCount += 1
				)
			)
			pb_status.value = 50.0 + ((i as float / missingAssetsList.count)*50.0)
		)
		
		ATSOps.Refresh()
		scanMissingFiles()
		pb_status.value = 100
		
		lbl_info_files.text = "Recuperados: " + (relinkCount as string)
		messageBox ("Arquivos Relinkados: " + relinkCount as string) title:"Resultado"
	)

	-- --- EVENTOS (UI v1.6 Wiring) ---
	on rlt_NoobFix open do
	(		
		loadFavoritesFromINI()
		scanMissingFiles()
		
		-- Estilos v1.6
		styleButton btn_browse "..." col_DarkGray fontSize: 8
		styleButton btn_addFav "+" col_DarkGray fontSize: 12
		styleButton btn_delFav "-" col_DarkGray fontSize: 12
		
		styleButton btn_scan "ESCANEAR CENA" col_OrangeSoft fontSize: 9
		styleButton btn_strip "LIMPAR CAMINHOS (Strip)" col_RedSoft fontSize: 9 -- Botao Novo
		styleButton btn_relink "BUSCAR E RELINKAR" col_GreenSoft fontSize: 11
		
		btn_relink.Enabled = false
		if btn_relink.Enabled == false do btn_relink.BackColor = col_DarkGray
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
	
	on btn_strip Click args do
	(
		if queryBox "Remover caminhos quebrados? (Irreversivel)" do stripMissingPaths()
	)

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