import typer
from shared.types import DatabaseRow
from tabulate import tabulate


def display_results(columns: list[str], rows: list[DatabaseRow]) -> None:
    if not rows:
        typer.echo("Sem resultados.")
        return

    values: list[list[object]] = [["NULL" if value is None else value for value in row] for row in rows]
    typer.echo(tabulate(values, headers=columns, tablefmt="fancy_grid"))
