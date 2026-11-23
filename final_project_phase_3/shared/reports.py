from dataclasses import dataclass


@dataclass(frozen=True)
class Report:
    title: str
    parameter_prompt: str | None = None


REPORTS: dict[int, Report] = {
    1: Report("Nota média das obras de produtoras verificadas"),
    2: Report("Métricas de autores verificados"),
    3: Report("Resenhas mais visualizadas por categoria"),
    4: Report("Perfil de engajamento dos usuários"),
    5: Report("Volume de autorias e versatilidade de autores"),
    6: Report("Usuários que resenharam todas as obras de uma categoria", "Nome da categoria"),
    7: Report("Autores com obras em múltiplas categorias"),
    8: Report("Usuários que comentaram em suas próprias resenhas"),
    9: Report("Obras mais bem avaliadas por tipo e categoria"),
    10: Report("Ranking das obras filhas de uma obra", "Nome da obra principal"),
}
