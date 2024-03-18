unit SQLite;

{$mode delphi}

interface

  uses
    SQLiteTypes;

  type

    TTransaction = record
      private
        FDatabase: PSQLite3;
      public
        procedure Init(aDatabase: PSQLite3);
        procedure Start;
        procedure Commit;
        procedure Rollback;

        procedure CreateSavePoint(aSavePointName: String);
        procedure RollbackToSavePoint(aSavePointName: String);
        procedure ReleaseSavePoint(aSavePointName: String);
    end;

    TDatabase = record
      private
        FDatabase: PSQLite3;
        FFilePath: String;
        FTransaction: TTransaction;
      public
        procedure Open(aFilePath: String);
        procedure Close;

        procedure ExecuteStatement(aStatement: String);
        function GetQueryResults(aQuery: String): TRecords;

        property Transaction: TTransaction read FTransaction;
    end;

implementation

  uses
    SQLIteAPI, SQLiteErr, SysUtils, SQLiteUtils;

  procedure TTransaction.Init;
  begin
    FDatabase := aDatabase;
  end;

  procedure TTransaction.Start;
  begin
    SQLiteUtils.ExecuteStatement(FDatabase, 'BEGIN TRANSACTION;');
  end;

  procedure TTransaction.Commit;
  begin
    SQLiteUtils.ExecuteStatement(FDatabase, 'COMMIT;');
  end;

  procedure TTransaction.Rollback;
  begin
    SQLiteUtils.ExecuteStatement(FDatabase, 'ROLLBACK;');
  end;

  procedure TTransaction.CreateSavePoint;
  begin
    SQLiteUtils.ExecuteStatement(FDatabase, Format('SAVEPOINT %s;', [aSavePointName]));
  end;

  procedure TTransaction.RollbackToSavePoint;
  begin
    SQLiteUtils.ExecuteStatement(FDatabase, Format('ROLLBACK TO SAVEPOINT %s;', [aSavePointName]));
  end;

  procedure TTransaction.ReleaseSavePoint;
  begin
    SQLiteUtils.ExecuteStatement(FDatabase, Format('RELEASE SAVEPOINT %s;', [aSavePointName]));
  end;

  procedure TDatabase.Open;
  begin
    TrySQLiteAPI(
      sqlite3_open(PChar(aFilePath), FDatabase),
      Format('Can''t open database "%s"', [aFilePath])
    );
    FFilePath := aFilePath;
    FTransaction.Init(FDatabase);
  end;

  procedure TDatabase.Close;
  begin
    TrySQLiteAPI(
      sqlite3_close(FDatabase),
      Format('Can''t close database "%s"', [FFilePath])
    );
  end;

  procedure TDatabase.ExecuteStatement;
  begin
    SQLiteUtils.ExecuteStatement(FDatabase, aStatement);
  end;

  function TDatabase.GetQueryResults;
  begin
    Result := SQLiteUtils.GetQueryResults(FDatabase, PChar(aQuery));
  end;

end.