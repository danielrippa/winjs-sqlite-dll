unit ChakraSQLiteUtils;

{$mode delphi}

interface

  uses
    SQLiteTypes, ChakraTypes;

  function RecordsAsJsValue(aRecords: TRecords): TJsValue;

implementation

  uses
    Variants, Chakra, SQLiteUtils;

  function BlobFieldValueAsJsValue(aFieldValue: Variant): TJsValue;
  var
    BlobSize: Integer;
    ByteIndex: Integer;
  begin
    BlobSize := VarArrayHighBound(aFieldValue, 1) - VarArrayLowBound(aFieldValue, 1) + 1;

    Result := CreateArray(BlobSize);

    for ByteIndex := 0 to BlobSize - 1 do begin
      SetArrayItem(Result, ByteIndex, IntAsJsNumber(aFieldValue[ByteIndex]));
    end;
  end;

  function FieldValueAsJsValue(aFieldType: TSQLiteFieldType; aFieldValue: Variant): TJsValue;
  begin
    case aFieldType of
      ftInteger: Result := IntAsJsNumber(Integer(aFieldValue));
      ftReal:    Result := DoubleAsJsNumber(Double(aFieldValue));
      ftText:    Result := StringAsJsString(String(aFieldValue));

      ftBlob: Result := BlobFieldValueAsJsValue(aFieldValue);

      ftNull: Result := Undefined;
    end;
  end;

  function RecordAsJsValue(aRecord: TRecord): TJsValue;
  var
    FieldCount: Integer;
    FieldIndex: Integer;
    Field: TField;
    FieldType: TSQLiteFieldType;
    FieldJsValue: TJsValue;
  begin
    Result := CreateObject;

    FieldCount := Length(aRecord);

    for FieldIndex := 0 to FieldCount - 1 do begin

      Field := aRecord[FieldIndex];

      FieldType := StringToFieldType(Field.FieldType);
      FieldJsValue := FieldValueAsJsValue(FieldType, Field.Value);

      SetProperty(Result, Field.FieldName, FieldJsValue);

    end;
  end;

  function RecordsAsJsValue;
  var
    RowCount: Integer;
    RowIndex: Integer;
    Row: TRecord;
  begin
    RowCount := Length(aRecords);

    Result := CreateArray(RowCount);

    for RowIndex := 0 to RowCount - 1 do begin
      Row := aRecords[RowIndex];

      SetArrayItem(Result, RowIndex, RecordAsJsValue(Row));
    end;
  end;

end.