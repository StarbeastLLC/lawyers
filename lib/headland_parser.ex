defmodule LawExtractor.HeadlandParser do
  @docmodule "APARTADO = TITLE ( SUBAPARTADO+ | CAPITULO+ | ARTICULO+ )"

  @headlands_exist_expression ~r{I.-}
  @headland_expression ~r{\n\n\s\s\s\s\s\s\s+I+V*\.-\s.*}

  import LawExtractor.ChapterParser,  only: [parse_chapter: 1, chapter_expression: 0]
  import LawExtractor.ArticleParser,  only: [parse_article: 1, article_expression: 0]
  import LawExtractor.SubHeadLandParser, only: [parse_subheadland: 1, subheadland_expression: 0]

  ####################
  # Public functions
  ####################
  def parse_headland({headland_name, headland}) do
    parse_headland_containing(headland_name, headland, headland_has(headland))
  end

  def headlands_exist_expression, do: @headlands_exist_expression

  def headland_expression, do: @headland_expression

  ####################
  # Branchs
  ####################
  defp parse_headland_containing(headland_name, headland, :subheadlands) do
    headland_titles = extract_headland_titles(headland, subheadland_expression)
    {titles, _} = Enum.reduce(headland_titles, %{titles: [], general: []}, &extract_divisor(&1, &2))

    subheadlands = split_headland_using_titles(headland, titles)
    subheadlands_with_names = List.zip([titles | [subheadlands | []]])
    subheadland_map = Enum.map(subheadlands_with_names, &parse_subheadland(&1))
    {"APARTADO: " <> headland_name, subheadland_map}
  end

  defp parse_headland_containing(headland_name, headland, :chapters) do
    chapters_with_index = headland
    |> split_headland_using(chapter_expression)
    |> Enum.with_index

    chapters_map = Enum.map(chapters_with_index, &parse_chapter(&1))
    {"APARTADO: " <> headland_name, chapters_map}
  end

  defp parse_headland_containing(headland_name, headland, :articles) do
    articles = split_headland_using(headland, article_expression)
    articles_map = Enum.map(articles, &parse_article(&1))
    {"APARTADO: " <> headland_name, articles_map}
  end

  ####################
  # Private functions
  ####################
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

  defp extract_headland_titles(headland, expression) do
    Regex.scan(expression, headland)
    |> List.flatten
    |> Enum.map(&String.strip/1)
  end

  defp extract_divisor(element, acc) do
    unless element in ["CAPITULO I", "PRIMER CAPITULO"] do
      push_element_to_general(element, acc)
    else
      move_element_from_general_to_titles(acc)
    end
  end

  defp push_element_to_general(element, acc) do
    new_general = [ element | acc[:general] ]
    %{acc | general: new_general}
  end

  defp move_element_from_general_to_titles(acc) do
    [title | new_general] = acc[:general]
    new_titles = [ title | acc[:titles] ]
    %{titles: new_titles, general: new_general}
  end

  defp split_headland_using_titles(headland, titles) do
    {:ok, expression} = create_regular_expression_from_titles(titles)

    headland
    |> String.strip
    |> String.split(expression, trim: true)
  end

  defp create_regular_expression_from_titles(titles) do
    exp_to_compile = "(" <> Enum.join(titles, "|") <> ")"
    Regex.compile(exp_to_compile)
  end
end
