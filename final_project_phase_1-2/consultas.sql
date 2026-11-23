-- ================================================================
-- Autores: André Schaidhauer Luckmann & Gabriel Felipe Kellermann
-- ================================================================

-- ================================================================
-- View - Resumo de Avaliações das Obras
-- Agrupa as métricas principais de cada obra do sistema. Cruza 
-- dados descritivos das obras com funções de agregações de suas
-- resenhas publicadas. Contém: nota média, número de resenhas e
-- número total de visualizações.
-- Comando SQL:
CREATE VIEW vw_resumo_avaliacoes_obras AS
SELECT
    o.id                  AS ObraID,
    o.Nome                AS TituloObra,
    a.Nome                AS AutorPrincipal,
    c.Nome                AS Categoria,
    t.Nome                AS TipoDeObra,
    COUNT(r.id)           AS TotalResenhas,
    ROUND(AVG(r.Nota), 2) AS NotaMedia,
    SUM(r.Visualizacoes)  AS TotalVisualizacoesResenhas
FROM Obras        o
JOIN Autor        a ON o.AutorID      = a.id
JOIN Categoria    c ON o.CategoriaID  = c.id
JOIN TipoDeObra   t ON o.TipoDeObraID = t.id
JOIN Resenha r ON o.id           = r.ObraID
GROUP BY o.id, o.Nome, a.Nome, c.Nome, t.Nome
-- ================================================================

-- ================================================================
-- Consulta 1 - Nota médias das obras de uma produtora verificada.
-- A consulta lista o nome de produtoras verificadas e nota média
-- de suas obras, considerando produtoras com mais de uma obra na
-- visão de Resumo de Avaliações das Obras.
-- Instâncias Necessárias:
INSERT INTO Usuario (id, Nome, Email, Senha) VALUES 
(10, 'Ana_C1', 'ana_c1@email.com', '123'), 
(11, 'Bruno_C1', 'bruno_c1@email.com', '123'), 
(12, 'Carla_C1', 'carla_c1@email.com', '123');

INSERT INTO Categoria (id, Nome) VALUES
(10, 'Ficção Científica_C1'), (11, 'Drama_C1')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES
(10, 'Filme_C1'), (11, 'Livro_C1')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES 
(10, 'Christopher Nolan_C1', true), 
(11, 'Steven Spielberg_C1', true);

INSERT INTO Produtoras (id, Nome, Verificado) VALUES
(10, 'Warner_C1', true),
(11, 'Universal_C1', true);

INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, ProdutoraID, AutorID, TipoDeObraID, CategoriaID) VALUES
(10, 'Interstellar_C1', 'Espaço', '2014-01-01', 'capa1.png', 10, 10, 10, 10),
(11, 'A Origem_C1', 'Sonhos', '2010-01-01', 'capa2.png', 10, 10, 10, 10),
(12, 'E.T._C1', 'Aliens', '1982-01-01', 'capa3.png', 11, 11, 10, 11);

INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(10, 10, 'Bom', 'Gostei', 9, 100, 10, CURRENT_TIMESTAMP),
(11, 10, 'Ótimo', 'Top', 10, 150, 11, CURRENT_TIMESTAMP),
(12, 11, 'Ok', 'Legal', 8, 50, 10, CURRENT_TIMESTAMP),
(13, 11, 'Triste', 'Chorei', 9, 200, 12, CURRENT_TIMESTAMP),
(14, 12, 'Clássico', 'Muito bom', 10, 300, 12, CURRENT_TIMESTAMP);

-- Justificativa:
-- A produtora Warner possui duas obras avaliadas, portanto, ela
-- passará no filtro e sua nota global será exibida. A produtora
-- Universal possui apenas uma obra registrada e avaliada, o que
-- forçará o seu descarte do resultado final.

-- Comando SQL:
SELECT
    p.Nome AS NomeProdutora,
    ROUND(AVG(v.NotaMedia), 2) AS NotaMediaGlobal
FROM Produtoras p
JOIN Obras o ON p.id = o.ProdutoraID
JOIN vw_resumo_avaliacoes_obras v ON o.id = v.ObraID
WHERE p.verificado = true
GROUP BY p.id, p.Nome
HAVING COUNT(o.id) > 1;
-- ================================================================

