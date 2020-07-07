defmodule ArkenstonWeb.Schema.Query.User do
  use Absinthe.Schema.Notation

  object :user_queries do
    field :users, list_of(:user) do
      arg :id,      :uuid4
      arg :name,    :string
      arg :email,   :string
      arg :role,    :user_role
      arg :deleted, :boolean
      resolve &Arkenston.Resolver.UserResolver.all/2
    end

    field :user, :user do
      arg :id,      :uuid4
      arg :name,    :string
      arg :email,   :string
      arg :role,    :user_role
      arg :deleted, :boolean
      resolve &Arkenston.Resolver.UserResolver.one/2
    end
  end
end
