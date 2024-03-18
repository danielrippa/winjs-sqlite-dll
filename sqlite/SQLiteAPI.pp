unit SQLIteAPI;

interface

  uses
    SQLiteTypes;

  const dll = 'sqlite3.dll';

  function sqlite3_open(filename: PAnsiChar; var Db: PSQLite3): Integer; cdecl; external dll;
  function sqlite3_close(Db: PSQLite3): Integer; cdecl; external dll;

  function sqlite3_exec(Db: PSQLite3; Sql: PAnsiChar; Callback: Pointer; Arg: Pointer; var ErrorMessage: PAnsiChar): Integer; cdecl; external dll;
  function sqlite3_prepare_v2(Db: PSQLite3; Sql: PAnsiChar; SqlLength: Integer; var Statement: PSQLite3Stmt; Tail: PAnsiChar): Integer; cdecl; external dll;
  function sqlite3_step(Statement: PSQLite3Stmt): Integer; cdecl; external dll;
  function sqlite3_finalize(Statement: PSQLite3Stmt): Integer; cdecl; external dll;

  function sqlite3_column_name(Statement: PSQLite3Stmt; ColumnIndex: Integer): PAnsiChar; cdecl; external dll;
  function sqlite3_column_type(Statement: PSQLite3Stmt; ColumnIndex: Integer): Integer; cdecl; external dll;

  function sqlite3_column_int(Statement: PSQLite3Stmt; ColumnIndex: Integer): Integer; cdecl; external dll;
  function sqlite3_column_double(Statement: PSQLite3Stmt; ColumnIndex: Integer): Double; cdecl; external dll;
  function sqlite3_column_text(Statement: PSQLite3Stmt; ColumnIndex: Integer): PChar; cdecl; external dll;
  function sqlite3_column_blob(Statement: PSQLite3Stmt; ColumnIndex: Integer): Pointer; cdecl; external dll;

  function sqlite3_column_bytes(Statement: PSQLite3Stmt; ColumnIndex: Integer): Integer; cdecl; external dll;
  function sqlite3_column_count(Statement: PSQLite3Stmt): Integer; cdecl; external dll;

  procedure sqlite3_free(P: Pointer); cdecl; external dll;

implementation

end.