defmodule LawExtractor.LawParser do
  @docmodule "LAW = ENCABEZADO TITULO PRELIMINAR LIBRO+ TRANSITORIOS"

  @preliminar_article_expression ~r{Artículo \d..-}

  import LawExtractor.Extractor, only: [extract_content_from_file_name: 1]
  import LawExtractor.BookParser, only: [parse_book: 1]

  ###################################################################
  # Función principal de inicio del parseo del contenido del archivo
  ###################################################################
  def parse_file(file_name) do
    {title, header, preliminar, books, _transitories} = extract_content_from_file_name(file_name)
    books_map = Enum.map(books, &parse_book(&1))
    preliminar_map = parse_preliminar(preliminar)

    %{title: title, header: header, preliminar: preliminar_map, books: books_map}
  end

  ####################
  # Private functions
  ####################
  defp parse_preliminar(preliminar) do
    preliminar_map = String.split(preliminar, @preliminar_article_expression)
    |> tl
    |> Stream.with_index
    |> Enum.map fn({k, v}) -> {"Artículo #{v + 1}", k} end
    Enum.into(preliminar_map, %{})
  end

end