-- ================================================================
-- Consulta 2 - Métricas de Autores Verificados
-- A consulta lista o nome dos autores verificados, o número de
-- obras cadastradas e a nota média de todas as suas obras.
-- Instâncias Necessárias:
INSERT INTO Usuario (id, Nome, Email, Senha) VALUES
(20, 'Avaliador_C2', 'avaliador_c2@email.com', '123');

INSERT INTO Categoria (id, Nome) VALUES
(20, 'Ficção Científica_C2'), (21, 'Aventura_C2')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES 
(20, 'Livro_C2')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES 
(20, 'Isaac Asimov_C2', true),
(21, 'Arthur C. Clarke_C2', true),
(22, 'Autor Amador_C2', false);

INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) VALUES
(20, 'Eu, Robô_C2', 'Clássico', '1950-12-02', 'capa1.png', 20, 20, 20),
(21, 'Fundação_C2', 'Império Galáctico', '1951-05-01', 'capa2.png', 20, 20, 20),
(22, '2001_C2', 'Monolito', '1968-07-01', 'capa3.png', 21, 20, 20),
(23, 'Livro Ruim_C2', 'Desconhecido', '2020-01-01', 'capa4.png', 22, 20, 21);

INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(20, 20, 'Excelente', 'Muito bom', 10, 10, 20, CURRENT_TIMESTAMP),
(21, 20, 'Muito complexo', 'Bom', 8, 10, 21, CURRENT_TIMESTAMP),
(22, 20, 'Interessante', 'Ok', 7, 10, 22, CURRENT_TIMESTAMP),
(23, 20, 'Surpreendente', 'Gostei', 10, 10, 23, CURRENT_TIMESTAMP);

-- Justificativa:
-- O autor Isaac Asimov é verificado e tem 2 obras com notas 10 e 8.
-- assim sua nota média é 9 e aparece no resultado. Arthur C. Clarke
-- tem uma obra com nota 7, como é verificado vai pro resultado. Já
-- o Autor Amador não é verificado, e apesar de ter nota 10, não vai
-- pro resultado.

-- Comando SQL:
SELECT
    a.Nome AS Autor,
    COUNT(v.ObraID) AS TotalObras,
    ROUND(AVG(v.NotaMedia), 2) AS NotaMediaGeral
FROM Autor a
JOIN Obras o ON a.id = o.AutorID
JOIN vw_resumo_avaliacoes_obras v ON o.id = v.ObraID
WHERE a.verificado = true
GROUP BY a.id, a.Nome
-- ================================================================

-- ================================================================
-- Consulta 3 - Resenhas mais visualizadas por categoria.
-- A consulta retorna uma lista com a categoria da obra, título da
-- obra, autor da resenha, cabeçalho, tipo de obra e a quantidade
-- de visualizações da resenha com mais visualizações em cada
-- categoria de obra existente no sistema.

-- Instâncias Necessárias:
INSERT INTO Usuario (id, Nome, Email, Senha) VALUES 
(30, 'Alice_C3', 'alice_c3@email.com', '123'), 
(31, 'Beto_C3', 'beto_c3@email.com', '123');

INSERT INTO Categoria (id, Nome) VALUES
(30, 'Ação_C3'), (31, 'Comédia_C3')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES
(30, 'Filme_C3')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES (30, 'Diretor X_C3', true);
INSERT INTO Produtoras (id, Nome, Verificado) VALUES (30, 'Estúdio Y_C3', true);

INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, ProdutoraID, AutorID, TipoDeObraID, CategoriaID) VALUES
(30, 'Duro de Matar_C3', 'Tiros', '1988-01-01', 'capa1.png', 30, 30, 30, 30),
(31, 'Missão Impossível_C3', 'Espiões', '1996-01-01', 'capa2.png', 30, 30, 30, 30),
(32, 'Se Beber Não Case_C3', 'Risadas', '2009-01-01', 'capa3.png', 30, 30, 30, 31);

-- Categoria: Ação
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(30, 30, 'Muito bom', 'Legal', 9, 50, 30, CURRENT_TIMESTAMP),
(31, 31, 'Clássico!', 'Incrível', 10, 500, 30, CURRENT_TIMESTAMP),
(32, 30, 'Ação pura', 'Top', 8, 300, 31, CURRENT_TIMESTAMP);

-- Categoria: Comédia
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(33, 30, 'Hilário', 'Ri muito', 10, 1000, 32, CURRENT_TIMESTAMP),
(34, 31, 'Sem graça', 'Meh', 4, 20, 32, CURRENT_TIMESTAMP);

