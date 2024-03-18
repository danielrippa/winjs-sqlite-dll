unit SQLiteUtils;

{$mode delphi}

interface

  uses
    SQLiteTypes, ChakraTypes;

  procedure PrepareStatement(aDatabase: PSQLite3; aStatement: String; var Stmt: PSQLite3Stmt);
  procedure ExecuteStatement(aDatabase: PSQlite3; aStatement: String);
  function GetQueryResults(aDatabase: PSQLite3; aQuery: String): TRecords;
  function FieldTypeAsString(aFieldType: TSQLiteFieldType): String;
  function StringToFieldType(aFieldType: String): TSQLiteFieldType;

implementation

  uses
    SQLiteAPI, SQLiteErr, SysUtils, Variants, TypInfo;

  procedure ExecuteStatement;
  var
    Message: PChar;
    ErrorCode: Integer;
    ErrorMessage: String;
  begin
    ErrorCode := sqlite3_exec(aDatabase, PChar(aStatement), Nil, Nil, Message);

    if ErrorCode <> SQLITE_OK then begin

      ErrorMessage := StrPas(Message);
      sqlite3_free(Message);

      raise ESQLiteException.Create(ErrorMessage);

    end;
  end;

  procedure PrepareStatement;
  var
    ErrorCode: Integer;

  begin
    ErrorCode := sqlite3_prepare_v2(aDatabase, PChar(aStatement), -1, Stmt, Nil);

    if ErrorCode <> SQLITE_OK then begin
      raise ESQLiteException.Create(Format('Failed to prepare statement "%s"', [aStatement]));
    end;
  end;

  function BlobAsVariant(aStatement: PSQLite3Stmt; aColumnIndex: Integer): Variant;
  var
    BlobSize: Integer;
    P: Pointer;
  begin

    BlobSize := sqlite3_column_bytes(aStatement, aColumnIndex);

    Result := VarArrayCreate([0, BlobSize - 1], varByte);

    P := VarArrayLock(Result);
    Move(sqlite3_column_blob(aStatement, aColumnIndex)^, P^, BlobSize);
    VarArrayUnlock(Result);

  end;

  function FieldTypeAsString;
  var
    FullEnumName: String;
    NameLength: Integer;
  begin
    FullEnumName := GetEnumName(TypeInfo(TSQLiteFieldType), Ord(aFieldType));
    NameLength := Length(FullEnumName);

    Result := RightStr(FullEnumName, NameLength - 2);
  end;

  function GetQueryResults;
  var
    QueryStatement: PSQLite3Stmt;
    ColumnCount: Integer;
    ErrorCode: Integer;
    Row: TRecord;
    Field: TField;
    ColumnIndex: Integer;
    ColumnType: TSQLiteFieldType;
    ColumnTypeIndex: Integer;
  begin

    PrepareStatement(aDatabase, aQuery, QueryStatement);

    ColumnCount := sqlite3_column_count(QueryStatement);

    while sqlite3_step(QueryStatement) = SQLITE_ROW do begin

      SetLength(Row, ColumnCount);

      for ColumnIndex := 0 to ColumnCount - 1 do begin

        ColumnTypeIndex := sqlite3_column_type(QueryStatement, ColumnIndex);

        ColumnType := TSQLiteFieldType(ColumnTypeIndex - 1);

        with Row[ColumnIndex] do begin

          FieldType := FieldTypeAsString(ColumnType);
          FieldName := sqlite3_column_name(QueryStatement, ColumnIndex);

          case ColumnType of
            ftInteger: Value := sqlite3_column_int(QueryStatement, ColumnIndex);
            ftReal:    Value := sqlite3_column_double(QueryStatement, ColumnIndex);
            ftText:    Value := sqlite3_column_text(QueryStatement, ColumnIndex);

            ftBlob: Value := BlobAsVariant(QueryStatement, ColumnIndex);
          end;

        end;

      end;

      Result := Result + [Row];

    end;

    sqlite3_reset(QueryStatement);

  end;

  function StringToFieldType;
  begin
    if      aFieldType = 'Integer' then Result := ftInteger
    else if aFieldType = 'Real'    then Result := ftReal
    else if aFieldType = 'Text'    then Result := ftText
    else if aFieldType = 'Blob'    then Result := ftBlob
    else if aFieldType = 'Null'    then Result := ftNull;
  end;

end.