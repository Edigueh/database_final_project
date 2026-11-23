# Parte III — aplicativo de consultas

Este CLI em Python executa as dez consultas da Parte II em um banco PostgreSQL. O aplicativo compartilhado [`app.py`](final_project_phase_3/app.py) mantém uma conexão aberta enquanto o menu está em uso. Ambos os modos usam SQLAlchemy: `orm` executa expressões dos modelos, e `positional` executa SQL com parâmetros posicionais. O esquema e as instâncias de teste de origem estão em [`tabelas.sql`](final_project_phase_1-2/tabelas.sql) e [`consultas.sql`](final_project_phase_1-2/consultas.sql).

O aplicativo, os títulos, os prompts e a exibição dos resultados são compartilhados:

```text
final_project_phase_3/
├── app.py
├── positional_params/
│   └── queries.py
├── orm/
│   ├── queries.py
│   └── schema.py
├── shared/
│   ├── display_results.py
│   ├── reports.py
│   └── types.py
├── mypy.ini
├── pyrightconfig.json
├── requirements.txt
├── requirements-dev.txt
└── test_app.py
```

Os arquivos `queries.py` contêm apenas as implementações das dez consultas, identificadas pelos números de 1 a 10. `shared/reports.py` define seus títulos e prompts, e `orm/schema.py` define os modelos ORM das tabelas e da visão.

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
python3 app.py --mode orm
unset DATABASE_URL
```

Como alternativa, defina `DATABASE_URL` em `final_project_phase_3/.env`. O programa lê esse arquivo ao iniciar.

Na pasta `final_project_phase_3`, escolha o modo pela flag ou pela variável `QUERY_MODE`, que também pode ser definida no `.env`:

```sh
python3 app.py --mode orm
python3 app.py --mode positional
QUERY_MODE=positional python3 app.py
```

A flag tem prioridade sobre `QUERY_MODE`. Sem nenhuma configuração, o modo é `orm`. Valores diferentes de `orm` e `positional` são rejeitados antes da conexão. Variáveis já definidas no ambiente têm prioridade sobre o `.env`.

Ambos os modos usam SQLAlchemy 2 com psycopg 3 como driver PostgreSQL, sem chamadas diretas ao psycopg no aplicativo. As consultas posicionais mantêm os placeholders `%s` e recebem os valores em tuplas. Cada consulta tem sua própria transação; falhas causam rollback e permitem continuar usando o menu. Os modelos mapeiam as colunas necessárias aos relatórios, incluindo a visão existente; o aplicativo não chama `create_all()` nem modifica o esquema.

O menu oferece as consultas de 1 a 10; selecione `0` para sair. A consulta 6 solicita uma categoria (por exemplo, `Cyberpunk_C6`) e a consulta 10 solicita o nome da obra principal (por exemplo, `The Dark Side of the Moon_C10`).

Para verificar a seleção de modo, a parametrização, a recuperação de erros e a equivalência das dez consultas em um banco SQLite em memória, execute na raiz do projeto:

```sh
python3 -m unittest discover -s final_project_phase_3 -p 'test_*.py'
```

Para instalar as ferramentas de desenvolvimento e verificar os tipos dos módulos da aplicação, execute em `final_project_phase_3`:

```sh
python3 -m pip install -r requirements-dev.txt
python3 -m mypy
python3 -m basedpyright
```

O `mypy.ini` habilita a checagem estrita do aplicativo, dos modelos, das consultas e dos módulos compartilhados. O `pyrightconfig.json` define o mesmo escopo para o basedpyright; arquivos de teste ficam fora das duas checagens.

#### Autores
- André Schaidhauer Luckmann (00601117)
- Gabriel Felipe Kellermann (00591164)