-- Justificativa: Há duas categorias nas instâncias, a avaliação 
-- isolada de cada grupo se dá pelo uso da subconsulta relacionando
-- a categoria interna (de r2) com a externa (da view v).

-- Comando SQL:
SELECT 
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
    -- Busca o valor máximo de visualizações para a categoria atual (v).
    SELECT MAX(r2.Visualizacoes)
    FROM Resenha r2
    JOIN vw_resumo_avaliacoes_obras v2 ON r2.ObraID = v2.ObraID
    WHERE v2.Categoria = v.Categoria
)
ORDER BY r.Visualizacoes DESC;
-- ================================================================

-- ================================================================
-- Consulta 4 - Perfil de engajamento dos usuários.
-- A consulta retorna o nome dos usuários, quantidade total de co-
-- mentários feitos por eles e a média das notas das obras em que
-- eles interagiram. Válido para usuários que tenham mais de um
-- comentário. O Objetivo é ter noção de qual tipo de avaliação mais
-- incentiva a interação de usuários. 

-- Instâncias Necessárias:
INSERT INTO Usuario (id, Nome, Email, Senha) VALUES 
(40, 'Lucas_C4', 'lucas_c4@email.com', '123'),
(41, 'Mariana_C4', 'mari_c4@email.com', '123'),
(42, 'João_C4', 'joao_c4@email.com', '123');

INSERT INTO Categoria (id, Nome) VALUES
(40, 'Suspense_C4')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES
(40, 'Série_C4')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES
(40, 'David Fincher_C4', true),
(41, 'Ben Stiller_C4', true);

INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) VALUES
(40, 'Mindhunter_C4', 'FBI e Psicologia', '2017-01-01', 'capa1.png', 40, 40, 40),
(41, 'Severance_C4', 'Misterio no trabalho', '2022-01-01', 'capa2.png', 41, 40, 40);

INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(40, 42, 'Obra Prima', 'Muito densa', 10, 50, 40, CURRENT_TIMESTAMP),
(41, 42, 'Confuso', 'Não entendi o final', 6, 20, 41, CURRENT_TIMESTAMP);

-- Lucas faz 3 comentários (2 em Mindhunter, 1 em Severance)
INSERT INTO Comentarios (id, UsuarioID, ResenhaID, Comentario, DataComentario) VALUES
(40, 40, 40, 'Concordo plenamente!', CURRENT_TIMESTAMP),
(41, 40, 40, 'O episódio 4 é o melhor.', CURRENT_TIMESTAMP),
(42, 40, 41, 'Assista de novo que você entende.', CURRENT_TIMESTAMP);

-- Mariana faz 2 comentários (Ambos em Severance)
INSERT INTO Comentarios (id, UsuarioID, ResenhaID, Comentario, DataComentario) VALUES
(43, 41, 41, 'Também achei o final estranho.', CURRENT_TIMESTAMP),
(44, 41, 41, 'Mas a fotografia é linda.', CURRENT_TIMESTAMP);

-- João faz apenas 1 comentário (Em Mindhunter)
INSERT INTO Comentarios (id, UsuarioID, ResenhaID, Comentario, DataComentario) VALUES
(45, 42, 40, 'Obrigado por ler minha resenha.', CURRENT_TIMESTAMP);

-- Justificativa:
-- Lucas faz 3 comentários, 2 em resenhas de nota 10 e 1 em resenha de nota 6.
-- Assim ele tende a comentar em obras com nota ~=8,67 [(10 + 10 + 6) / 3].
-- Mariana tem 2 comentários: Colocou 2 comentários em uma resenha de nota 6.
-- Assim ela tende a comentar em obras com nota ~=6,0 [(6 + 6) / 2].
-- João fez somente um comentário, logo não aparece no resultado.

-- Comando SQL:
SELECT
    u.Nome AS Usuario,
    COUNT(c.id) AS TotalComentarios,
    ROUND(AVG(v.NotaMedia), 2) AS MediaNotaObrasComentadas
FROM Usuario u
JOIN Comentarios c ON u.id = c.UsuarioID
JOIN Resenha r ON c.ResenhaID = r.id
JOIN vw_resumo_avaliacoes_obras v ON r.ObraID = v.ObraID
GROUP BY u.id, u.Nome
HAVING COUNT(c.id) > 1
ORDER BY TotalComentarios DESC;
-- ================================================================

