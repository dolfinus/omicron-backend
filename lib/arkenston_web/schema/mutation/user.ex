defmodule ArkenstonWeb.Schema.Mutation.User do
  use Absinthe.Schema.Notation
  import AbsintheErrorPayload.Payload

  object :user_mutations do
    field :create_user, :user_payload do
      arg :input, non_null(:create_user_input)
      resolve &Arkenston.Mutator.UserMutator.create/3
      middleware &build_payload/2
    end

    field :update_user, :user_payload do
      arg :id,    :uuid4
      arg :name,  :string
      arg :email, :string
      arg :input, non_null(:update_user_input)
      resolve &Arkenston.Mutator.UserMutator.update/3
      middleware &build_payload/2
    end

    field :delete_user, :boolean_payload do
      arg :id,    :uuid4
      arg :name,  :string
      arg :email, :string
      arg :input, :delete_user_input
      resolve &Arkenston.Mutator.UserMutator.delete/3
      middleware &build_payload/2
    end
  end
end
