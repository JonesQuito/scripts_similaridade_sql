-- cria uma tabela de tokens para uma tabela informa
CREATE OR REPLACE FUNCTION TTokensGeneric(text) returns text as $$
	DECLARE
		tableName ALIAS FOR $1;
   BEGIN
       tableName := 'TTokensOf' || upper(substring(tableName, 1, 1)) || SUBSTRING(tableName, 2, character_length(tableName));
       EXECUTE ' create table ' || tableName || '(tid varchar(11), token varchar(5));';
       RETURN tableName;
   END;
$$ LANGUAGE plpgsql;
--############################################


--##Cria uma tabela de tokens para os tokens de um atributo específico de uma tabela informada##
CREATE OR REPLACE FUNCTION createTTokensTo(TEXT, TEXT) RETURNS TEXT AS $$
    DECLARE
        tableName ALIAS FOR $1;
        columnName ALIAS FOR $2;
        TTokensName varchar(60);
    BEGIN
        TTokensName := 'ttkto' || columnName || 'from' || tableName;
        EXECUTE 'CREATE TABLE ' || TTokensName || '(tid varchar(15), token varchar(5));'; 
        RETURN TTokensName;
    END;
$$ LANGUAGE plpgsql;
--############################################


--##Cria uma tabela de tokens para os tokens de um atributo específico de uma tabela informada##
CREATE OR REPLACE FUNCTION createTTokensTo2(TEXT, TEXT) RETURNS TEXT AS $$
    DECLARE
        tableName ALIAS FOR $1;
        columnName ALIAS FOR $2;
        TTokensName varchar(60);
        tipoCampoChave text; --linhas acrescidas
    BEGIN
    	  tipoCampoChave := (SELECT tipo from field_primary_key(tableName) limit 1); --linhas acrescidas
        TTokensName := 'ttkto' || columnName || 'from' || tableName;
        if tipoCampoChave is null then
        	EXECUTE 'CREATE TABLE ' || TTokensName || '(tid varchar(15), token varchar(5));'; 
         else
            EXECUTE 'CREATE TABLE ' || TTokensName || '(tid '||tipoCampoChave||', token varchar(5));'; 
        end if;
        RETURN TTokensName;
    END;
$$ LANGUAGE plpgsql;
--############################################


-- Cria a função insertTTokens() que será executada quando um novo registro for inserido na tabela de funcionarios
-- esta função cria um conjunto de tokens apartir do nome do funcionario e insere na tabela de tokens
CREATE OR REPLACE FUNCTION insertTTokens() RETURNS TRIGGER as $insertTTokens$
DECLARE
	s1 varchar;
	s2 varchar;
	q integer := 2;
	s1_card integer;
	token varchar;
BEGIN
    s1 := NEW.nome;
    s2 := NEW.cpf;
    s1_card := character_length(s1) + q - 1;
    FOR i in 1..q-1 LOOP
    	s1 := '*' || s1 || '*';
    END LOOP;
    FOR i IN 1..s1_card LOOP
        token := SUBSTRING(s1, i, q);
        insert into TTokens values(s2, token);
    END LOOP;
    RETURN NULL;
END;
$insertTTokens$ LANGUAGE plpgsql;
--############################################


-- Trigger responsável por invocar a função insertTTokens atualizando assim a tabela TTokens
-- drop trigger updateTTokens on funcionario
create trigger updateTTokens after insert on funcionario FOR EACH ROW execute procedure insertTTokens()


-- Insere um registro para testar a trigger e a function
insert into funcionario (nome, inicial, sobrenome, cpf, data_nasc, endereco, gen, salario, super_cpf, dno)
	values ('Jhones', 'J', 'Kito', '955310173', '28/08/1987', 'Rua Nonato Mota', 'M', '2000', '888665555', 5)
delete from funcionario where cpf='955310173'
--############################################

CREATE OR REPLACE FUNCTION insertTTokens2(text, text, integer, text) RETURNS void as $$
DECLARE
	tid alias for $1; 
	texto alias for $2;
   q alias for $3;
   ttokens alias for $4;
	card integer;
	token varchar;
BEGIN
    card := character_length(texto) + q - 1;
    FOR i in 1..q-1 LOOP
    	texto := '*' || texto || '*';
    END LOOP;
    FOR i IN 1..card LOOP
        token := SUBSTRING(texto, i, q);
        EXECUTE format('INSERT INTO ' ||ttokens|| '(tid, token) VALUES($1,$2);') using tid, token;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;
--############################################


CREATE FUNCTION createTDF(TEXT, TEXT) RETURNS VOID AS
$BODY$
	DECLARE
   	tableName ALIAS for $1;
      columnName ALIAS FOR $2;
   BEGIN
   	tableName := 'tdfto'||columnName||'from'||tableName;
   	EXECUTE 'CREATE TABLE ' ||tableName|| ' (token varchar(5), df integer)';
      RETURN;
   END;
$BODY$ LANGUAGE plpgsql;
--############################################


CREATE OR REPLACE FUNCTION existTable(text) RETURNS BOOLEAN AS $$
    BEGIN
        IF EXISTS(SELECT DISTINCT table_name FROM information_schema.columns 
                  	--WHERE table_schema = 'public' and table_name = $1) THEN
                  WHERE table_name = $1) THEN
        		RETURN TRUE;
        ELSE
        		RETURN FALSE;
        END IF;
    END;
$$ LANGUAGE plpgsql;
--############################################


CREATE OR REPLACE FUNCTION enableSimilarity(TEXT, TEXT) RETURNS text AS $$
	DECLARE
   	ttokensName text;
      tdfName text;
   BEGIN
   	ttokensName := 'ttkto'||$2|| 'from' || $1;
      tdfName := 'tdfto'||$2||'from'||$1;
      IF (not existTable(ttokensName)) AND (not existTable(tdfName)) THEN
      	PERFORM createTTokensTo2($1, $2);
         PERFORM createTDF($1, $2);
         -- chamar função para popular as tabelas de tokens e de frequência
         -- criar trigger para atualizar as tabelas de tokens e de frequência quando $1 for atualizada
         RETURN 'A TABELA '||$1|| ' FOI HABILITADA PARA OPERAÇÕES DE SIMILARIDADE';
      ELSE
      	RETURN 'OPERAÇÕES DE SIMILARIDADE JÁ HAVIAM SIDO HABILITADAS';
      END IF;
      return tdfName;
   END;
$$ LANGUAGE plpgsql;
--############################################



--############################################
CREATE OR REPLACE FUNCTION field_primary_key(TEXT) 
RETURNS TABLE (nome name, tipo text) AS $$
	DECLARE
   	tableName ALIAS FOR $1; 
   BEGIN
   	RETURN QUERY SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
              FROM pg_index i JOIN   pg_attribute a ON a.attrelid = i.indrelid
              AND a.attnum = ANY(i.indkey)
              WHERE i.indrelid =  tableName::regclass AND i.indisprimary; 
      return;
   END;
$$ LANGUAGE 'plpgsql';
--############################################