-- ================================================================
-- Consulta 5 - Volume de autorias e versatilidade de autor.
-- A consulta retorna o nome dos autores ordenados pela quantidade
-- de obras em que estão envolvidos (autor ou coautor), também
-- exibe a quantidade de tipos de obras distintos (Livro, Série, Filme)
-- em que um autor possui participação. Ordena o resultado do autor
-- com mais participações para o menor.

-- Instâncias Necessárias:
INSERT INTO Categoria (id, Nome) VALUES
(50, 'Fantasia_C5'), (51, 'Ficção Científica_C5')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES
(50, 'Livro_C5'), (51, 'Filme_C5'), (52, 'Música_C5')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES 
(50, 'Autor Multi-Tipos_C5', true), 
(51, 'Autor Focado_C5', true), 
(52, 'Mestre das Coautorias_C5', true);

-- Obra 1: Livro de Fantasia (Autor Multi-Tipos como principal)
INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) 
VALUES (50, 'O Hobbit_C5', 'Aventura', '1937-09-21', 'capa1.png', 50, 50, 50);

-- Obra 2: Filme de Ficção Científica (Autor Focado como principal)
INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) 
VALUES (51, 'Duna_C5', 'Planeta deserto', '2021-10-22', 'capa2.png', 51, 51, 51);

-- Obra 3: Música de Fantasia (Autor Focado como principal)
INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) 
VALUES (52, 'The Bard Song_C5', 'Taverna', '1992-01-01', 'capa3.png', 51, 52, 50);

-- Obra 4: Livro de Ficção Científica (Autor Focado como principal)
INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID)
VALUES (53, 'Neuromancer_C5', 'Cyberpunk', '1984-07-01', 'capa4.png', 51, 50, 51);

-- Autor Multi-Tipos atua como coautor no Filme 2 e na Música 3
INSERT INTO Coautoria (AutorID, ObraID) VALUES (50, 51), (50, 52);

-- Mestre das Coautorias atua como coautor nos Livros 1 e 4
INSERT INTO Coautoria (AutorID, ObraID) VALUES (52, 50), (52, 53);

-- Justificativa: 
-- O Autor focado, não possui nenhuma coautoria mas atua como principal em
-- 3 obras diferentes. O Autor Multi-Tipos, é autor principal de um livro,
-- e co-autor de filme e música, o que resulta em 3 participações em 3 tipos
-- distintos. O Mestre das Coautorias não é autor principal de nada, mas é 
-- coautor de 2 livros (2 autorias) no mesmo tipo de obra.
-- Comando SQL:
SELECT
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
ORDER BY TotalAutorias DESC, TiposDeObrasDistintas DESC;
-- ================================================================

-- ================================================================
-- Consulta 6 - Usuários que fizeram resenhas para todas as obras
-- de uma categoria.
-- A consulta retorna o nome dos usuários que publicaram resenhas
-- para todas as obras cadastradas em uma determinada categoria, além
-- da própria categoria, do número total de resenhas que aquele 
-- usuário fez na categoria.

-- Instâncias Necessárias:
-- C3. Instâncias Necessárias:
INSERT INTO Usuario (id, Nome, Email, Senha) VALUES 
(60, 'Fã de Anime_C6', 'anime_c6@email.com', '123'), 
(61, 'Leitor de Terror_C6', 'terror_c6@email.com', '123'), 
(62, 'Usuário Casual_C6', 'casual_c6@email.com', '123');

INSERT INTO Categoria (id, Nome) VALUES 
(60, 'Cyberpunk_C6'), 
(61, 'Terror_C6'),
(62, 'Medieval_C6')
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES 
(60, 'Anime_C6'), (61, 'Livro_C6') ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES 
(60, 'Katsuhiro Otomo_C6', true),
(61, 'Stephen King_C6', true);

-- Inserindo 2 obras de Cyberpunk e 2 obras de Terror (Nenhuma Medieval)
INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) VALUES
(60, 'Akira_C6', 'Neo Toquio', '1988-07-16', 'akira.png', 60, 60, 60),
(61, 'Ghost in the Shell_C6', 'Ciborgues', '1995-11-18', 'gits.png', 60, 60, 60),
(62, 'O Iluminado_C6', 'Hotel', '1977-01-28', 'iluminado.png', 61, 61, 61),
(63, 'It: A Coisa_C6', 'Palhaço', '1986-09-15', 'it.png', 61, 61, 61);

