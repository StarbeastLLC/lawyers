defmodule LawExtractor.TitleParser do
  @docmodule "TITULO = TITLE ( APARTADO+ | CAPITULO+ | ARTICULO+ )"

  @title_expression ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
  @title_first_expression ~r{^TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}

  import LawExtractor.HeadlandParser, only: [parse_headland: 1, headlands_exist_expression: 0, headland_expression: 0]
  import LawExtractor.ChapterParser,  only: [parse_chapter: 1, chapter_expression: 0]
  import LawExtractor.ArticleParser,  only: [parse_article: 1, article_expression: 0]

  ####################
  # Public functions
  ####################
  def parse_title(title_with_index) do
    parse_title_containing(title_with_index, title_has(title_with_index))
  end

  def title_first_expression, do: @title_first_expression

  def title_expression, do: @title_expression

  ####################
  # Branchs
  ####################
  defp parse_title_containing({title, index}, :headlands) do
    raw_headlands = split_title_using(title, headland_expression)
    headland_names = extract_headland_names(title, headland_expression)

    {title_name, headlands} = extract_title_name(raw_headlands)
    headlands_with_names = List.zip([headland_names | [headlands | []]])
    headlands_map = Enum.map(headlands_with_names, &parse_headland(&1))
    {"TITULO #{index_to_word(index)}: " <> title_name, headlands_map}
  end

  defp parse_title_containing({title, index}, :chapters) do
    raw_chapters = split_title_using(title, chapter_expression)

    {title_name, chapters} = extract_title_name(raw_chapters)
    chapters_with_index = Enum.with_index(chapters)
    chapters_map = Enum.map(chapters_with_index, &parse_chapter(&1))
    {"TITULO #{index_to_word(index)}: " <> title_name, chapters_map}
  end

  defp parse_title_containing({title, index}, :articles) do
    raw_articles = split_title_using(title, article_expression)

    {title_name, articles} = extract_title_name(raw_articles)
    articles_map = Enum.map(articles, &parse_article(&1))
    {"TITULO #{index_to_word(index)}: " <> title_name, articles_map}
  end

  ####################
  # Private functions
  ####################
  defp title_has({title, _index}) do
    if title_has_chapters(title) do
      if title_has_headlands(title), do: :headlands, else: :chapters
    else
      :articles
    end
  end

  defp title_has_chapters(title) do
    Regex.match?(chapter_expression, title)
  end

  defp title_has_headlands(title) do
    first_element = title
    |> split_title_using(chapter_expression)
    |> Enum.at(0)

    Regex.match?(headlands_exist_expression, first_element)
  end

  defp split_title_using(title, expression) do
    title
    |> String.strip
    |> String.split(expression, trim: true)
  end

  defp extract_title_name(raw_element) do
    title_name = Enum.at(raw_element, 0) |> String.strip
    elements = Enum.drop(raw_element,1)
    {title_name, elements}
  end

  defp extract_headland_names(title, expression) do
    Regex.scan(expression, title)
    |> List.flatten
    |> Enum.map(&String.strip/1)
  end

  defp index_to_word(index) do
    ["PRIMERO","SEGUNDO","TERCERO","CUARTO","QUINTO","SEXTO","SEPTIMO","OCTAVO","NOVENO","DECIMO", "UNDECIMO"]
    |> Enum.at(index)
  end
  # section_exp = ~r{\n\n\s*(\w+|\s+)+\n\n/u}
  # sections = String.split(hd(chapters), section_exp, trim: true)

end
