# NoobFix for 3ds Max 🛠️

![Version](https://img.shields.io/badge/version-1.6.0-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-3ds%20Max-orange)

**NoobFix** é uma ferramenta gratuita e open-source desenvolvida para resolver um dos problemas mais comuns no 3ds Max: **Texturas Perdidas (Missing Bitmaps)**.

Diferente de outros scripts, o NoobFix foi construído utilizando métodos híbridos (.NET + MaxScript) para garantir velocidade na busca de arquivos e estabilidade em grandes bibliotecas, com suporte a monitores 4K e um modo de segurança contra travamentos.

---

## 🚀 Funcionalidades Principais

* **Busca Inteligente:** Algoritmo otimizado para encontrar texturas perdidas em segundos.
* **Modo Seguro (Safe Mode):** Método de leitura recursiva que evita que o 3ds Max trave ao encontrar pastas corrompidas ou com nomes excessivamente longos.
* **Suporte Universal:** Funciona com Standard, V-Ray, Corona, Arnold, Redshift, FStorm e OSL.
* **Sistema de Favoritos:** Salve as pastas da sua biblioteca para acesso rápido.
* **Diagnóstico Visual:** Lista interativa que mostra exatamente quais arquivos estão faltando na cena.
* **Interface Responsiva:** Ajuste automático de escala para monitores FullHD, 2K e 4K (High DPI).
* **Ignorar Extensões:** Capacidade de relinkar arquivos mesmo se a extensão mudou (ex: `.jpg` para `.png`).

---

## 📦 Como Instalar

1.  Baixe a última versão na aba [Releases](../../releases).
2.  Arraste o arquivo `NoobFix_Installer.mzp` para dentro da viewport do 3ds Max.
3.  Uma mensagem confirmará a instalação.
4.  Para adicionar o botão à sua barra:
    * Vá em **Customize** > **Customize User Interface** > **Toolbars**.
    * Procure pela categoria: **NoobTools**.
    * Arraste o **NoobFix** para sua barra de ferramentas.

---

## 🖥️ Como Usar

1.  **Selecione a Pasta:** Clique em `...` ou escolha um Favorito para definir onde o script deve procurar as texturas.
2.  **Diagnóstico:** O script listará automaticamente os arquivos perdidos na área "Diagnóstico".
3.  **Configuração:** Marque "Incluir Subpastas" para buscas profundas.
4.  **Buscar:** Clique no botão verde **BUSCAR**.
5.  **Acompanhe:** A barra de progresso indicará o status da operação.

---

## 📝 Histórico de Atualizações (Changelog)

### v1.6.0 (Versão Atual)
* **Novo:** Adicionada Barra de Progresso visual (verde) para acompanhar o status da busca.
* **Novo:** Rodapé com créditos e link direto para o repositório GitHub.
* **UI:** Ajustes finos de altura da janela para melhor visualização.

### v1.5.2
* **Fix:** Correção crítica no tratamento de Strings (Case Sensitive) que causava erro em alguns sistemas.
* **Fix:** Melhoria na compatibilidade do "Modo Seguro".

### v1.5.0
* **Novo:** Implementação do **Safe Mode** (Busca Segura). O script agora lê pasta por pasta individualmente, impedindo que um erro de permissão do Windows cancele toda a busca.
* **Fix:** Tratamento para caminhos de arquivo muito longos (limite do Windows).

### v1.4.0
* **Novo:** Sistema de alerta caso a pasta selecionada esteja vazia ou bloqueada.
* **Fix:** Função de limpeza de caminhos para evitar barras duplicadas.

### v1.3.0
* **Novo:** **Suporte High DPI (4K)**. O script detecta a escala do monitor e ajusta automaticamente o tamanho das fontes e botões.

### v1.1.0 - v1.2.0
* **UI:** Reformulação visual para estilo "Flat" com botões coloridos modernos.
* **UX:** Melhor feedback visual nos botões de ação.

### v1.0.0
* Lançamento inicial.
* Sistema de busca via .NET Hashtables.
* Suporte a V-Ray e Corona.

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
