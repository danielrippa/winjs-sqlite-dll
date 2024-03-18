unit SQLiteErr;

{$mode delphi}

interface

  uses
    SysUtils, SQLIteTypes;

  type

    ESQLiteException = class(Exception);

  procedure TrySQLiteAPI(aErrorCode: Integer; aMessage: String);

implementation

  procedure TrySQLiteAPI;
  begin
    if aErrorCode <> SQLITE_OK then begin
      raise ESQLiteException.Create(aMessage);
    end;
  end;

end.