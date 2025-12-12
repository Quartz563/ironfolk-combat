defmodule IronfolkCombat.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_posts" do
    field(:title, :string)
    field(:slug, :string)
    field(:content, :string)
    field(:excerpt, :string)
    field(:published, :boolean, default: false)
    field(:published_at, :naive_datetime)
    field(:author_name, :string)

    belongs_to(:author, IronfolkCombat.Accounts.Admin)

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :excerpt, :published, :author_name, :author_id])
    |> validate_required([:title, :content])
    |> generate_slug()
    |> unique_constraint(:slug)
    |> maybe_set_published_at()
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :title) do
      nil ->
        changeset

      title ->
        slug =
          title
          |> String.downcase()
          |> String.replace(~r/[^\w\s-]/, "")
          |> String.replace(~r/\s+/, "-")

        put_change(changeset, :slug, slug)
    end
  end

  defp maybe_set_published_at(changeset) do
    if get_change(changeset, :published) == true and get_field(changeset, :published_at) == nil do
      put_change(
        changeset,
        :published_at,
        NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      )
    else
      changeset
    end
  end
end
