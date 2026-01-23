# NoobFix for 3ds Max 🛠️

![Version](https://img.shields.io/badge/version-1.6.0-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-3ds%20Max-orange)

**NoobFix** é uma ferramenta gratuita e open-source desenvolvida para resolver um dos problemas mais comuns no 3ds Max: **Texturas Perdidas (Missing Bitmaps)**.

Diferente de outros scripts, o NoobFix foi construído utilizando métodos híbridos (.NET + MaxScript) para garantir velocidade na busca de arquivos e estabilidade em grandes bibliotecas, com suporte a monitores 4K e um modo de segurança contra travamentos.

---

## 🚀 Funcionalidades Principais

- **Busca Inteligente:** Algoritmo otimizado para encontrar texturas perdidas em segundos.
- **Modo Seguro (Safe Mode):** Método de leitura recursiva que evita que o 3ds Max trave ao encontrar pastas corrompidas ou com nomes excessivamente longos.
- **Suporte Universal:** Funciona com Standard, V-Ray, Corona, Arnold, Redshift, FStorm e OSL.
- **Sistema de Favoritos:** Salve as pastas da sua biblioteca para acesso rápido.
- **Diagnóstico Visual:** Lista interativa que mostra exatamente quais arquivos estão faltando na cena.
- **Interface Responsiva:** Ajuste automático de escala para monitores FullHD, 2K e 4K (High DPI).
- **Ignorar Extensões:** Capacidade de relinkar arquivos mesmo se a extensão mudou (ex: `.jpg` para `.png`).

---

## 📦 Como Instalar

1.  Baixe a última versão na aba [Releases](../../releases).
2.  Arraste o arquivo `NoobFix_Installer.mzp` para dentro da viewport do 3ds Max.
3.  Uma mensagem confirmará a instalação.
4.  Para adicionar o botão à sua barra:
    - Vá em **Customize** > **Customize User Interface** > **Toolbars**.
    - Procure pela categoria: **NoobTools**.
    - Arraste o **NoobFix** para sua barra de ferramentas.

---

## 🖥️ Como Usar

1.  **Selecione a Pasta:** Clique em `...` ou escolha um Favorito para definir onde o script deve procurar as texturas.
2.  **Diagnóstico:** O script listará automaticamente os arquivos perdidos na área "Diagnóstico".
3.  **Configuração:** Marque "Incluir Subpastas" para buscas profundas.
4.  **Buscar:** Clique no botão verde **BUSCAR**.
5.  **Acompanhe:** A barra de progresso indicará o status da operação.

---

📋 Changelog / Notas de Atualização (v1.2.6)

## Changelog

### v2.3.0

- **Visual Feedback:** Adicionado suporte a duplo clique na lista de arquivos faltantes para selecionar automaticamente os objetos na viewport.
- **Suporte Estendido:** Inclusão de classes para Redshift, FStorm, Arnold e OSL nas rotinas de diagnóstico e limpeza.
- **Novo Motor de Diagnóstico (Status Check):** Substituição da verificação manual pela consulta direta ao sistema de rastreamento do 3ds Max (ATSOps), detectando arquivos com 100% de precisão.
- **Busca de Arquivos via .NET:** Implementação da biblioteca do Windows (System.IO) para varredura de pastas, tornando a indexação de subpastas instantânea.
- **Relink via Retarget:** O processo de relink agora utiliza o comando nativo `ATSOps.RetargetSelection`, permitindo corrigir texturas dentro de XRefs e Containers.
- **Auto-Search:** O script agora define automaticamente a pasta do projeto aberto como diretório de busca inicial.
- **Coletar Arquivos (Collect):** Novo botão para copiar todas as texturas relinkadas para uma pasta `\Maps` junto ao arquivo do projeto.
- **Conversor UNC:** Novo botão para converter caminhos de unidade local (ex: `Z:\`) para caminhos de rede universais (ex: `\\Servidor\`).
- **Log Detalhado:** Inclusão de mensagens de debug no Listener (F11) para rastrear exatamente quais arquivos estão sendo detectados e processados.
- **Proteção de XRefs:** O sistema de Strip tenta evitar apagar caminhos de arquivos referenciados externamente para prevenir danos a outros arquivos do projeto.
- **Interface:** Ajustes de layout para acomodar as novas ferramentas mantendo o design clássico da v1.6.

---

## 🤝 Contribuição

Contribuições são bem-vindas! Se você tem uma ideia de melhoria ou encontrou um bug:

1.  Faça um **Fork** do projeto.
2.  Crie uma Branch para sua Feature (`git checkout -b feature/NovaFeature`).
3.  Faça o Commit (`git commit -m 'Adicionando nova feature'`).
4.  Faça o Push (`git push origin feature/NovaFeature`).
5.  Abra um **Pull Request**.

---

## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

Desenvolvido por **NoobDev**.
