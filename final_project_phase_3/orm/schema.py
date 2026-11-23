from datetime import date
from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


# Os modelos mapeiam somente as colunas usadas pelos relatórios.
class Usuario(Base):
    __tablename__: str = "usuario"

    id: Mapped[int] = mapped_column(primary_key=True)
    nome: Mapped[str] = mapped_column()


class Categoria(Base):
    __tablename__: str = "categoria"

    id: Mapped[int] = mapped_column(primary_key=True)
    nome: Mapped[str] = mapped_column()


class TipoDeObra(Base):
    __tablename__: str = "tipodeobra"

    id: Mapped[int] = mapped_column(primary_key=True)
    nome: Mapped[str] = mapped_column()


class Autor(Base):
    __tablename__: str = "autor"

    id: Mapped[int] = mapped_column(primary_key=True)
    nome: Mapped[str] = mapped_column()
    verificado: Mapped[bool] = mapped_column()


class Produtora(Base):
    __tablename__: str = "produtoras"

    id: Mapped[int] = mapped_column(primary_key=True)
    nome: Mapped[str] = mapped_column()
    verificado: Mapped[bool] = mapped_column()


class Obra(Base):
    __tablename__: str = "obras"

    id: Mapped[int] = mapped_column(primary_key=True)
    nome: Mapped[str] = mapped_column()
    publicacao: Mapped[date | None] = mapped_column()
    produtora_id: Mapped[int | None] = mapped_column("produtoraid", ForeignKey("produtoras.id"))
    autor_id: Mapped[int] = mapped_column("autorid", ForeignKey("autor.id"))
    tipo_de_obra_id: Mapped[int] = mapped_column("tipodeobraid", ForeignKey("tipodeobra.id"))
    categoria_id: Mapped[int] = mapped_column("categoriaid", ForeignKey("categoria.id"))
    relacionado: Mapped[int | None] = mapped_column(ForeignKey("obras.id"))


class Resenha(Base):
    __tablename__: str = "resenha"

    id: Mapped[int] = mapped_column(primary_key=True)
    usuario_id: Mapped[int] = mapped_column("usuarioid", ForeignKey("usuario.id"))
    cabecalho: Mapped[str] = mapped_column()
    visualizacoes: Mapped[int] = mapped_column()
    obra_id: Mapped[int] = mapped_column("obraid", ForeignKey("obras.id"))


class Coautoria(Base):
    __tablename__: str = "coautoria"

    autor_id: Mapped[int] = mapped_column("autorid", ForeignKey("autor.id"), primary_key=True)
    obra_id: Mapped[int] = mapped_column("obraid", ForeignKey("obras.id"), primary_key=True)


class Comentario(Base):
    __tablename__: str = "comentarios"

    id: Mapped[int] = mapped_column(primary_key=True)
    usuario_id: Mapped[int] = mapped_column("usuarioid", ForeignKey("usuario.id"))
    resenha_id: Mapped[int] = mapped_column("resenhaid", ForeignKey("resenha.id"))
    comentario: Mapped[str] = mapped_column()


class ResumoAvaliacoes(Base):
    __tablename__: str = "vw_resumo_avaliacoes_obras"

    # A visão tem uma linha por obra; o ORM precisa de uma chave para o mapeamento.
    obra_id: Mapped[int] = mapped_column("obraid", primary_key=True)
    titulo_obra: Mapped[str] = mapped_column("tituloobra")
    categoria: Mapped[str] = mapped_column()
    tipo_de_obra: Mapped[str] = mapped_column("tipodeobra")
    nota_media: Mapped[Decimal | None] = mapped_column("notamedia", Numeric)
