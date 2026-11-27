import os
from pathlib import Path

import typer
from dotenv import load_dotenv
from internal.queries import QUERIES
from internal.types import REPORTS, DatabaseRow, Report
from sqlalchemy import create_engine
from sqlalchemy.engine import URL, Connection, Engine, make_url
from sqlalchemy.exc import SQLAlchemyError
from tabulate import tabulate


def display_results(columns: list[str], rows: list[DatabaseRow]) -> None:
    if not rows:
        typer.echo("Sem resultados.")
        return

    values: list[list[object]] = [["NULL" if value is None else value for value in row] for row in rows]
    typer.echo(tabulate(values, headers=columns, tablefmt="fancy_grid"))


def execute_query(
    connection: Connection, statement: str, param_value: str | None = None
) -> tuple[list[str], list[DatabaseRow]]:
    result = connection.exec_driver_sql(statement, (param_value,) if param_value is not None else ())
    return list(result.keys()), [tuple(row) for row in result.all()]


def run_menu(connection: Connection) -> None:
    while True:
        typer.echo("\nConsultas da Parte II")
        menu: list[tuple[int, str]] = [(number, report.title) for number, report in REPORTS.items()]
        menu.append((0, "Sair"))
        typer.echo(tabulate(menu, headers=("Opção", "Consulta"), tablefmt="fancy_grid"))

        selection: str = typer.prompt("Selecione uma opção").strip()
        if selection == "0":
            return
        if not selection.isdecimal() or int(selection) not in REPORTS:
            typer.echo("Opção inválida.")
            continue

        number: int = int(selection)
        report: Report = REPORTS[number]
        param_value: str | None = None
        if report.parameter_prompt:
            param_value = typer.prompt(report.parameter_prompt).strip()

        try:
            with connection.begin():
                columns, rows = execute_query(connection, QUERIES[number], param_value)
        except SQLAlchemyError as error:
            typer.echo(f"Erro ao executar a consulta: {error}")
            continue

        typer.echo(f"\n{report.title}")
        display_results(columns, rows)


def main() -> None:
    load_dotenv(Path(__file__).with_name(".env"))

    database_url: str | None = os.getenv("DATABASE_URL")
    if not database_url:
        typer.echo("Defina DATABASE_URL com a URI para o Banco de Dados PostgreSQL.", err=True)
        raise typer.Exit(code=1)

    engine: Engine | None = None
    try:
        url: URL = make_url(database_url)
        typer.echo("URL criada.")
        # pool_pre_ping checa se a conexão por pooling ainda está ativa antes de usar.
        engine = create_engine(url.set(drivername="postgresql+psycopg"), pool_pre_ping=True)
        typer.echo("Mecanismo de conexão criado.")
        with engine.connect() as connection:
            typer.echo("Conexão ao Banco de Dados efetuada.")
            run_menu(connection)
    except (SQLAlchemyError, ValueError) as error:
        typer.echo(f"Erro ao conectar ao PostgreSQL: {error}", err=True)
        raise typer.Exit(code=1) from error
    except KeyboardInterrupt:
        typer.echo("\nPrograma encerrado.")
    finally:
        if engine is not None:
            engine.dispose()
            typer.echo("Mecanismo de conexão encerrado.")


if __name__ == "__main__":
    typer.run(main)
