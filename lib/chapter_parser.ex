defmodule LawExtractor.ChapterParser do
  @docmodule "CAPITULO = TITLE? (SUBTITULO+ | SECCION+ | ARTICULO+)"

  @chapter_expression ~r{CAPITULO (UNICO|PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO|I|II|III|IV|V|VI|VII|VIII|IX|X)}

  import LawExtractor.ArticleParser, only: [parse_article: 1, article_expression: 0]
  import LawExtractor.SectionParser, only: [parse_section: 1, section_expression: 0]

  ####################
  # Public functions
  ####################
  def parse_chapter(chapter) do
    parse_chapter_containing(chapter, chapter_has(chapter))
  end

  def chapter_expression do
    @chapter_expression
  end

  def create_chapter(chapter) do
    chapter
  end

  ####################
  # Branchs
  ####################
  defp parse_chapter_containing(chapter, :subtitles) do
    raw_articles = split_chapter_using(chapter, article_expression)

    {chapter_name, subtitle, articles} = extract_chapter_name_and_subtitle(raw_articles)
    articles_map = Enum.map(articles, &parse_article(&1))
    {chapter_name, {subtitle, articles_map}}
  end

  defp parse_chapter_containing(chapter, :sections) do
    raw_sections = split_chapter_using(chapter, section_expression)

    {chapter_name, sections} = extract_chapter_name(raw_sections)
    sections_map = Enum.map(sections, &parse_section(&1))
    {chapter_name, sections_map}
  end

  defp parse_chapter_containing(chapter, :articles) do
    raw_articles = split_chapter_using(chapter, article_expression)

    {chapter_name, articles} = extract_chapter_name(raw_articles)
    articles_map = Enum.map(articles, &parse_article(&1))
    {chapter_name, articles_map}
  end

  ####################
  # Private functions
  ####################
  defp chapter_has(chapter) do
    cond do
      chapter_has_sections(chapter) -> :sections
      chapter_has_subtitles(chapter) -> :subtitles
      true -> :articles
    end
  end

  def chapter_has_sections(chapter) do
    Regex.match?(section_expression, chapter)
  end

  def chapter_has_subtitles(chapter) do
    first_element = split_chapter_using(chapter, article_expression)
    |> Enum.at(0)
    |> String.strip
    |> String.split(~r{\n\n})

    if length(first_element) == 2, do: true, else: false
  end

  defp split_chapter_using(chapter, expression) do
    chapter
    |> String.strip
    |> String.split(expression, trim: true)
  end

  defp extract_chapter_name(raw_element) do
    chapter_name = raw_element
    |> Enum.at(0)
    |> String.strip

    elements = raw_element |> Enum.drop(1)
    {chapter_name, elements}
  end

  def extract_chapter_name_and_subtitle(raw_articles) do
    [chapter_name, subtitle] = raw_articles
    |> Enum.at(0)
    |> String.strip
    |> String.split(~r{\n\n})

    articles = raw_articles |> Enum.drop(1)
    {chapter_name, subtitle, articles}
  end

end
