--Exemplos de funções e triggers em PostgreSQL
--Leonardo Andrade Ribeiro
--Instituto de Informática
--Universidade Federal de Goiás

----------------------------Exemplos básicos de funções e triggers--------------------------------------
--Examplo de função que calcula o somatório dos k maiores salários

CREATE OR REPLACE FUNCTION tok_sum(k int)
RETURNS float AS $$
DECLARE func RECORD;
DECLARE out float;
DECLARE count int;
BEGIN
out := 0;
count := 0;
FOR func IN SELECT salario FROM funcionario order by salario desc LOOP
out := out + func.salario;
count := count + 1;
IF count = k THEN exit;
END IF;
END LOOP;
RETURN out;
END;
$$ LANGUAGE plpgsql;

--SELECT salario FROM funcionario order by salario desc
--SELECT * FROM funcionario

--select tok_sum(2)
-----------------Exemplo de trigger para atualização de visão--------------------
--select * from funcionario
--select * from dependente

create view func_dep as
(select f.cpf, f.nome as func_nome, d.nome as dep_nome, d.gen, d.data_nasc, d.relacionamento
 from funcionario f join dependente d on f.cpf = d.cpf)

--select * from func_dep

CREATE OR REPLACE FUNCTION removeDep()
RETURNS TRIGGER AS $removeDep$
BEGIN
delete from dependente where cpf = OLD.cpf and nome = OLD.dep_nome;
RETURN NULL;
END;
$removeDep$ LANGUAGE plpgsql;

CREATE TRIGGER deleteFuncDep
    INSTEAD OF DELETE ON func_dep
    FOR EACH ROW
    EXECUTE PROCEDURE removeDep();

delete from func_dep where func_nome = 'Franklin' and dep_nome = 'Theodore';



----------------------------Exemplos avançados de funções e triggers--------------------------------------
--Exemplo de função para calculo de similaridade textual baseada em q-grams

CREATE OR REPLACE FUNCTION tokensimfunc(
    character varying,
    character varying,
    integer,
    integer)
  RETURNS DOUBLE PRECISION AS
$BODY$
DECLARE
s1 varchar := $1;
s2 varchar := $2;
q integer := $3;
simFunc integer := $4;
s1_card integer := character_length(s1) + q - 1;
s2_card integer := character_length(s2) + q - 1;
array_s1 varchar[];
array_s2 varchar[];
array_over varchar[];
overlap integer;
sim float;
BEGIN
FOR i in 1..q - 1 LOOP
s1 := '*' || s1 || '*';
s2 := '*' || s2 || '*';
END LOOP;
FOR i in 1..s1_card LOOP
array_s1[i] := substring(s1, i, q);
END LOOP;
FOR i in 1..s2_card LOOP
array_s2[i] := substring(s2, i, q);
END LOOP;
array_over := (select array(select unnest(array_s1) intersect all select unnest(array_s2)));
overlap := array_length(array_over,1);
IF simFunc = 1 THEN sim := overlap::float/(s1_card + s2_card - overlap);
ELSIF simFunc = 2 THEN sim := (2::float * overlap)/(s1_card + s2_card);
ELSIF simFunc = 3 THEN sim := overlap::float/sqrt(s1_card * s2_card);
ELSE sim := overlap::float/(s1_card + s2_card - overlap);
END IF;
RETURN sim;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 1;
ALTER FUNCTION tokensimfunc(character varying, character varying, integer, integer)
  OWNER TO postgres;


---select tokensimfunc('sistemas','sitemas',2,2);


--Exemplo de triggers
--tabela com atributo textual
create table r (nome varchar(64));
--tabela de frequência de q-grams
create table tokCount (tok char(3), freq int);

--Função que mantém a tabela de frequência de q-grams
CREATE OR REPLACE FUNCTION updateTokCount() 
RETURNS TRIGGER AS $updateTokCount$
DECLARE
s1 varchar := NEW.nome;
token varchar;
s1_card integer := character_length(s1) + 2;
BEGIN
FOR i in 1..2 LOOP
s1 := '*' || s1 || '*';
END LOOP;
FOR i in 1..s1_card LOOP
token := substring(s1, i, 3);
IF NOT EXISTS (select * from tokCount where tok = token) then insert into tokCount values (token, 1);
ELSE update tokCount set freq = freq + 1 where tok = token;
END IF;  
END LOOP;
RETURN NULL;
END;
$updateTokCount$ LANGUAGE plpgsql;

--trigger que invoca a função para manutenção da tabela de q-grams. 
CREATE TRIGGER tokFreq
    AFTER INSERT ON r
    FOR EACH ROW
    WHEN (character_length(NEW.nome) > 3)
    EXECUTE PROCEDURE updateTokCount();


--delete from r;
--delete from tokCount
--insert into r values ('abcd');
--select * from tokCount;






  