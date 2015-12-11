defmodule LawExtractor.SectionParser do
  @docmodule "SECCION = TITLE ARTICULO+"

  @section_expression ~r{Sección (PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA)}

  import LawExtractor.ArticleParser,  only: [parse_article: 1, article_expression: 0]

  ####################
  # Public functions
  ####################
  def parse_section(section) do
    parse_section_containing(section, :articles)
  end

  def section_expression, do: @section_expression

  ####################
  # Branchs
  ####################
  defp parse_section_containing(section, :articles) do
    raw_articles = split_section_using(section, article_expression)

    {section_name, articles} = extract_section_name(raw_articles)
    articles_map = Enum.map(articles, &parse_article(&1))
    {"SECCION: " <> section_name, articles_map}
  end

  ####################
  # Private functions
  ####################
  defp split_section_using(section, expression) do
    section
    |> String.strip
    |> String.split(expression, trim: true)
  end

  defp extract_section_name(raw_element) do
    article_name = raw_element
    |> Enum.at(0)
    |> String.strip

    elements = raw_element |> Enum.drop(1)
    {article_name, elements}
  end

end
