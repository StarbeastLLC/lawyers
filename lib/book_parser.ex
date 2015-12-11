defmodule LawExtractor.BookParser do
  @moduledoc "LIBRO = (PARTE+ | TITULO+)"

  import LawExtractor.PartParser,  only: [parse_part: 1, part_expression: 0]
  import LawExtractor.TitleParser, only: [parse_title: 1, title_expression: 0]

  ####################
  # Public functions
  ####################
  def parse_book(book_with_index) do
    parse_book_containing(book_with_index, book_has(book_with_index))
  end

  ####################
  # Branchs
  ####################
  defp parse_book_containing({book, index}, :parts) do
    raw_parts = split_book_using(book, part_expression)

    {book_title, parts_with_index} = extract_book_title(raw_parts)
    parts_map = Enum.map(parts_with_index, &parse_part(&1))
    {"LIBRO #{index_to_word(index)}: " <> book_title, parts_map}
  end

  defp parse_book_containing({book, index}, :titles) do
    raw_titles = split_book_using(book, title_expression)

    {book_title, titles_with_index} = extract_book_title(raw_titles)
    titles_map = Enum.map(titles_with_index, &parse_title(&1))
    {"LIBRO #{index_to_word(index)}: " <> book_title, titles_map}
  end

  ####################
  # Private functions
  ####################
  defp book_has({book, _index}) do
    case Regex.match?(part_expression, book) do
      true -> :parts
      false -> :titles
    end
  end

  defp split_book_using(book, expression) do
    book
    |> String.strip
    |> String.split(expression, trim: true)
  end

  defp extract_book_title(raw_element) do
    book_title = Enum.at(raw_element, 0) |> String.strip
    elements = Enum.drop(raw_element,1) |> Enum.with_index
    {book_title, elements}
  end

  defp index_to_word(index) do
    ["PRIMERO","SEGUNDO","TERCERO","CUARTO","QUINTO","SEXTO","SEPTIMO","OCTAVO","NOVENO","DECIMO"]
    |> Enum.at(index)
  end
end
