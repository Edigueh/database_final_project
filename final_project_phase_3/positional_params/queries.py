from typing import LiteralString

QUERIES: dict[int, LiteralString] = {
    1: """SELECT
    p.Nome AS NomeProdutora,
    ROUND(AVG(v.NotaMedia), 2) AS NotaMediaGlobal
FROM Produtoras p
JOIN Obras o ON p.id = o.ProdutoraID
JOIN vw_resumo_avaliacoes_obras v ON o.id = v.ObraID
WHERE p.verificado = true
GROUP BY p.id, p.Nome
HAVING COUNT(o.id) > 1;""",
    2: """SELECT
    a.Nome AS Autor,
    COUNT(v.ObraID) AS TotalObras,
    ROUND(AVG(v.NotaMedia), 2) AS NotaMediaGeral
FROM Autor a
JOIN Obras o ON a.id = o.AutorID
JOIN vw_resumo_avaliacoes_obras v ON o.id = v.ObraID
WHERE a.verificado = true
GROUP BY a.id, a.Nome;""",
    3: """SELECT
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
    4: """SELECT
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
    5: """SELECT
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
    6: """SELECT DISTINCT
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
    7: """SELECT
    a.Nome AS NomeAutor,
    COUNT(DISTINCT c.id) AS QtdCategoriasDistintas
FROM Autor a
JOIN Obras o ON a.id = o.AutorID
JOIN Categoria c ON o.CategoriaID = c.id
GROUP BY a.id, a.Nome
HAVING COUNT(DISTINCT c.id) > 1;""",
    8: """SELECT DISTINCT
    u.Nome AS AutorResenhaEComentario,
    o.Nome AS TituloDaObra,
    c.Comentario AS TextoDoComentario
FROM Usuario u
JOIN Comentarios c ON u.id = c.UsuarioID
JOIN Resenha r ON c.ResenhaID = r.id
JOIN Obras o ON r.ObraID = o.id
WHERE c.UsuarioID = r.UsuarioID;""",
    9: """SELECT
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
    10: """SELECT
    obra_pai.Nome AS Album,
    obra_filha.Nome AS Musica,
    v.NotaMedia
FROM Obras obra_filha
JOIN Obras obra_pai ON obra_filha.Relacionado = obra_pai.id
JOIN vw_resumo_avaliacoes_obras v ON obra_filha.id = v.ObraID
WHERE obra_pai.Nome = %s
ORDER BY v.NotaMedia DESC;""",
}
