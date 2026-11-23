from decimal import Decimal

from orm.schema import (
    Autor,
    Categoria,
    Coautoria,
    Comentario,
    Obra,
    Produtora,
    Resenha,
    ResumoAvaliacoes,
    Usuario,
)
from sqlalchemy import bindparam, func, select
from sqlalchemy.orm import aliased
from sqlalchemy.sql import Executable
from sqlalchemy.sql.selectable import Exists, ScalarSelect, SelectBase, Subquery

resenha_categoria: type[Resenha] = aliased(Resenha)
resumo_categoria: type[ResumoAvaliacoes] = aliased(ResumoAvaliacoes)
max_visualizacoes: ScalarSelect[int] = (
    select(func.max(resenha_categoria.visualizacoes))
    .join(resumo_categoria, resenha_categoria.obra_id == resumo_categoria.obra_id)
    .where(resumo_categoria.categoria == ResumoAvaliacoes.categoria)
    .correlate(ResumoAvaliacoes)
    .scalar_subquery()
)

participacoes: Subquery = (
    select(Obra.autor_id.label("autorid"), Obra.id.label("obraid"))
    .union(select(Coautoria.autor_id, Coautoria.obra_id))
    .subquery("participacoes")
)

obra_categoria: type[Obra] = aliased(Obra)
resenha_usuario: type[Resenha] = aliased(Resenha)
obras_resenhadas: SelectBase = (
    select(resenha_usuario.obra_id)
    .where(resenha_usuario.usuario_id == Usuario.id)
    .correlate(Usuario)
)
obras_nao_resenhadas: Exists = (
    select(obra_categoria.id)
    .where(
        obra_categoria.categoria_id == Categoria.id,
        obra_categoria.id.not_in(obras_resenhadas),
    )
    .correlate(Categoria, Usuario)
    .exists()
)

resumo_tipo_categoria: type[ResumoAvaliacoes] = aliased(ResumoAvaliacoes)
max_nota_media: ScalarSelect[Decimal | None] = (
    select(func.max(resumo_tipo_categoria.nota_media))
    .where(
        resumo_tipo_categoria.tipo_de_obra == ResumoAvaliacoes.tipo_de_obra,
        resumo_tipo_categoria.categoria == ResumoAvaliacoes.categoria,
    )
    .correlate(ResumoAvaliacoes)
    .scalar_subquery()
)

obra_pai: type[Obra] = aliased(Obra)
obra_filha: type[Obra] = aliased(Obra)

