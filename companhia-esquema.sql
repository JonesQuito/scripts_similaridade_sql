CREATE TABLE funcionario (
    nome character varying(15) not null,
    inicial char,
    sobrenome character varying(15) not null,
    cpf character(9) not null,
    data_nasc date,
    endereco character varying(33),
    gen character(1),
    salario numeric(10,2),
    super_cpf character(9),
    dno integer not null,
    primary key (cpf),
    foreign key (super_cpf) references funcionario(cpf)
);


CREATE TABLE departamento (
    dnome character varying(15) not null unique,
    dnumero integer not null primary key,
    ger_cpf character(9) not null,
    ger_inicio_data date,
    foreign key (ger_cpf) references funcionario(cpf)
);

alter table funcionario add constraint func_depart_fkey foreign key (super_cpf) references funcionario(cpf);

CREATE TABLE dept_locais (
    dnumero integer not null,
    dlocal character varying(15) not null,
    constraint dept_locais_pkey primary key (dnumero, dlocal),
    constraint dept_locais_fkey foreign key (dnumero) references departamento(dnumero)
);

CREATE TABLE projeto (
    pnome character varying(18) not null,
    pnumero integer not null primary key,
    plocal character varying(15),
    dnum integer not null references departamento(dnumero),
    unique (pnome)
);

CREATE TABLE func_proj (
    cpf character(9) not null references funcionario(cpf),
    pno integer not null references projeto(pnumero),
    hours numeric(3,1) not null,
    primary key (cpf, pno)
);

CREATE TABLE dependente (
    cpf character(9) NOT NULL references funcionario(cpf),
   nome character varying(15) NOT NULL,
    gen character(1),
    data_nasc date,
    relacionamento varchar(8),
    primary key (cpf, nome)
);
