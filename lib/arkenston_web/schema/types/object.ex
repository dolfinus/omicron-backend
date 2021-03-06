defmodule ArkenstonWeb.Schema.Types.Object do
  use Absinthe.Schema.Notation

  import_types ArkenstonWeb.Schema.Types.Object.Author

  import_types ArkenstonWeb.Schema.Types.Object.User
  import_types ArkenstonWeb.Schema.Types.Object.UserAccessToken
  import_types ArkenstonWeb.Schema.Types.Object.UserToken
  import_types ArkenstonWeb.Schema.Types.Object.UserLogout
end