QUERIES: dict[int, Executable] = {
    1: (
        select(
            Produtora.nome.label("nomeprodutora"),
            func.round(func.avg(ResumoAvaliacoes.nota_media), 2).label("notamediaglobal"),
        )
        .select_from(Produtora)
        .join(Obra, Produtora.id == Obra.produtora_id)
        .join(ResumoAvaliacoes, Obra.id == ResumoAvaliacoes.obra_id)
        .where(Produtora.verificado.is_(True))
        .group_by(Produtora.id, Produtora.nome)
        .having(func.count(Obra.id) > 1)
    ),
    2: (
        select(
            Autor.nome.label("autor"),
            func.count(ResumoAvaliacoes.obra_id).label("totalobras"),
            func.round(func.avg(ResumoAvaliacoes.nota_media), 2).label("notamediageral"),
        )
        .select_from(Autor)
        .join(Obra, Autor.id == Obra.autor_id)
        .join(ResumoAvaliacoes, Obra.id == ResumoAvaliacoes.obra_id)
        .where(Autor.verificado.is_(True))
        .group_by(Autor.id, Autor.nome)
    ),
    3: (
        select(
            Resenha.cabecalho.label("tituloresenha"),
            Usuario.nome.label("autorresenha"),
            Resenha.visualizacoes,
            ResumoAvaliacoes.titulo_obra.label("tituloobra"),
            ResumoAvaliacoes.categoria,
            ResumoAvaliacoes.tipo_de_obra.label("tipodeobra"),
        )
        .select_from(Resenha)
        .join(ResumoAvaliacoes, Resenha.obra_id == ResumoAvaliacoes.obra_id)
        .join(Usuario, Resenha.usuario_id == Usuario.id)
        .where(Resenha.visualizacoes == max_visualizacoes)
        .order_by(Resenha.visualizacoes.desc())
    ),
    4: (
        select(
            Usuario.nome.label("usuario"),
            func.count(Comentario.id).label("totalcomentarios"),
            func.round(func.avg(ResumoAvaliacoes.nota_media), 2).label("medianotaobrascomentadas"),
        )
        .select_from(Usuario)
        .join(Comentario, Usuario.id == Comentario.usuario_id)
        .join(Resenha, Comentario.resenha_id == Resenha.id)
        .join(ResumoAvaliacoes, Resenha.obra_id == ResumoAvaliacoes.obra_id)
        .group_by(Usuario.id, Usuario.nome)
        .having(func.count(Comentario.id) > 1)
        .order_by(func.count(Comentario.id).desc())
    ),
    5: (
        select(
            Autor.nome.label("nomeautor"),
            func.count(participacoes.c.obraid).label("totalautorias"),
            func.count(Obra.tipo_de_obra_id.distinct()).label("tiposdeobrasdistintas"),
        )
        .select_from(Autor)
        .join(participacoes, Autor.id == participacoes.c.autorid)
        .join(Obra, participacoes.c.obraid == Obra.id)
        .group_by(Autor.id, Autor.nome)
        .order_by(func.count(participacoes.c.obraid).desc(), func.count(Obra.tipo_de_obra_id.distinct()).desc())
    ),
    6: (
        select(
            Usuario.nome.label("nomeusuario"),
            Categoria.nome.label("categoria"),
            func.count(Resenha.id).label("qtdresenhasdousuario"),
        )
        .distinct()
        .select_from(Usuario)
        .join(Resenha, Usuario.id == Resenha.usuario_id)
        .join(Obra, Resenha.obra_id == Obra.id)
        .join(Categoria, Obra.categoria_id == Categoria.id)
        .where(Categoria.nome == bindparam("value"), ~obras_nao_resenhadas)
        .group_by(Usuario.id, Usuario.nome, Categoria.id, Categoria.nome)
    ),
    7: (
        select(
            Autor.nome.label("nomeautor"),
            func.count(Categoria.id.distinct()).label("qtdcategoriasdistintas"),
        )
        .select_from(Autor)
        .join(Obra, Autor.id == Obra.autor_id)
        .join(Categoria, Obra.categoria_id == Categoria.id)
        .group_by(Autor.id, Autor.nome)
        .having(func.count(Categoria.id.distinct()) > 1)
    ),
    8: (
        select(
            Usuario.nome.label("autorresenhaecomentario"),
            Obra.nome.label("titulodaobra"),
            Comentario.comentario.label("textodocomentario"),
        )
        .distinct()
        .select_from(Usuario)
        .join(Comentario, Usuario.id == Comentario.usuario_id)
        .join(Resenha, Comentario.resenha_id == Resenha.id)
        .join(Obra, Resenha.obra_id == Obra.id)
        .where(Comentario.usuario_id == Resenha.usuario_id)
    ),
    9: (
        select(
            ResumoAvaliacoes.titulo_obra.label("tituloobra"),
            ResumoAvaliacoes.nota_media.label("notamedia"),
            ResumoAvaliacoes.tipo_de_obra.label("tipodeobra"),
            ResumoAvaliacoes.categoria,
            Obra.publicacao,
        )
        .select_from(ResumoAvaliacoes)
        .join(Obra, ResumoAvaliacoes.obra_id == Obra.id)
        .join(Autor, Obra.autor_id == Autor.id)
        .where(ResumoAvaliacoes.nota_media == max_nota_media)
        .order_by(ResumoAvaliacoes.tipo_de_obra, ResumoAvaliacoes.categoria)
    ),
    10: (
        select(
            obra_pai.nome.label("album"),
            obra_filha.nome.label("musica"),
            ResumoAvaliacoes.nota_media.label("notamedia"),
        )
        .select_from(obra_filha)
        .join(obra_pai, obra_filha.relacionado == obra_pai.id)
        .join(ResumoAvaliacoes, obra_filha.id == ResumoAvaliacoes.obra_id)
        .where(obra_pai.nome == bindparam("value"))
        .order_by(ResumoAvaliacoes.nota_media.desc())
    ),
}
