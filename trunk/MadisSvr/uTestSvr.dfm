object DM: TDM
  OldCreateOrder = False
  OnCreate = RemoteDataModuleCreate
  Height = 150
  Width = 215
  object dsProvider: TDataSetProvider
    DataSet = qry
    Left = 88
    Top = 56
  end
  object qry: TADOQuery
    Connection = conn
    Parameters = <>
    Left = 40
    Top = 56
  end
  object conn: TADOConnection
    LoginPrompt = False
    Left = 40
    Top = 8
  end
end
