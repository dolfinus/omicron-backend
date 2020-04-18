defmodule Arkenston.Subject do
  @moduledoc """
  The Subject context.
  """

  import Ecto.Query, warn: false

  alias Arkenston.Repo
  alias Arkenston.Subject.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """

  @spec list_users(opts :: Repo.query_opts, fields :: Repo.fields) :: [%User{}]
  def list_users(opts \\ %{}, fields \\ []) do
    User
    |> Repo.generate_query(opts)
    |> Repo.return_fields(fields)
    |> Repo.all()
  end

  @doc """
  Gets a single user by search query.

  ## Examples

      iex> get_user_by(id: 123)
      %User{}

      iex> get_user_by(id: 456)
      nil

  """
  @spec get_user_by(opts :: Repo.query_opts, fields :: Repo.fields) :: %User{}|nil
  def get_user_by(opts \\ %{}, fields \\ []) do
    User
    |> Repo.generate_query(opts)
    |> Repo.return_fields(fields)
    |> Repo.first()
    |> Repo.one()
  end

  @doc """
  Gets a single user by search query.

  ## Examples

      iex> get_user_by(id: 123)
      %User{}

      iex> get_user_by(id: 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by!(opts :: Repo.query_opts, fields :: Repo.fields) :: %User{}|no_return
  def get_user_by!(opts \\ %{}, fields \\ []) do
    User
    |> Repo.generate_query(opts)
    |> Repo.return_fields(fields)
    |> Repo.first()
    |> Repo.one!()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(id :: User.id, fields :: Repo.fields) :: %User{}|no_return
  def get_user!(id, fields \\ []), do: get_user_by!(%{id: id}, fields)

  @doc """
  Gets a single user by id.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  @spec get_user(id :: User.id, fields :: Repo.fields) :: %User{}|nil
  def get_user(id, fields \\ []), do: get_user_by(%{id: id}, fields)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(attrs :: map, context :: map) :: {:ok, any}|{:error, any}
  def create_user(attrs \\ %{}, context \\ %{}) do
    %User{}
      |> User.create_changeset(attrs)
      |> Repo.audited_insert(context)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(user :: %User{}, attrs :: map, context :: map) :: {:ok, any}|{:error, any}
  def update_user(%User{} = user, attrs \\ %{}, context \\ %{}) do
    user
      |> User.update_changeset(attrs)
      |> Repo.audited_update(context)
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user(user :: %User{}, context :: map) :: {:ok, any}|{:error, any}
  def delete_user(%User{} = user, context \\ %{}) do
    user
      |> User.delete_changeset()
      |> Repo.audited_update(context)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  @spec change_user(user :: %User{}) :: Repo.changeset
  def change_user(%User{} = user) do
    User.update_changeset(user)
  end
end