-- Fã de Anime resenha TODAS as 2 obras de Cyberpunk, e 1 de Terror
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(60, 60, 'Obra Prima', 'Excelente', 10, 100, 60, CURRENT_TIMESTAMP),
(61, 60, 'Filosófico', 'Profundo', 9, 100, 61, CURRENT_TIMESTAMP),
(62, 60, 'Assustador', 'Muito bom', 8, 50, 62, CURRENT_TIMESTAMP);

-- Leitor de Terror resenha TODAS as 2 obras de Terror
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(63, 61, 'Clássico', 'Medo', 10, 80, 62, CURRENT_TIMESTAMP),
(64, 61, 'Longo', 'Bom livro', 9, 90, 63, CURRENT_TIMESTAMP);

-- Usuário Casual resenha apenas 1 de Cyberpunk e 1 de Terror (não completa nenhuma)
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(65, 62, 'Legal', 'Gostei', 8, 20, 60, CURRENT_TIMESTAMP),
(66, 62, 'Ok', 'Mediano', 7, 15, 62, CURRENT_TIMESTAMP);

-- Justificativa:
-- A consulta é formulada avaliando o resultado vazio da diferença
-- entre o conjunto total de obras de uma categoria e o conjunto to-
-- tal de obras dessa categoria e o conjunto de obras que o usuário
-- efetivamente resenhou. 

-- Comando SQL:
SELECT DISTINCT
    u.Nome AS NomeUsuario,
    c.Nome AS Categoria,
    COUNT(r1.id) AS QtdResenhasDoUsuario
FROM Usuario u
JOIN Resenha r1 ON u.id = r1.UsuarioID
JOIN Obras o1   ON r1.ObraID = o1.id
JOIN Categoria c ON o1.CategoriaID = c.id
-- Verificar se não existe nenhuma obra...
WHERE NOT EXISTS (
    SELECT *
    FROM Obras o2
    -- Que pertença a categoria atual...
    WHERE o2.CategoriaID = c.id
      AND o2.id NOT IN (
          -- ...e que esteja ausente no conjunto de obras que o usuario resenhou,
		  -- ou seja, ele fez resenhas de todas as obras dessa categoria.
          SELECT r2.ObraID
          FROM Resenha r2
          WHERE r2.UsuarioID = u.id
      )
) GROUP BY u.id, u.Nome, c.id, c.Nome;

-- ================================================================

-- ================================================================
-- Consulta 7 - Autores com obras em múltiplas categorias
-- A consulta retorna o nome dos autores que possuem obras de sua 
-- autoria cadastradas em mais de uma categoria diferente no sistema.
-- Além disso, retorna a quantidade de categorias distintas em que o ator atua.

-- Instâncias Necessárias:
INSERT INTO Categoria (id, Nome) VALUES 
(70, 'Romance_C7'), (71, 'Conto_C7') 
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES 
(70, 'Literatura_C7') 
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES 
(70, 'Machado de Assis_C7', true), 
(71, 'J.R.R. Tolkien_C7', true);

INSERT INTO Obras (id, Nome, AutorID, TipoDeObraID, CategoriaID) VALUES 
(70, 'Dom Casmurro_C7', 70, 70, 70),        -- Machado: Romance
(71, 'O Alienista_C7', 70, 70, 71),         -- Machado: Conto
(72, 'O Hobbit_C7', 71, 70, 70),            -- Tolkien: Romance
(73, 'O Senhor dos Anéis_C7', 71, 70, 70);  -- Tolkien: Romance

-- Justificativa:
-- Machado de Assis tem obras de Romance e Conto, logo, deve passar
-- no filtro HAVING > 1. Tolkien possui duas obras cadastradas, mas
-- todas são de romance, sendo barrado pelo COUNT(DISTINCT).

-- Comando SQL:
SELECT
    a.Nome AS NomeAutor,
    COUNT(DISTINCT c.id) AS QtdCategoriasDistintas
FROM Autor a
JOIN Obras o ON a.id = o.AutorID
JOIN Categoria c ON o.CategoriaID = c.id
GROUP BY a.id, a.Nome
HAVING COUNT(DISTINCT c.id) > 1
-- ================================================================

-- ================================================================
-- Consulta 8 - usuários interagindo em suas próprias resenhas.
-- Retorna o nome do usuário, o título da obra avaliada e o texto de
-- um comentário que o usuário postou numa resenha que ele mesmo es-
-- creveu (auto-engajamento).

