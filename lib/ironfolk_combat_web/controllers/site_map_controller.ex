defmodule IronfolkCombatWeb.SiteMapController do
  use IronfolkCombatWeb, :controller

  def index(conn, _params) do
    posts = IronfolkCombat.Admin.list_published_slugs()

    urls = build_urls(posts)
    xml = generate_sitemap_xml(urls)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml)
  end

  defp build_urls(posts) do
    static_urls() ++ blog_urls(posts)
  end

  defp static_urls do
    [
      {url(~p"/"), "weekly", "1.0"},
      {url(~p"/about"), "monthly", "0.8"},
      {url(~p"/faq"), "monthly", "0.7"},
      {url(~p"/code-of-conduct"), "monthly", "0.6"},
      {url(~p"/harassment-policy"), "monthly", "0.6"},
      {url(~p"/resources"), "monthly", "0.6"},
      {url(~p"/contact"), "monthly", "0.7"},
      {url(~p"/blog"), "daily", "0.9"}
    ]
  end

  defp blog_urls(posts) do
    Enum.map(posts, fn post ->
      {url(~p"/blog/#{post}"), "monthly", "0.8"}
    end)
  end

  defp event_urls(events) do
    Enum.map(events, fn event ->
      {url(~p"/events/#{event}"), "weekly", "0.7"}
    end)
  end

  defp generate_sitemap_xml(urls) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{Enum.map_join(urls, "\n", &url_entry/1)}
    </urlset>
    """
  end

  defp url_entry({loc, changefreq, priority}) do
    """
      <url>
        <loc>#{loc}</loc>
        <changefreq>#{changefreq}</changefreq>
        <priority>#{priority}</priority>
      </url>
    """
  end
end
