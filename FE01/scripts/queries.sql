-- [a] Quantos títulos possui a coleção?
select count(*) as num_titulos from titulo;

-- [b] Quantas músicas no total possui toda a coleção?
select count(*) as num_musicas from musica;

-- [c] Sem utilizar tabela autores, quantos autores existem na coleção?
select count(distinct ID_AUTOR) as num_autores 
from musica;

-- [d] Quantas editoras distintas existem na coleção?
select count(distinct ID_EDITORA) as num_editoras
from titulo;

-- [e] O autor “Max Changmin” é o principal autor de quantos título?
--[1]
select count(distinct ID_TITULO) as num_titulos
from TITULO
where ID_AUTOR = (select ID_AUTOR from AUTOR where NOME = 'Max Changmin');
--[2]
select count(distinct ID_TITULO) as num_titulos
from TITULO
INNER JOIN AUTOR ON TITULO.ID_AUTOR = AUTOR.ID_AUTOR where NOME = 'Max Changmin';

-- [f] No ano de 1970, quais foram os títulos comprados pelo utilizador?
SELECT TITULO.TITULO as titulo 
FROM TITULO 
WHERE TO_CHAR(TITULO.DATA_COMPRA, 'YYYY')='1970';

-- [g] Qual o autor do título que foi adquirido em “01-02-2010”, cujo preço foi de 12€?
--[1]
SELECT NOME as nome_autor
FROM AUTOR
where ID_AUTOR = (select titulo.ID_AUTOR
    from TITULO
    where TITULO.DATA_COMPRA = '01-02-2010' and TITULO.PRECO = 12
);
--[2]
select nome as nome_autor
from AUTOR
inner join Titulo 
on AUTOR.ID_AUTOR = TITULO.ID_AUTOR
where TITULO.DATA_COMPRA = '01-02-2010' and TITULO.PRECO = 12;

-- [h] Na alínea anterior indique nome da editora desse título?
--[1]
SELECT NOME as nome_editora
from EDITORA
where ID_EDITORA = (select titulo.ID_EDITORA
    from TITULO
    where TITULO.DATA_COMPRA = '01-02-2010' and TITULO.PRECO = 12
);
--[2]
SELECT NOME as nome_editora
from EDITORA
inner join Titulo
on EDITORA.ID_EDITORA = TITULO.ID_EDITORA
where TITULO.DATA_COMPRA = '01-02-2010' and TITULO.PRECO = 12;

-- [i] Quais as reviews (data e classificação) existentes para o título “oh whoa oh” ?
--[1]
SELECT review.DTA_REVIEW as data_review, review.CONTEUDO as review_conteudo
from review
where 
    review.ID_TITULO = (select TITULO.ID_TITULO
    from TITULO
    where TITULO.TITULO = 'oh whoa oh'
);
-- [2]
SELECT review.DTA_REVIEW as data_review, review.CONTEUDO as review_conteudo
from review
inner join TITULO
on TITULO.ID_TITULO=review.ID_TITULO and TITULO.TITULO= 'oh whoa oh';

-- [j] Quais as reviews (data e classificação) existentes para o título “pump”, ordenadas por data da mais antiga para a mais recente?
--[1]
SELECT review.DTA_REVIEW as data_review, review.CONTEUDO as review_conteudo
from review
where review.ID_TITULO=(SELECT TITULO.ID_TITULO
                        FROM TITULO
                        WHERE TITULO.TITULO='pump'
)
ORDER BY data_review asc;
--[2]
SELECT review.DTA_REVIEW as data_review, review.CONTEUDO as review_conteudo
from review
INNER JOIN TITULO
ON TITULO.ID_TITULO=REVIEW.ID_TITULO and TITULO.TITULO='pump'
ORDER BY data_review asc;

-- [k] Quais os diversos autores das músicas do título lançado a ‘04-04-1970’ com o preço de 20€?
SELECT AUTOR.NOME as NOMES_AUTORES
FROM AUTOR
WHERE AUTOR.ID_AUTOR IN (
    SELECT MUSICA.ID_AUTOR
    FROM MUSICA
    WHERE MUSICA.ID_TITULO = (
        SELECT TITULO.ID_TITULO
        FROM TITULO
        WHERE TITULO.DATA_COMPRA='04-04-1970' and TITULO.PRECO='20'
    )
);

