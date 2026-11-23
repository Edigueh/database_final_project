import os
from collections.abc import Mapping
from enum import Enum
from pathlib import Path
from typing import Annotated, cast

import typer
from dotenv import load_dotenv
from orm.queries import QUERIES as ORM_QUERIES
from positional_params.queries import QUERIES as POSITIONAL_QUERIES
from shared.display_results import display_results
from shared.reports import REPORTS, Report
from shared.types import DatabaseRow, QueryStatement
from sqlalchemy import create_engine
from sqlalchemy.engine import URL, Engine, make_url
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from tabulate import tabulate


class QueryMode(str, Enum):
    ORM = "orm"
    POSITIONAL = "positional"


def execute_query(
    session: Session, statement: QueryStatement, param_value: str | None = None
) -> tuple[list[str], list[DatabaseRow]]:
    result = (
        session.connection().exec_driver_sql(statement, (param_value,) if param_value is not None else ())
        if isinstance(statement, str)
        else session.execute(statement, {"value": param_value} if param_value is not None else None)
    )
    return list(result.keys()), [tuple(row) for row in result.all()]


def run_menu(session: Session, queries: Mapping[int, QueryStatement]) -> None:
    while True:
        typer.echo("\nConsultas da Parte II")
        menu: list[tuple[int, str]] = [(number, report.title) for number, report in REPORTS.items()]
        menu.append((0, "Sair"))
        typer.echo(tabulate(menu, headers=("Opção", "Consulta"), tablefmt="fancy_grid"))

        selection: str = cast(str, typer.prompt("Selecione uma opção")).strip()
        if selection == "0":
            return
        if not selection.isdecimal() or int(selection) not in REPORTS:
            typer.echo("Opção inválida.")
            continue

        number: int = int(selection)
        report: Report = REPORTS[number]
        param_value: str | None = None
        if report.parameter_prompt:
            param_value = cast(str, typer.prompt(report.parameter_prompt)).strip()

        try:
            with session.begin():
                columns, rows = execute_query(session, queries[number], param_value)
        except SQLAlchemyError as error:
            typer.echo(f"Erro ao executar a consulta: {error}")
            continue

        typer.echo(f"\n{report.title}")
        display_results(columns, rows)


def main(
    mode: Annotated[
        QueryMode | None,
        typer.Option("--mode", help="Modo de consulta; padrão: QUERY_MODE ou orm."),
    ] = None,
) -> None:
    _ = load_dotenv(Path(__file__).with_name(".env"))
    try:
        selected_mode: QueryMode = mode if mode is not None else QueryMode(os.getenv("QUERY_MODE", "orm"))
    except ValueError:
        raise typer.BadParameter("Use orm ou positional.", param_hint="QUERY_MODE") from None
    queries: Mapping[int, QueryStatement] = ORM_QUERIES if selected_mode == QueryMode.ORM else POSITIONAL_QUERIES

    database_url: str | None = os.getenv("DATABASE_URL")
    if not database_url:
        typer.echo("Defina DATABASE_URL com a URI PostgreSQL do Supabase.", err=True)
        raise typer.Exit(code=1)

    engine: Engine | None = None
    try:
        url: URL = make_url(database_url)
        engine = create_engine(url.set(drivername="postgresql+psycopg"), pool_pre_ping=True)
        with engine.connect() as connection, Session(bind=connection) as session:
            run_menu(session, queries)
    except (SQLAlchemyError, ValueError) as error:
        typer.echo(f"Erro ao conectar ao PostgreSQL: {error}", err=True)
        raise typer.Exit(code=1) from error
    except KeyboardInterrupt:
        typer.echo("\nPrograma encerrado.")
    finally:
        if engine is not None:
            engine.dispose()


if __name__ == "__main__":
    typer.run(main)