-- Instâncias Necessárias:
INSERT INTO Usuario (id, Nome, Email, Senha) VALUES 
(80, 'Vaidoso_C8', 'vai_c8@email.com', '123'), 
(81, 'Critico_C8', 'crit_c8@email.com', '123');

INSERT INTO Categoria (id, Nome) VALUES (80, 'Rock_C8') ON CONFLICT DO NOTHING;
INSERT INTO TipoDeObra (id, Nome) VALUES (80, 'Música_C8') ON CONFLICT DO NOTHING;
INSERT INTO Autor (id, Nome, Verificado) VALUES (80, 'Jack Black_C8', true);

INSERT INTO Obras (id, Nome, AutorID, TipoDeObraID, CategoriaID) VALUES 
(80, 'Obra Analisada_C8', 80, 80, 80);

-- Resenha feita pelo usuário 'Vaidoso'
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(80, 80, 'Minha Resenha', 'Texto incrível', 10, 50, 80, CURRENT_TIMESTAMP);

-- Comentários na resenha publicada
INSERT INTO Comentarios (id, UsuarioID, ResenhaID, Comentario, DataComentario) VALUES
(80, 80, 80, 'Concordo comigo mesmo!', CURRENT_TIMESTAMP), -- Auto-engajamento
(81, 81, 80, 'Eu discordo de você.', CURRENT_TIMESTAMP);   -- Terceiros

-- Justificativa:
-- A A claúsula WHERE vai comparar o 'UsuarioID' da tabela 'Comentarios'
-- com o 'UsuarioID' da tabela de 'Resenha'. Logo, conseguimos cruzar
-- diretamente usuários que comentam em suas próprias resenhas e filtrar
-- comentários postados por terceiros na resenha do resultado.

-- Comando SQL:
SELECT DISTINCT
    u.Nome AS AutorResenhaEComentario,
    o.Nome AS TituloDaObra,
    c.Comentario AS TextoDoComentario
FROM Usuario u
JOIN Comentarios c ON u.id = c.UsuarioID
JOIN Resenha r ON c.ResenhaID = r.id
JOIN Obras o ON r.ObraID = o.id
WHERE c.UsuarioID = r.UsuarioID

-- ================================================================

-- ================================================================
-- Consulta 9 - Obras mais bem avaliadas por Tipo e Categoria
-- A consulta retorna o titulo, tipo de obra, a categoria, o título,
-- data de publicação e nota média consolidada das obras que possuem a 
-- maior nota média dentro do par TipoDeObra e Categoria.

-- Instâncias Necessárias:
INSERT INTO Categoria (id, Nome) VALUES 
(90, 'Ação_C9'), (91, 'Romance_C9') 
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES 
(90, 'Filme_C9'), (91, 'Curta-metragem_C9') 
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES
(90, 'James Cameron_C9', true);

INSERT INTO Usuario (id, Nome, Email, Senha) VALUES
(90, 'Crítico_C9', 'c9@e.com', '123');

-- Obras inseridas (Filmes reais):
-- 90: Filme de Ação (Nota 8) - Perdedor
-- 91: Filme de Ação (Nota 10) - Vencedor do grupo Filme/Ação
-- 92: Filme de Romance (Nota 7) - Vencedor do grupo Filme/Romance
-- 93: Curta de Ação (Nota 9) - Vencedor do grupo Curta/Ação
INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) VALUES 
(90, 'True Lies_C9', 'Espionagem', '1994-07-15', 'truelies.png', 90, 90, 90),
(91, 'O Exterminador do Futuro 2_C9', 'Ciborgue', '1991-07-03', 't2.png', 90, 90, 90),
(92, 'Titanic_C9', 'Navio', '1997-12-19', 'titanic.png', 90, 90, 91),
(93, 'T2 3-D: Battle Across Time_C9', 'Parque', '1996-01-01', 't23d.png', 90, 91, 90);

-- Resenhas para gerar a média
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(90, 90, 'Bom', 'Divertido', 8, 10, 90, CURRENT_TIMESTAMP),
(91, 90, 'Obra-prima', 'Perfeito', 10, 10, 91, CURRENT_TIMESTAMP),
(92, 90, 'Triste', 'Chorei', 7, 10, 92, CURRENT_TIMESTAMP),
(93, 90, 'Legal', 'Curto', 9, 10, 93, CURRENT_TIMESTAMP);

