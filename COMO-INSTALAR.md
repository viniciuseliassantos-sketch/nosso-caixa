# Nosso Caixa — como colocar no ar (grátis)

Tempo: uns 20 minutos, uma vez só. Custo: zero (planos gratuitos do Supabase e do GitHub).

## 1. Banco de dados (Supabase)
1. Crie uma conta em https://supabase.com e clique em **New project** (nome: nosso-caixa, região: South America (São Paulo)). Guarde a senha do banco.
2. No menu lateral, abra **SQL Editor**, cole todo o conteúdo do arquivo `supabase-setup.sql` e clique em **Run**. Deve aparecer "Success".
3. Abra **Project Settings › API** e copie a **Project URL** e a chave **anon public**.
4. Abra o arquivo `config.js` num bloco de notas e cole os dois valores no lugar de `COLE_AQUI...`. Salve.

## 2. Publicar o link (GitHub Pages)
1. Crie uma conta em https://github.com e clique em **New repository** (nome: nosso-caixa, marque **Public**, crie).
2. Clique em **uploading an existing file** e arraste todos os arquivos desta pasta (index.html, config.js, sw.js, manifest.webmanifest, os ícones .png). Clique em **Commit changes**.
3. Vá em **Settings › Pages**, em *Branch* escolha **main** e **/ (root)**, clique em **Save**.
4. Em 1 ou 2 minutos aparece o link: `https://SEU-USUARIO.github.io/nosso-caixa/`.

## 3. Ajuste final no Supabase
Em **Authentication › URL Configuration**, coloque o link do passo 2 em **Site URL** e também em **Redirect URLs**. Isso faz os e-mails de confirmação e de "esqueci a senha" voltarem para o app.

(Opcional) Em **Authentication › Sign In / Providers › Email**, desligue **Confirm email** se não quiserem confirmar o e-mail ao criar a conta.

## 4. Nos celulares
1. **Vini**: abra o link, toque em **Criar conta**, entre, escolha "Vini" e toque em **Criar nossa família**. Em **Perfil** aparece o código de convite.
2. **Kety**: abra o mesmo link, crie a conta dela, escolha "Kety", digite o código e toque em **Entrar com o código**.
3. Instale nos dois: Android (Chrome) menu ⋮ › **Instalar app**; iPhone (Safari) compartilhar › **Adicionar à Tela de Início**.

## Lembretes de vencimento
Em **Perfil › Lembretes no celular**, escolham os avisos e toquem em **Gerar lembretes**. Abra o arquivo no celular para adicionar à agenda (iPhone: Calendário; Android: Samsung Calendar, ou importe no Google Agenda pelo computador em calendar.google.com › Configurações › Importar). Os alarmes tocam mesmo com o app fechado. Gerem de novo uma vez por mês.

## Observações
- O plano gratuito do Supabase pausa o projeto após 7 dias seguidos sem nenhum acesso. Usando o app toda semana, isso não acontece; se pausar, é só entrar no painel e clicar em **Restore**.
- Backup: **Perfil › Baixar backup completo** gera um arquivo com todos os dados.
- Para atualizar o app depois, basta enviar o novo `index.html` no GitHub.
