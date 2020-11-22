defmodule ArkenstonWeb.Schema.Query.Author do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  use ArkenstonWeb.Schema.Helpers.Pagination

  object :author_queries do
    connection field :authors, node_type: :author do
      arg :id,      :uuid4
      arg :name,    :string
      arg :email,   :string
      arg :deleted, :boolean
      paginated &Arkenston.Resolver.AuthorResolver.all/2
    end

    field :author, :author do
      arg :id,      :uuid4
      arg :name,    :string
      arg :email,   :string
      arg :deleted, :boolean
      resolve &Arkenston.Resolver.AuthorResolver.one/2
    end
  end
end
