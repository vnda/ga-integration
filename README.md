# Instalação, rodando projeto e executando os testes automatizados

## Requirements

* Ruby 2.5.5
* PostGIS

## Instalação:

1. Instalar as Gems

```sh
$ bin/bundle install
```

2. Copiar o `.env.sample` para `.env` e configurar os campos com os valores apropriados.

3. Copiar o `config/database.yml.sample` para `config/database.yml` e configurar para os bancos de desenvolvimento e teste. Nota: deve-se dar ao usuário permissão para criar bancos no PostgreSQL.

4. Criar o banco com as tabelas para os testes. **NOTA**: Esse comando só vai funcionar se a configuração com a API Google Analytics estiver feita (ver abaixo)

```sh
$ bin/rake db:create db:migrate db:test:prepare
```

## Rodando o projeto:

```sh
# Iniciar o rails server
$ bin/rails s
```

Acesso no navegador: http://localhost:3000/

## Rodando os testes automatizados:

```sh
$ bin/rake test
```

## Configuração da API Google Analytics

### Configurando o App

1. Criar projeto em [Google Developers Console](http://console.developers.google.com)
2. Acessar "APIS & AUTH / APIs" e ativar "Analytics API"
3. Acessar "APIS & AUTH / Credentials" e clicar em "Create new Client ID", selecionar "Service Account"
4. Baixar a chave clicando em "Generate new P12 key" e copiar o email em "Service Account / Email Address"
5. Setar as variaveis de ambiente do app:
   * `GOOGLE_API_ACCOUNT_EMAIL=email da service account`
   * `GOOGLE_API_P12=$(base64 caminho/da/chave.p12)`
6. Reiniciar o App

### Habilitando Acesso para a Loja

1. Acessar Google Analytics
2. Acessar "Admin / User Management"
3. Adicionar email da service account com a permissão "Read & Analyze".
