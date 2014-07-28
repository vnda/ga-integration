Configuração da API Google Analytics
====================================

Configurando o App
------------------

1. Criar projeto em [Google Developers Console](http://console.developers.google.com)
2. Acessar "APIS & AUTH / APIs" e ativar "Analytics API"
3. Acessar "APIS & AUTH / Credentials" e clicar em "Create new Client ID", selecionar "Service Account"
4. Clicar em "Generate new P12 key", salvar o arquivo em "config/google_api.p12"
5. Copiar o email em "Service Account / Email Address" e colar no arquivo "config/google_api_account_email"
6. Reiniciar o App

Habilitando Acesso para a Loja
------------------------------

1. Acessar Google Analytics
2. Acessar "Admin / User Management"
3. Adicionar email da service account com a permissão "Read & Analyze".
