create or replace procedure pr_inventario


as
cursor cr_objeto is select object_name, object_type, created -- Cursor para Procedure
                    from user_objects;

cursor cr_texto is select *
                     from all_source
                     where owner = user;

cursor cr_tabela is select TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH  
                    from user_tab_cols;

cursor cr_index is select index_name, table_name
                   from user_indexes;


cursor cr_seq is select * 
                 from user_sequences;
resposta varchar2(5000);
resposta_ddl clob;
Coluna_tabelas varchar2(5000);
tamanho_tabela number;
contador number:= 0;
resposta_seq varchar2(5000);
begin
FOR x IN cr_objeto LOOP

            resposta:= '    '||'Usuário: '||user||chr(13);
            resposta:= resposta||'Nome do Objeto: '|| x.object_name||'      '||'Data da Criação: '||x.created||'        '||'Tipo de Objeto: '   ||x.object_type||chr(13);

            if lower(x.object_type) = 'table' 
                then    for y in cr_tabela loop
                            if contador = 0
                            then execute immediate 'SELECT COUNT(*) FROM ' || x.object_name into contador; --registros da tabela
                            end if;

                            if lower(y.TABLE_NAME) = lower(x.object_name)
                            then    if Coluna_tabelas is null
                                    then Coluna_tabelas := y.COLUMN_NAME||' '||y.DATA_TYPE||'('||y.DATA_LENGTH||')';
                                    else Coluna_tabelas := Coluna_tabelas||', '||y.COLUMN_NAME||' '||y.DATA_TYPE||'('||y.DATA_LENGTH||')';
                                    end if;
                            end if;
                        end loop;   

             resposta_ddl:= 'Create table '||x.object_name||' ('||Coluna_tabelas||');';
             resposta:=resposta||'Registros: '||contador||' ';

             execute immediate 'select sum(bytes)/(1024*1024) Mbytes
                                from dba_segments
                                where segment_type =''TABLE''
                                and segment_name = '''||x.object_name||''''
                                into tamanho_tabela;

    resposta := resposta||'Tamanho: '||tamanho_tabela||'Mbytes'||chr(13);
    resposta := resposta||' '||'DDL: '||chr(13);
    DBMS_OUTPUT.PUT_LINE(resposta);
    DBMS_OUTPUT.PUT_LINE(resposta_ddl);
    DBMS_OUTPUT.PUT_LINE('  ');
    DBMS_OUTPUT.PUT_LINE('=====================================================================================================');

            elsif lower(x.object_type) = 'procedure'
                    then    resposta:= resposta||' '||'DDL: ';
                            for y in cr_texto loop
                            if x.object_name = y.name
                            then resposta_ddl := resposta_ddl||y.text||chr(13);
                            end if;
                            end loop;

        DBMS_OUTPUT.PUT_LINE(resposta);
        DBMS_OUTPUT.PUT_LINE(resposta_ddl);
        DBMS_OUTPUT.PUT_LINE('  ');

            elsif lower(x.object_type) = 'function'
                    then resposta:= resposta||' '||'DDL: ';
                        for y in cr_texto loop
                        if x.object_name = y.name
                        then resposta_ddl := resposta_ddl||y.text||chr(13);
                        end if;
                        end loop;
        DBMS_OUTPUT.PUT_LINE(resposta);
        DBMS_OUTPUT.PUT_LINE(resposta_ddl);
        DBMS_OUTPUT.PUT_LINE('  ');
        DBMS_OUTPUT.PUT_LINE('=====================================================================================================');



            elsif lower(x.object_type) = 'trigger'
                    then resposta:= resposta||' '||'DDL: ';
                        for y in cr_texto loop
                        if x.object_name = y.name
                        then resposta_ddl := resposta_ddl||y.text||chr(13);
                        end if;
                        end loop;

        DBMS_OUTPUT.PUT_LINE(resposta);
        DBMS_OUTPUT.PUT_LINE(resposta_ddl);
        DBMS_OUTPUT.PUT_LINE('  ');
        DBMS_OUTPUT.PUT_LINE('=====================================================================================================');  

            elsif lower(x.object_type) = 'sequence'
                    then resposta:= resposta||' '||'DDL: ';
                        for y in cr_seq loop
                        if x.object_name = y.SEQUENCE_NAME
                        then resposta_ddl := 'Create or replace sequence '||y.sequence_name||chr(13)||'Start with ' ||y.MIN_VALUE || chr(13)||'minvalue '||y.MIN_VALUE||chr(13)||
                                             'maxvalue '||y.MAX_VALUE||chr(13)||'Increment by '||y.INCREMENT_BY||chr(13);

                        end if;
                        end loop;

        DBMS_OUTPUT.PUT_LINE(resposta);
        DBMS_OUTPUT.PUT_LINE(resposta_ddl);
        DBMS_OUTPUT.PUT_LINE('  ');
        DBMS_OUTPUT.PUT_LINE('====================================================================================================='); 
        
         elsif lower(x.object_type) = 'index'
                    then resposta:= resposta||' '||'DDL: ';
                   
                        
                        for y in cr_index loop
                        
                        
                          
                        if x.object_name = y.INDEX_NAME
                        then 
                        resposta_ddl := 'Create  unique index '||y.index_name||' on ' ||y.table_name || '()';

                        end if;
                        end loop;

        DBMS_OUTPUT.PUT_LINE(resposta);
        DBMS_OUTPUT.PUT_LINE(resposta_ddl);
        DBMS_OUTPUT.PUT_LINE('  ');
        DBMS_OUTPUT.PUT_LINE('====================================================================================================='); 



end if;


contador:= 0;
resposta:='';
resposta_ddl:='';
Coluna_tabelas:='';

end loop;
end;

