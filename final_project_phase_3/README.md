# Parte III — acesso às consultas

O programa é um CLI em Python que executa as dez consultas da Parte II no PostgreSQL do Supabase. Ele usa Psycopg 3 diretamente e envia os valores das consultas parametrizadas separadamente do SQL.

## Requisitos

- Python 3.10 ou superior.
- Projeto Supabase com as tabelas, a visão vw_resumo_avaliacoes_obras e os dados de teste da Parte II carregados.
- URI de conexão PostgreSQL do Supabase, obtida em **Project Settings → Database → Connection string → URI**. Use a conexão direta ou a Session Pooler; a URI deve usar SSL (sslmode=require). Se a senha tiver caracteres especiais, use a URI copiada pelo painel ou codifique esses caracteres.

Não use as chaves anon ou service_role: elas não são credenciais de conexão PostgreSQL. Não grave a URI no código nem a envie ao repositório.

## Instalação e execução

Na pasta final_project_phase_3:

    python3 -m pip install -r requirements.txt
    read -s 'DATABASE_URL?URI do Supabase: '
    export DATABASE_URL
    python3 app.py
    unset DATABASE_URL

O valor lido pelo terminal não aparece na tela nem fica escrito no comando. O programa mantém uma conexão durante o menu e encerra ao selecionar 0.

## Consultas parametrizadas

- Consulta 6: informe uma categoria, por exemplo Cyberpunk_C6.
- Consulta 10: informe o nome da obra principal, por exemplo The Dark Side of the Moon_C10.

As duas usam placeholders %s do Psycopg e cursor.execute(sql, (valor,)). As demais consultas são enviadas sem parâmetros. O resultado mostra os nomes das colunas e os valores retornados; consultas sem linhas exibem Sem resultados.

Execute as verificações locais com python3 -m unittest discover -s .