-- Justificativa:
-- O pareamento de TipoDeObra e Categoria será feito através de uma
-- subconsulta correlacionada. O filtro do MAX() é aplicado somente
-- para obras dentro do par TipoDeObra + Categoria.
-- Comando SQL:
SELECT
    v.TituloObra,
    v.NotaMedia,
    v.TipoDeObra,
    v.Categoria,
    o.Publicacao
FROM vw_resumo_avaliacoes_obras v
JOIN Obras o ON v.ObraID = o.id
JOIN Autor a ON o.AutorID = a.id
WHERE v.NotaMedia = (
    -- Busca a nota máxima isolada para o tipo e categoria da linha 
    -- de 'v' atual sendo avalida.
    SELECT MAX (v2.NotaMedia)
    FROM vw_resumo_avaliacoes_obras v2
    WHERE v2.TipoDeObra = v.TipodeObra
        AND v2.Categoria = v.Categoria
) ORDER BY v.TipoDeObra, v.Categoria;
-- ================================================================

-- ================================================================
-- Consulta 10 - Ranking das Obras Filhas de uma Obra
-- A consulta retorna o nome de uma obra principal (ex: álbum), o nome de
-- suas obras derivadas (ex: músicas do álbum) e a nota média conso-
-- lidada de cada uma dessas obras filhas. O resultado é ordenado da 
-- obra filha mais bem avaliada para a menos bem avaliada. Neste caso
-- utilizamos o nome da obra principal como sendo 'The Dark Side of the Moon'
-- como exemplo.

-- Instâncias Necessárias:
INSERT INTO Usuario (id, Nome, Email, Senha) VALUES 
(100, 'Ouvinte_C10', 'ouvinte_c10@email.com', '123') 
ON CONFLICT DO NOTHING;

INSERT INTO Categoria (id, Nome) VALUES 
(100, 'Rock_C10') 
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO TipoDeObra (id, Nome) VALUES 
(100, 'Álbum_C10'), (101, 'Música_C10') 
ON CONFLICT (Nome) DO NOTHING;

INSERT INTO Autor (id, Nome, Verificado) VALUES 
(100, 'Pink Floyd_C10', true);

-- Inserindo a Obra Principal
INSERT INTO Obras (id, Nome, Descricao, Publicacao, Capa, AutorID, TipoDeObraID, CategoriaID) VALUES 
(100, 'The Dark Side of the Moon_C10', 'Álbum icônico', '1973-03-01', 'darkside.png', 100, 100, 100);

-- Inserindo as Obras Derivadas (As Músicas Filhas apontando para o Álbum Pai)
INSERT INTO Obras (id, Nome, AutorID, TipoDeObraID, CategoriaID, Relacionado) VALUES 
(101, 'Time_C10', 100, 101, 100, 100),
(102, 'Money_C10', 100, 101, 100, 100),
(103, 'Us and Them_C10', 100, 101, 100, 100);

-- Inserindo Resenhas nas Músicas para gerar as médias
INSERT INTO Resenha (id, UsuarioID, Cabecalho, Resenha, Nota, Visualizacoes, ObraID, DataPublicacao) VALUES
(100, 100, 'Obra prima', 'Incrível', 10, 10, 101, CURRENT_TIMESTAMP), -- Time: Nota 10
(101, 100, 'Clássico', 'Muito bom', 8, 10, 102, CURRENT_TIMESTAMP),   -- Money: Nota 8
(102, 100, 'Emocionante', 'Profundo', 9, 10, 103, CURRENT_TIMESTAMP); -- Us and Them: Nota 9

-- Justificativa:
-- Uso do auto-relacionamento na tabela Obras, identificando dependências
-- hierárquicas. Ao cruzar com a visão dea valiações, podemos usar o ID
-- da obra filha para buscar a NotaMedia agregada e aplicar a ordenação.

-- Comando SQL:
SELECT
    obra_pai.Nome AS Album,
    obra_filha.Nome AS Musica,
    v.NotaMedia
FROM Obras obra_filha
JOIN Obras obra_pai ON obra_filha.Relacionado = obra_pai.id
JOIN vw_resumo_avaliacoes_obras v ON obra_filha.id = v.ObraID
WHERE obra_pai.Nome = 'The Dark Side of the Moon_C10'
ORDER BY v.NotaMedia DESC;
-- ================================================================
