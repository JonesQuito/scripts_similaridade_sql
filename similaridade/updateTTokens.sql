
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


-- Trigger responsável por invocar a função insertTTokens atualizando assim a tabela TTokens
-- drop trigger updateTTokens on funcionario
create trigger updateTTokens after insert on funcionario FOR EACH ROW execute procedure insertTTokens()


-- Insere um registro para testar a trigger e a function
insert into funcionario (nome, inicial, sobrenome, cpf, data_nasc, endereco, gen, salario, super_cpf, dno)
	values ('Jhones', 'J', 'Kito', '955310173', '28/08/1987', 'Rua Nonato Mota', 'M', '2000', '888665555', 5)
delete from funcionario where cpf='955310173'


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

insert into ttktonomefromaluno values(201510695, '**J')
insert into ttktonomefromaluno values(201510695, **J)
delete from ttktonomefromaluno

select insertTTokens2('201510695', 'Simone Leitão Cardoso', 2, 'ttktonomefromaluno')
select * from ttktonomefromaluno
select * from aluno
select cast(12 as text)
select cast('12' as numeric)