-- [l] Qual foi o total de dinheiro investido em compras de título da editora ‘EMI’?
SELECT SUM(TITULO.PRECO) as investimento 
FROM TITULO
WHERE TITULO.ID_EDITORA=(
    SELECT EDITORA.ID_EDITORA
    FROM EDITORA
    WHERE EDITORA.NOME='EMI'
);

-- [m] Qual o título mais antigo cujo preço foi de 20€?
SELECT TITULO.TITULO 
FROM TITULO
WHERE TITULO.PRECO='20'
ORDER BY TITULO.DATA_COMPRA ASC
FETCH FIRST 1 ROW ONLY;

-- [n] Quantos “MP3” tem a coleção?
SELECT TITULO.TITULO
FROM TITULO
WHERE TITULO.ID_SUPORTE=(
    SELECT SUPORTE.ID_SUPORTE
    FROM SUPORTE
    WHERE SUPORTE.NOME='MP3'
);

-- [o] Destes mp3 quais são o títulos cujo género é: Pop Rock?
SELECT TITULO.TITULO
FROM TITULO
WHERE TITULO.ID_SUPORTE=(
    SELECT SUPORTE.ID_SUPORTE
    FROM SUPORTE
    WHERE SUPORTE.NOME='MP3'
) AND TITULO.ID_GENERO= (
    SELECT GENERO.ID_GENERO
    FROM GENERO
    WHERE GENERO.NOME='Pop Rock'
)
;

-- [p] Qual o custo total com “Blue-Ray”?
SELECT SUM(TITULO.PRECO) as custo_total
FROM TITULO
INNER JOIN SUPORTE 
ON SUPORTE.ID_SUPORTE=TITULO.ID_SUPORTE 
WHERE SUPORTE.NOME='Blue-Ray';

-- [q] Qual o custo total com “Blue-Ray” cuja editora é a EMI?
SELECT SUM(TITULO.PRECO) as custo_total
FROM TITULO
INNER JOIN SUPORTE 
ON SUPORTE.ID_SUPORTE=TITULO.ID_SUPORTE 
INNER JOIN EDITORA
ON TITULO.ID_EDITORA=EDITORA.ID_EDITORA 
WHERE SUPORTE.NOME='Blue-Ray' and EDITORA.NOME='EMI';

-- [r] Qual(ais) a(s) editora(s) na qual o colecionador investiu mais dinheiro e qual o valor do investimento?
SELECT EDITORA.NOME AS editora, SUM(TITULO.PRECO) AS valor_investido
FROM EDITORA
INNER JOIN TITULO ON TITULO.ID_EDITORA = EDITORA.ID_EDITORA
GROUP BY EDITORA.NOME
HAVING SUM(TITULO.PRECO) = (
    SELECT MAX(total_investido) 
    FROM (
        SELECT SUM(TITULO.PRECO) AS total_investido 
        FROM TITULO 
        GROUP BY ID_EDITORA
        )
    )
ORDER BY SUM(TITULO.PRECO) DESC;

-- [t] Qual a editora que possui mais títulos de “Heavy Metal” na coleção? Quantos titulo possui essa editora?
SELECT EDITORA.NOME AS editora, COUNT(TITULO.TITULO) AS num_titulos_heavy_metal
FROM TITULO
INNER JOIN GENERO ON GENERO.ID_GENERO = TITULO.ID_GENERO AND GENERO.NOME = 'Heavy Metal'
INNER JOIN EDITORA ON EDITORA.ID_EDITORA = TITULO.ID_EDITORA
GROUP BY EDITORA.NOME
ORDER BY COUNT(TITULO.TITULO) DESC
FETCH FIRST 1 ROW ONLY;

--[5] Insira uma coluna na tabela review denomidada nota. Preencha esta coluna tendo em conta a coluna conteúdo: obra prima – 5, excelente – 4, bom – 3, mau – 2, péssimo – 1. Mostre os comandos SQL que utilizou.
ALTER TABLE REVIEW ADD NOTA INT;

UPDATE REVIEW SET NOTA = 5 WHERE REVIEW.CONTEUDO = 'OBRA PRIMA';
UPDATE REVIEW SET NOTA = 4 WHERE REVIEW.CONTEUDO = 'EXCELENTE';
UPDATE REVIEW SET NOTA = 3 WHERE REVIEW.CONTEUDO = 'BOM';
UPDATE REVIEW SET NOTA = 2 WHERE REVIEW.CONTEUDO = 'MAU';
UPDATE REVIEW SET NOTA = 1 WHERE REVIEW.CONTEUDO = 'PÉSSIMO';

SELECT * FROM REVIEW;