defmodule IronfolkCombat.Repo.Migrations.CreateCreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add(:title, :string, null: false)
      add(:slug, :string, null: false)
      add(:content, :text, null: false)
      add(:excerpt, :text)
      add(:published, :boolean, default: false)
      add(:published_at, :naive_datetime)
      add(:author_name, :string)
      add(:author_id, references(:admins, on_delete: :nilify_all))

      timestamps()
    end

    create(unique_index(:blog_posts, [:slug]))
    create(index(:blog_posts, [:published]))
    create(index(:blog_posts, [:author_id]))
  end
end
