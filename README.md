Configuração da API Google Analytics
====================================

Configurando o App
------------------

1. Criar projeto em [Google Developers Console](http://console.developers.google.com)
2. Acessar "APIS & AUTH / APIs" e ativar "Analytics API"
3. Acessar "APIS & AUTH / Credentials" e clicar em "Create new Client ID", selecionar "Service Account"
4. Baixar a chave clicando em "Generate new P12 key" e copiar o email em "Service Account / Email Address"
5. Setar as variaveis de ambiente do app:
   * `GOOGLE_API_ACCOUNT_EMAIL=email da service account`
   * `GOOGLE_API_P12=$(base64 caminho/da/chave.p12)`
6. Reiniciar o App

Habilitando Acesso para a Loja
------------------------------

1. Acessar Google Analytics
2. Acessar "Admin / User Management"
3. Adicionar email da service account com a permissão "Read & Analyze".
