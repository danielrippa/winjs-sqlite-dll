unit ChakraSQLite;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetJsValue: TJsValue;

implementation

  uses
    Chakra, ChakraErr, SQLite, SQLiteTypes, ChakraSQLiteUtils;

  var
    Database: TDatabase;

  function ChakraOpenDatabase(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := Undefined;
    CheckParams('openDatabase', Args, ArgCount, [jsString], 1);

    Database.Open(JsStringAsString(Args^));
  end;

  function ChakraCloseDatabase(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := Undefined;
    Database.Close;
  end;

  function ChakraExecuteStatement(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := Undefined;
    CheckParams('executeStatement', Args, ArgCount, [jsString], 1);

    Database.ExecuteStatement(JsStringAsString(Args^));
  end;

  function ChakraGetQueryResults(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    Query: String;
    QueryResults: TRecords;
  begin
    CheckParams('getQueryResults', Args, ArgCount, [jsString], 1);

    Query := JsStringAsString(Args^);

    QueryResults := Database.GetQueryResults(Query);

    Result := RecordsAsJsValue(QueryResults);
  end;

  function GetJsValue;
  begin
    Result := CreateObject;

    SetFunction(Result, 'openDatabase', ChakraOpenDatabase);
    SetFunction(Result, 'closeDatabase', ChakraCloseDatabase);

    SetFunction(Result, 'executeStatement', ChakraExecuteStatement);
    SetFunction(Result, 'getQueryResults', ChakraGetQueryResults);
  end;

end.