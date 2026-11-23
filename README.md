# Parte III — aplicativo de consultas

Este CLI em Python executa as dez consultas da Parte II em um banco PostgreSQL. O programa mantém uma conexão aberta enquanto o menu está em uso. As consultas ficam em `app.py`; o esquema e as instâncias de teste de origem estão em [`tabelas.sql`](final_project_phase_1-2/tabelas.sql) e [`consultas.sql`](final_project_phase_1-2/consultas.sql).

## Banco de dados

Antes de iniciar, configure o banco com as tabelas, a visão `vw_resumo_avaliacoes_obras` e os dados necessários à consulta escolhida. O aplicativo não cria nem preenche o banco. O arquivo `consultas.sql` contém a definição da visão, os dados de exemplo e as consultas da Parte II.

Use a URI PostgreSQL do Supabase em **Project Settings → Database → Connection string → URI**, com conexão direta ou Session Pooler e `sslmode=require`. Codifique caracteres especiais da senha na URI.

## Requisitos

- Python 3.11 ou superior.
- Dependências listadas em `requirements.txt`.
- A variável `DATABASE_URL`, definida no ambiente ou em um arquivo `.env` nesta pasta.

## Instalação e execução

Na pasta `final_project_phase_3`, instale as dependências:

```sh
python3 -m pip install -r requirements.txt
```

No zsh, solicite a URI sem exibi-la no terminal e inicie o programa:

```zsh
read -s 'DATABASE_URL?URI do Supabase: '
export DATABASE_URL
python3 app.py
unset DATABASE_URL
```

Como alternativa, defina `DATABASE_URL` em `final_project_phase_3/.env`. O programa lê esse arquivo ao iniciar.

O menu oferece as consultas de 1 a 10; selecione `0` para sair. A consulta 6 solicita uma categoria (por exemplo, `Cyberpunk_C6`) e a consulta 10 solicita o nome da obra principal (por exemplo, `The Dark Side of the Moon_C10`).

#### Autores
- André Schaidhauer Luckmann (00601117)
- Gabriel Felipe Kellermann (00591164)
