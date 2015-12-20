defmodule LawExtractor.LawParser do
  @docmodule "LAW = ENCABEZADO TITULO PRELIMINAR LIBRO+ TRANSITORIOS"

  @preliminar_article_expression ~r{Artículo \d..-}
  @transitories_expression ~r(\s\s\sTRANSITORIO\n|\s\s\sTRANSITORIOS\n)

  import LawExtractor.Extractor, only: [extract_content_from_file_name: 1]
  import LawExtractor.BookParser, only: [parse_book: 1]

  ###################################################################
  # Función principal de inicio del parseo del contenido del archivo
  ###################################################################
  def parse_file(file_name) do
    {title, header, preliminar, books, transitories} = extract_content_from_file_name(file_name)
    preliminar_map = parse_preliminar(preliminar)
    books_map = Enum.map(books, &parse_book(&1))
    transitories_map = parse_transitories(transitories)

    %{title: title, header: header, preliminar: preliminar_map, books: books_map, transitories: transitories_map}
  end

  ####################
  # Private functions
  ####################
  defp parse_preliminar(preliminar) do
    preliminar_map =
      preliminar
      |> String.split(@preliminar_article_expression)
      |> tl
      |> Stream.with_index
      |> Enum.map fn({k, v}) -> {"Artículo #{v + 1}", k} end

    Enum.into(preliminar_map, %{})
  end

  defp parse_transitories(transitories) do
    transitories_map =
      transitories
      |> String.split(@transitories_expression)
      |> Stream.with_index
      |> Enum.map fn({k, v}) -> {"Transitorio #{v + 1}", k} end

    Enum.into(transitories_map, %{})
  end

end
