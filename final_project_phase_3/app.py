import os
from dataclasses import dataclass
from pathlib import Path

import psycopg
import typer
from dotenv import load_dotenv
from psycopg import Connection
from psycopg.rows import TupleRow
from tabulate import tabulate


@dataclass(frozen=True)
class Query:
    title: str
    sql: str
    parameter_prompt: str | None = None

DATABASE_ENV_VAR: str = "DATABASE_URL"
QUERIES = (
    Query(
        "Nota média das obras de produtoras verificadas",
        """SELECT
    p.Nome AS NomeProdutora,
    ROUND(AVG(v.NotaMedia), 2) AS NotaMediaGlobal
FROM Produtoras p
JOIN Obras o ON p.id = o.ProdutoraID
JOIN vw_resumo_avaliacoes_obras v ON o.id = v.ObraID
WHERE p.verificado = true
GROUP BY p.id, p.Nome
HAVING COUNT(o.id) > 1;""",
    ),
    Query(
        "Métricas de autores verificados",
        """SELECT
    a.Nome AS Autor,
    COUNT(v.ObraID) AS TotalObras,
    ROUND(AVG(v.NotaMedia), 2) AS NotaMediaGeral
FROM Autor a
JOIN Obras o ON a.id = o.AutorID
JOIN vw_resumo_avaliacoes_obras v ON o.id = v.ObraID
WHERE a.verificado = true
GROUP BY a.id, a.Nome;""",
    ),
    Query(
        "Resenhas mais visualizadas por categoria",
        """SELECT
    r.Cabecalho AS TituloResenha,
    u.Nome AS AutorResenha,
    r.Visualizacoes,
    v.TituloObra,
    v.Categoria,
    v.TipoDeObra
FROM Resenha r
JOIN vw_resumo_avaliacoes_obras v ON r.ObraID = v.ObraID
JOIN Usuario u ON r.UsuarioID = u.id
WHERE r.Visualizacoes = (
    SELECT MAX(r2.Visualizacoes)
    FROM Resenha r2
    JOIN vw_resumo_avaliacoes_obras v2 ON r2.ObraID = v2.ObraID
    WHERE v2.Categoria = v.Categoria
)
ORDER BY r.Visualizacoes DESC;""",
    ),
    Query(
        "Perfil de engajamento dos usuários",
        """SELECT
    u.Nome AS Usuario,
    COUNT(c.id) AS TotalComentarios,
    ROUND(AVG(v.NotaMedia), 2) AS MediaNotaObrasComentadas
FROM Usuario u
JOIN Comentarios c ON u.id = c.UsuarioID
JOIN Resenha r ON c.ResenhaID = r.id
JOIN vw_resumo_avaliacoes_obras v ON r.ObraID = v.ObraID
GROUP BY u.id, u.Nome
HAVING COUNT(c.id) > 1
ORDER BY TotalComentarios DESC;""",
    ),
    Query(
        "Volume de autorias e versatilidade de autores",
        """SELECT
    a.Nome AS NomeAutor,
    COUNT(participacoes.ObraID) AS TotalAutorias,
    COUNT(DISTINCT o.TipoDeObraID) AS TiposDeObrasDistintas
FROM Autor a
JOIN (
    SELECT AutorID, id AS ObraID FROM Obras
    UNION
    SELECT AutorID, ObraID FROM Coautoria
) participacoes ON a.id = participacoes.AutorID
JOIN Obras o ON participacoes.ObraID = o.id
GROUP BY a.id, a.Nome
ORDER BY TotalAutorias DESC, TiposDeObrasDistintas DESC;""",
    ),
    Query(
        "Usuários que resenharam todas as obras de uma categoria",
        """SELECT DISTINCT
    u.Nome AS NomeUsuario,
    c.Nome AS Categoria,
    COUNT(r1.id) AS QtdResenhasDoUsuario
FROM Usuario u
JOIN Resenha r1 ON u.id = r1.UsuarioID
JOIN Obras o1 ON r1.ObraID = o1.id
JOIN Categoria c ON o1.CategoriaID = c.id
WHERE c.Nome = %s
  AND NOT EXISTS (
      SELECT *
      FROM Obras o2
      WHERE o2.CategoriaID = c.id
        AND o2.id NOT IN (
            SELECT r2.ObraID
            FROM Resenha r2
            WHERE r2.UsuarioID = u.id
        )
  )
GROUP BY u.id, u.Nome, c.id, c.Nome;""",
        "Nome da categoria",
    ),
    Query(
        "Autores com obras em múltiplas categorias",
        """SELECT
    a.Nome AS NomeAutor,
    COUNT(DISTINCT c.id) AS QtdCategoriasDistintas
FROM Autor a
JOIN Obras o ON a.id = o.AutorID
JOIN Categoria c ON o.CategoriaID = c.id
GROUP BY a.id, a.Nome
HAVING COUNT(DISTINCT c.id) > 1;""",
    ),
    Query(
        "Usuários que comentaram em suas próprias resenhas",
        """SELECT DISTINCT
    u.Nome AS AutorResenhaEComentario,
    o.Nome AS TituloDaObra,
    c.Comentario AS TextoDoComentario
FROM Usuario u
JOIN Comentarios c ON u.id = c.UsuarioID
JOIN Resenha r ON c.ResenhaID = r.id
JOIN Obras o ON r.ObraID = o.id
WHERE c.UsuarioID = r.UsuarioID;""",
    ),
    Query(
        "Obras mais bem avaliadas por tipo e categoria",
        """SELECT
    v.TituloObra,
    v.NotaMedia,
    v.TipoDeObra,
    v.Categoria,
    o.Publicacao
FROM vw_resumo_avaliacoes_obras v
JOIN Obras o ON v.ObraID = o.id
JOIN Autor a ON o.AutorID = a.id
WHERE v.NotaMedia = (
    SELECT MAX(v2.NotaMedia)
    FROM vw_resumo_avaliacoes_obras v2
    WHERE v2.TipoDeObra = v.TipoDeObra
      AND v2.Categoria = v.Categoria
)
ORDER BY v.TipoDeObra, v.Categoria;""",
    ),
    Query(
        "Ranking das obras filhas de uma obra",
        """SELECT
    obra_pai.Nome AS Album,
    obra_filha.Nome AS Musica,
    v.NotaMedia
FROM Obras obra_filha
JOIN Obras obra_pai ON obra_filha.Relacionado = obra_pai.id
JOIN vw_resumo_avaliacoes_obras v ON obra_filha.id = v.ObraID
WHERE obra_pai.Nome = %s
ORDER BY v.NotaMedia DESC;""",
        "Nome da obra principal",
    ),
)


