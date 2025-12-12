defmodule IronfolkCombatWeb.BlogHTML do
  use IronfolkCombatWeb, :html
  embed_templates "blog_html/*"

  def render_markdown(content) do
    case Earmark.as_html(content) do
      {:ok, html, _} -> raw(html)
      {:error, _, _} -> content
    end
  end
end
