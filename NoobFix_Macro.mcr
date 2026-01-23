macroScript NoobFix
category: "NoobTools"
tooltip: "NoobFix v2.3.0"
icon: #( "NoobFix", 1 )
-- O Max vai ler "NoobFix" e procurar automaticamente por "NoobFix_24i.bmp" na pasta de icones
(	
	on execute do
	(		
		local scriptPath = ( getDir #userScripts )+ "\\NoobFix\\NoobFix.ms"
		if( doesFileExist scriptPath ) then
		(			
			fileIn scriptPath
		)
		else
		(			
			messageBox "Erro: Script não encontrado."
		)
	)
)