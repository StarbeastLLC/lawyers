defmodule LawExtractor.ChapterParser do

  @chapter_expression ~r{CAPITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO|I|II|III|IV|V|VI|VII|VIII|IX|X)}

  def parse_chapter(chapter) do
    chapter
  end

  def chapter_expression do
    @chapter_expression
  end

  def create_chapter(chapter) do
    chapter
  end

end