def execute_query(cursor, sql, params=None):
    if params is None:
        cursor.execute(sql)
    else:
        cursor.execute(sql, params)

    if cursor.description is None:
        return [], []

    return [column.name for column in cursor.description], cursor.fetchall()


def display_results(columns, rows):
    if not rows:
        typer.echo("Sem resultados.")
        return

    values = [["NULL" if value is None else value for value in row] for row in rows]
    typer.echo(tabulate(values, headers=columns, tablefmt="grid"))


def run_menu(connection: Connection[TupleRow], database_error):
    while True:
        typer.echo("\nConsultas da Parte II")
        for number, query in enumerate(QUERIES, start=1):
            typer.echo(f"{number}. {query.title}")
        typer.echo("0. Sair")

        selection: str = typer.prompt("Selecione uma opção").strip()
        if selection == "0":
            return
        if not selection.isdigit() or not 1 <= int(selection) <= len(QUERIES):
            typer.echo("Opção inválida.")
            continue

        query: Query = QUERIES[int(selection) - 1]
        params: tuple[str] | None = None
        if query.parameter_prompt:
            params = (typer.prompt(query.parameter_prompt).strip(),)

        try:
            with connection.cursor() as cursor:
                columns, rows = execute_query(cursor, query.sql, params)
        except database_error as error:
            typer.echo(f"Erro ao executar a consulta: {error}")
            continue

        typer.echo(f"\n{query.title}")
        display_results(columns, rows)


def main() -> None:
    load_dotenv(Path(__file__).with_name(".env"))
    database_url: str | None = os.getenv(DATABASE_ENV_VAR)
    if not database_url:
        typer.echo("Defina DATABASE_URL com a URI PostgreSQL do Supabase.", err=True)
        raise typer.Exit(code=1)

    try:
        with psycopg.connect(database_url, autocommit=True) as connection:
            run_menu(connection, psycopg.Error)
    except psycopg.Error as error:
        typer.echo(f"Erro ao conectar ao PostgreSQL: {error}", err=True)
        raise typer.Exit(code=1) from error
    except KeyboardInterrupt:
        typer.echo("\nPrograma encerrado.")


if __name__ == "__main__":
    typer.run(main)
