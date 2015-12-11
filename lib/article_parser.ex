defmodule LawExtractor.ArticleParser do
  @docmodule "ARTICULO = NUMERO TEXTO"

  @article_expression ~r{Artículo\s}
  @article_number_expression ~r{(\.-|\.)}

  ####################
  # Public functions
  ####################
  def parse_article(article) do
    parse_article_containing(article, :text)
  end

  def article_expression, do: @article_expression

  ####################
  # Branchs
  ####################
  defp parse_article_containing(article, :text) do
    raw_article = split_article_using(article, @article_number_expression)
    {article_number, text} = extract_article_number(raw_article)
    {"ARTICULO " <> article_number, text}
  end

  ####################
  # Private functions
  ####################
  defp split_article_using(article, expression) do
    article
    |> String.strip
    |> String.split(expression, trim: true, parts: 2)
  end

  defp extract_article_number(raw_element) do
    article_number = raw_element
    |> Enum.at(0)
    |> String.strip

    elements = raw_element |> Enum.drop(1)
    {article_number, elements}
  end
end
