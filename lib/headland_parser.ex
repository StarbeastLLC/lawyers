defmodule LawExtractor.HeadlandParser do
  @docmodule "APARTADO = TITLE ( SUBAPARTADO+ | CAPITULO+ | ARTICULO+ )"

  @headlands_exist_expression ~r{I.-}
  @headland_expression ~r{\n\n\s\s\s\s\s\s\s+I+V*\.-\s.*}

  import LawExtractor.ChapterParser,  only: [parse_chapter: 1, chapter_expression: 0]
  import LawExtractor.ArticleParser,  only: [parse_article: 1, article_expression: 0]

  # Public functions
  def parse_headland({headland_name, headland}) do
    parse_headland_containing(headland_name, headland, headland_has(headland))
  end

  def headlands_exist_expression do
    @headlands_exist_expression
  end

  def headland_expression do
    @headland_expression
  end

  # Private functions
  defp headland_has(headline) do
    unless headland_has_chapters(headline) do
      if headland_has_subheadlands(headline), do: :subheadlands, else: :chapters
    else
      :articles
    end
  end

  defp headland_has_chapters(headland) do
    Regex.match?(chapter_expression, headland)
  end

  defp headland_has_subheadlands(headland) do
    first_element = headland
    |> split_headland_using(chapter_expression)
    |> Enum.at(0)

    not Regex.match?(article_expression, first_element)
  end

  defp split_headland_using(headland, expression) do
    headland
    |> String.strip
    |> String.split(expression, trim: true)
  end

  # Branchs
  defp parse_headland_containing(headland_name, headland, :subheadlands) do
    headland
  end

  defp parse_headland_containing(headland_name, headland, :chapters) do
    chapters = split_headland_using(headland, chapter_expression)
    chapters_map = Enum.map(chapters, fn(chapter) -> parse_chapter(chapter) end)
    {headland_name, chapters_map}
  end

  defp parse_headland_containing(headland_name, headland, :articles) do
    articles = split_headland_using(headland, article_expression)
    articles_map = Enum.map(articles, fn(article) -> parse_article(article) end)
    {headland_name, articles_map}
  end

  # Auxiliars functions

end
