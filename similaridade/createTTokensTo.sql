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

-- Exemplos de uso
select TTokensGeneric('aluno');
select * from TTokensOfAluno;
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

-- Exemplos de uso
select createTTokensTo('professor', 'nome')
select * from ttktonomefromprofessor;
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
