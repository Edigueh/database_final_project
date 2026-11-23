DROP VIEW IF EXISTS vw_resumo_avaliacoes_obras;
DROP TABLE IF EXISTS comentarios;
DROP TABLE IF EXISTS coautoria;
DROP TABLE IF EXISTS resenha;
DROP TABLE IF EXISTS obras;
DROP TABLE IF EXISTS produtoras;
DROP TABLE IF EXISTS autor;
DROP TABLE IF EXISTS tipodeobra;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS usuario;
-- ================================================================
-- Autores: André Schaidhauer Luckmann & Gabriel Felipe Kellermann
-- ================================================================

-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave.
-- Email é uma chave candidata que também determina a tupla inteira.
CREATE TABLE Usuario (
  id SERIAL PRIMARY KEY,
  Nome VARCHAR(255) NOT NULL,
  Email VARCHAR(255) NOT NULL UNIQUE,
  Senha VARCHAR(255) NOT NULL
);

-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave.
-- Nome é uma chave candidata que também determina a tupla inteira.
CREATE TABLE Categoria (
  id SERIAL PRIMARY KEY,
  Nome VARCHAR(255) NOT NULL UNIQUE
);

-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave.
-- Nome é uma chave candidata que também determina a tupla inteira.
CREATE TABLE TipoDeObra (
  id SERIAL PRIMARY KEY,
  Nome VARCHAR(255) NOT NULL UNIQUE
);

-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave.
-- Não há outras chaves determinantes na tupla.
CREATE TABLE Autor (
  id SERIAL PRIMARY KEY,
  Nome VARCHAR(255) NOT NULL,
  LocalNascimento VARCHAR(255),
  DataNascimento DATE,
  Biografia TEXT,
  Verificado BOOLEAN NOT NULL DEFAULT false,
  imagem VARCHAR(255)
  CONSTRAINT chk_Autor_DataNascimento CHECK (DataNascimento <= CURRENT_DATE)
);

-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave.
-- Nome é uma chave candidata que também determina a tupla inteira.
CREATE TABLE Produtoras (
  id SERIAL PRIMARY KEY,
  Nome VARCHAR(255) NOT NULL UNIQUE,
  Verificado BOOLEAN NOT NULL DEFAULT false
);

-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave e suas associações.
-- Informações inerentes aos objetos relacionados a obra estão armazenados em suas próprias tabelas.
CREATE TABLE Obras (
  id SERIAL PRIMARY KEY ,
  Nome VARCHAR(255) NOT NULL,
  Descricao TEXT,
  Publicacao DATE,
  Capa VARCHAR(255),
  ProdutoraID INTEGER REFERENCES Produtoras ON UPDATE CASCADE ON DELETE SET NULL,
  AutorID INTEGER NOT NULL REFERENCES Autor ON UPDATE CASCADE ON DELETE CASCADE,
  TipoDeObraID INTEGER NOT NULL REFERENCES TipoDeObra,
  CategoriaID INTEGER NOT NULL REFERENCES Categoria,
  Relacionado INTEGER REFERENCES Obras ON UPDATE CASCADE
);

-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave e suas associações.
-- Informações inerentes aos objetos relacionados a resenha estão armazenados em suas próprias tabelas.
CREATE TABLE Resenha (
  id SERIAL PRIMARY KEY,
  UsuarioID INTEGER NOT NULL REFERENCES Usuario ON UPDATE CASCADE ON DELETE CASCADE,
  Cabecalho TEXT NOT NULL,
  Resenha TEXT NOT NULL,
  Nota SMALLINT,
  Visualizacoes BIGINT NOT NULL DEFAULT 0,
  ObraID INTEGER NOT NULL REFERENCES Obras,
  DataPublicacao TIMESTAMP NOT NULL,
  DataUltimaEdicao TIMESTAMP,
  CONSTRAINT chk_Resenha_Nota CHECK (Nota >= 0 AND Nota <= 10),
  CONSTRAINT chk_Resenha_Visualizacoes CHECK (Visualizacoes >= 0)
);

-- Justificativa FNBC: Os únicos valores presentes são parte da chave primária e são o único determinante da relação.
-- Assim, não há outras dependências nessa tabela.
CREATE TABLE Coautoria (
  AutorID INTEGER NOT NULL REFERENCES Autor ON UPDATE CASCADE,
  ObraID INTEGER NOT NULL REFERENCES Obras ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY (AutorID, ObraID)
);


-- Justificativa FNBC: id determina funcionalmente todos os atributos não-chave e suas associações.
-- Informações inerentes aos objetos relacionados a ao comentário estão armazenados em suas próprias tabelas.
CREATE TABLE Comentarios (
  id SERIAL PRIMARY KEY,
  UsuarioID INTEGER NOT NULL REFERENCES Usuario ON UPDATE CASCADE ON DELETE CASCADE,
  ResenhaID INTEGER NOT NULL REFERENCES Resenha ON UPDATE CASCADE ON DELETE CASCADE,
  Comentario TEXT NOT NULL,
  ComentarioPai INTEGER REFERENCES Comentarios ON UPDATE CASCADE ON DELETE CASCADE,
  DataComentario TIMESTAMP NOT NULL,
  DataUltimaEdicao TIMESTAMP
);
