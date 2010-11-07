{------------------------------------
  功能说明：哈希表
  创建日期：2009/05/05
  作者：wzw
  版权：wzw
-------------------------------------}
unit uHashList;

interface
uses IniFiles;
Type
  PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;

  THashItem = record
    Next: PHashItem;
    Key: string;
    Value: Pointer;
  end;

  TDeletionEvent = Procedure(var Value: Pointer) of Object;

  THashList = class
  private
    FEnumIndex: Cardinal;
    FCurrItem: PHashItem;
    Buckets: array of PHashItem;
    FOnDeletion: TDeletionEvent;
    procedure DoDeletion(var Value: Pointer);
  protected
    function Find(const Key: string): PPHashItem;
    function HashOf(const Key: string): Cardinal; virtual;
  public
    constructor Create(Size: Cardinal = 256);
    destructor Destroy; override;
    procedure Add(const Key: string; Value: Pointer);
    procedure Clear;
    procedure Remove(const Key: string);
    function Modify(const Key: string; Value: Pointer): Boolean;
    function ValueOf(const Key: string): Pointer;
    function FindKey(const Key: string): Boolean;
    // 列举
    procedure StartEnum;
    function EnumValue(out Value: Pointer): Boolean;
    property OnDeletion: TDeletionEvent Read FOnDeletion Write FOnDeletion;
  end;

implementation

{ THashList }

procedure THashList.Add(const Key: string; Value: Pointer);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.Value := Value;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
end;

procedure THashList.Clear;
var
  I: Integer;
  P, N: PHashItem;
begin
  for I := 0 to Length(Buckets) - 1 do
  begin
    P := Buckets[I];
    while P <> nil do
    begin
      N := P^.Next;
      DoDeletion(P^.Value);
      Dispose(P);
      P := N;
    end;
    Buckets[I] := nil;
  end;
end;

constructor THashList.Create(Size: Cardinal);
begin
  inherited Create;
  FOnDeletion := nil;
  FEnumIndex := 0;
  FCurrItem := nil;
  SetLength(Buckets, Size);
end;

destructor THashList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure THashList.DoDeletion(var Value: Pointer);
begin
  if assigned(FOnDeletion) then
    FOnDeletion(Value);
end;

function THashList.EnumValue(out Value: Pointer): Boolean;
begin
  Result := False;

  while FCurrItem <> nil do
  begin
    FCurrItem := FCurrItem^.Next;
    Break;
  end;

  while (FCurrItem = nil) and (FEnumIndex < Cardinal(Length(Buckets))) do
  begin
    FCurrItem := Buckets[FEnumIndex];
    Inc(FEnumIndex);
  end;
  if FCurrItem <> nil then
  begin
    Result := True;
    Value := FCurrItem^.Value;
  end;
end;

function THashList.Find(const Key: string): PPHashItem;
var
  Hash: Integer;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  Result := @Buckets[Hash];
  while Result^ <> nil do
  begin
    if Result^.Key = Key then
      Exit
    else
      Result := @Result^.Next;
  end;
end;

function THashList.FindKey(const Key: string): Boolean;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  Result := P <> nil;
end;

function THashList.HashOf(const Key: string): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(Key) do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor Ord
      (Key[I]);
end;

function THashList.Modify(const Key: string; Value: Pointer): Boolean;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    DoDeletion(P^.Value);
    P^.Value := Value;
  end
  else
    Result := False;
end;

procedure THashList.Remove(const Key: string);
var
  P: PHashItem;
  Prev: PPHashItem;
begin
  Prev := Find(Key);
  P := Prev^;
  if P <> nil then
  begin
    Prev^ := P^.Next;
    DoDeletion(P^.Value);
    Dispose(P);
  end;
end;

procedure THashList.StartEnum;
begin
  FEnumIndex := 0;
  FCurrItem := nil;
end;

function THashList.ValueOf(const Key: string): Pointer;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value
  else
    Result := nil;
end;

end.
