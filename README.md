# Parte III — aplicativo de consultas

CLI em Python que executa as dez consultas da Parte II em um banco PostgreSQL. O [`app.py`](final_project_phase_3/app.py) mantém uma conexão aberta enquanto o menu está em uso. Ambos os modos usam SQLAlchemy: `orm` executa expressões dos modelos, e `positional` executa SQL com parâmetros posicionais. O esquema e as instâncias de teste de origem estão em [`tabelas.sql`](final_project_phase_1-2/tabelas.sql) e [`consultas.sql`](final_project_phase_1-2/consultas.sql).

## Banco de dados

Antes de iniciar, configure o banco com as tabelas, a visão `vw_resumo_avaliacoes_obras` e os dados necessários à consulta escolhida. O aplicativo não cria nem preenche o banco. O arquivo `consultas.sql` contém a definição da visão, os dados de exemplo e as consultas da Parte II.

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

Ambos os modos usam SQLAlchemy 2 com psycopg 3 como driver PostgreSQL. As consultas posicionais mantêm os placeholders `%s` e recebem os valores em tuplas. Cada consulta tem sua própria transação; falhas causam rollback e permitem continuar usando o menu.

### Autores

- André Schaidhauer Luckmann (00601117)
- Gabriel Felipe Kellermann (00591164)
