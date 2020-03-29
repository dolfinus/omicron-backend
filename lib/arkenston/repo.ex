defmodule Arkenston.Repo do
  use Ecto.Repo,
    otp_app: :arkenston,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, warn: false
  alias Arkenston.Subject.User

  @type changeset :: Ecto.Changeset.t
  @type query :: Ecto.Query.t
  @type operation :: atom

  @spec audited(op :: operation, user :: %User{}|nil, args :: [any]) :: {:ok, any} | {:error, any}
  defp audited(op, %User{} = user, args) do
    if in_transaction?() do
      query("set local \"arkenston.current_user\" = '#{user.id}';")
      apply(__MODULE__, op, args)
    else
      transaction(fn ->
        query("set local \"arkenston.current_user\" = '#{user.id}';")
        apply(__MODULE__, op, args)
      end)
    end
  end

  defp audited(op, _, args) do
    apply(__MODULE__, op, args)
  end

  @spec audited_insert(changeset :: changeset, user :: %User{}|nil, opts :: [keyword]) :: {:ok, any} | {:error, any}
  def audited_insert(changeset, user \\ nil, opts \\ []) do
    audited(:insert, user, [changeset, opts])
  end

  @spec audited_insert!(changeset :: changeset, user :: %User{}|nil, opts :: [keyword]) :: any | no_return
  def audited_insert!(changeset, user \\ nil, opts \\ []) do
    case audited_insert(changeset, user, opts) do
      {:ok, result} ->
        result

      {:error, changes} ->
        raise Ecto.InvalidChangesetError, action: :insert, changeset: changes
    end
  end

  @spec audited_update(changeset :: changeset, user :: %User{}|nil, opts :: [keyword]) :: {:ok, any} | {:error, any}
  def audited_update(changeset, user \\ nil, opts \\ []) do
    audited(:update, user, [changeset, opts])
  end

  @spec audited_update!(changeset :: changeset, user :: %User{}|nil, opts :: [keyword]) :: any | no_return
  def audited_update!(changeset, user \\ nil, opts \\ []) do
    case audited_update(changeset, user, opts) do
      {:ok, result} ->
        result

      {:error, changes} ->
        raise Ecto.InvalidChangesetError, action: :update, changeset: changes
    end
  end

  @type queryable :: Ecto.Queryable.t | module
  @type fields :: [atom]
  @type limit :: pos_integer
  @type page :: pos_integer
  @type size :: pos_integer
  @type order :: :desc|:asc

  @type filter_opt :: %{optional(atom) => atom|number|String.t|map}
  @type deleted_opt :: %{deleted: boolean|nil}
  @type order_opt :: %{order: keyword(order)|%{optional(atom) => order}}
  @type limit_opt :: %{limit: limit}
  @type pagination_opt :: %{page: page} | %{size: size} | %{page: page, size: size}
  @type query_opts :: filter_opt|deleted_opt|order_opt|limit_opt|pagination_opt

  @doc """
  Apply filter for 'deleted' column

  ## Examples

      iex> filter_deleted(query, %{deleted: true, some: thing})
      {from i in query,
        where: i.deleted == true, %{some: thing}}

      iex> filter_deleted(User)
      {from i in query,
        where: i.deleted == false}

      iex> filter_deleted(User, %{deleted: false, some: thing})
      {from i in query,
        where: i.deleted == false, %{some: thing}}

      iex> filter_deleted(User, %{deleted: nil, some: thing})
      {query, %{some: thing}}

  """
  @spec filter_deleted(query :: queryable, opts :: query_opts) :: {queryable, query_opts}
  def filter_deleted(query, opts \\ %{}) do
      new_query = case opts |> Map.fetch(:deleted) do
        {:ok, deleted} when not is_nil(deleted) ->
          from i in query,
            where: i.deleted == ^deleted

        {:ok, nil} ->
          query

        :error ->
          from i in query,
            where: i.deleted == false
      end

      new_opts = opts |> Map.delete(:deleted)

      {new_query, new_opts}
  end

  @doc """
  Return first query result

  ## Examples

      iex> first(query)
      from i in query,
        where: limit == 1

  """
  @spec first(query :: queryable) :: queryable
  def first(query) do
    from i in query,
      limit: 1
  end

  @doc """
  Add WHERE clause to SELECT query

  ## Examples

      iex> handle_filter(query)
      {query, %{}}

      iex> handle_filter(User, %{some: thing, limit: 1})
      {from i in query,
        where: i.some == thing, %{limit: 1}}

  """
  @spec handle_filter(query :: queryable, opts :: query_opts) :: queryable
  def handle_filter(query, opts \\ %{}) do
    {query, opts} = filter_deleted(query, opts)

    query |> where([], ^Enum.to_list(opts))
  end

  @doc """
  Add result order handler

  ## Examples

      iex> handle_order(query)
      query

      iex> handle_order(User, %{order: [column: :desc]})
      from i in query,
        order: ^[column: :desc]

  """
  @spec handle_order(query :: queryable, opts :: query_opts) :: queryable
  def handle_order(query, opts \\ %{}) do
    case opts do
      %{order: order} ->
        from i in query, order_by: ^order

      _ ->
        query
    end
  end

  @doc """
  Add result limit handler

  ## Examples

      iex> handle_limit(query)
      query

      iex> handle_limit(User, %{limit: 1})
      from i in query,
        limit: ^1

  """
  @spec handle_limit(query :: queryable, opts :: query_opts) :: queryable
  def handle_limit(query, opts \\ %{}) do
    case opts do
      %{limit: limit} ->
        from i in query, limit: ^limit

      _ ->
        query
    end
  end

  @doc """
  Add pagination case handler

  ## Examples

      iex> handle_pagination(query)
      query

      iex> handle_pagination(User, %{page: 2})
      from i in query,
        limit: ^40,
        offset: ^20

      iex> handle_pagination(User, %{size: 40})
      from i in query,
        limit: ^40,
        offset: ^0

      iex> handle_pagination(User, %{page: 2, size: 40})
      from i in query,
        limit: ^80,
        offset: ^40

  """
  @spec handle_pagination(query :: queryable, opts :: query_opts) :: queryable
  def handle_pagination(query, opts \\ %{}) do
    case opts do
      %{page: page, size: size} ->
        paginate(query, page, size)

      %{size: size} ->
        paginate(query, 1, size)

      %{page: page} ->
        paginate(query, page, 20)

      _ ->
        query
    end
  end

  @doc """
  Add LIMIT clause to SELECT query

  ## Examples

      iex> paginage(query, 1, 10)
      from i in query,
        limit: 10,
        offset: 0

      iex> paginage(query, 2, 10)
      from i in query,
        limit: 10,
        offset: 10

  """
  @spec paginate(query :: queryable, page :: page, size :: size) :: queryable
  def paginate(query, page, size) do
    from query,
      limit: ^size,
      offset: ^((page-1) * size)
  end

  @doc """
  Add WHERE clause to SELECT query

  ## Examples

      iex> generate_query(query)
      query

      iex> generate_query(User, %{some: thing, limit: 1, order: %{colum: desc}})
      from i in query,
        where: i.some == thing,
        limit: 1,
        order_by: [desc: column]

  """
  @spec generate_query(query :: queryable, opts :: query_opts) :: queryable
  def generate_query(query, opts \\ %{}) do
    filter_opts = Map.drop(opts, [:limit, :order, :page, :size])
    query
    |> handle_pagination(opts)
    |> handle_limit(opts)
    |> handle_order(opts)
    |> handle_filter(filter_opts)
  end

  @doc """
  Limit return fields list in SELECT query

  ## Examples

      iex> return_fields(query, [:id, :name])
      from i in query,
        select: [:id, :name]

  """
  @spec return_fields(query :: queryable, fields :: fields) :: queryable
  def return_fields(query, fields) when is_list(fields) and length(fields) != 0 do
    query
    |> select(^fields)
  end

  def return_fields(query, _fields) do
    query
  end
end
