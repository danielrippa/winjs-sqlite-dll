unit SQLiteTypes;

interface

  const
    SQLITE_OK = 0;
    SQLITE_ROW = 100;

  type

    TField = record
      FieldName: String;
      FieldType: String;
      Value: Variant;
    end;

    TRecord = array of TField;

    TRecords = array of TRecord;

    TSQLite3 = Pointer;
    PSQLite3 = ^TSQLite3;

    PSQLite3Stmt = Pointer;

    TSQLiteFieldType = (ftInteger, ftReal, ftText, ftBlob, ftNull);

implementation

end.