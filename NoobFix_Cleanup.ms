/* NoobFix Cleanup - Remove versões antigas antes de instalar */
try (
    -- Define o caminho da instalação antiga
    local installDir = (getDir #userScripts) + "\\NoobFix"
    
    -- Se a pasta existe, deleta ela e tudo que tem dentro
    if (doesDirectoryExist installDir) then (
        -- Usa comando .NET para forçar a exclusão completa da pasta
        (dotNetClass "System.IO.Directory").Delete installDir true
        print "Versão antiga do NoobFix removida com sucesso."
    )
) catch (
    -- Se der erro (ex: pasta aberta), segue o jogo
    print "Nenhuma versão anterior encontrada ou erro ao remover."
)