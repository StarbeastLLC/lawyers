defmodule LawExtractor.TitleParser do
  alias LawExtractor.ChapterParser

  def parse_title(title) do
    title
  end

  def create_title(title) do
    chapter_exp =  ~r{CAPITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO|I|II|III|IV|V|VI|VII|VIII|IX|X)}
    chapters = title
    |> String.strip
    |> String.split(chapter_exp, trim: true)

    {chapter_title, chapters} = extract_title_title(chapters)
    # IO.inspect "Chapters to process #{length(chapters)}"
    # IO.inspect chapter_title
    chapters_map = Enum.map(chapters, fn(chapter) -> ChapterParser.create_chapter(chapter) end)
    {chapter_title,chapters_map}
  end

  def extract_title_title(chapters) do
    title_title = ""
    # Si tiene mas de un elemento hay varios capitulos y el primer elemento es el titulo del TITULO
    if length(chapters) > 1 do
      title_title = Enum.at(chapters, 0) |> String.strip
      title = Enum.drop(chapters,1)
    else
      section_exp = ~r{\n\n\s*(\w+|\s+)+\n\n/u}
      sections = String.split(hd(chapters), section_exp, trim: true)

      if length(sections) > 1 do
        title_title = Enum.at(sections, 0) |> String.strip
      end
    end

    {title_title, chapters}
  end

end
