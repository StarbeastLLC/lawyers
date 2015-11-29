defmodule LawExtractor.BookParser do
  @moduledoc "LIBRO = (PARTE+ | TITULO+)"

  import LawExtractor.PartParser,  only: [parse_part: 1, part_expression: 0]
  import LawExtractor.TitleParser, only: [parse_title: 1, title_expression: 0]

  # Public functions
  def parse_book(book) do
    parse_book_containing(book, book_has(book))
  end

  # Private functions
  defp book_has(book) do
    case Regex.match?(part_expression, book) do
      true -> :parts
      false -> :titles
    end
  end

  # Branchs
  defp parse_book_containing(book, :parts) do
    raw_parts = split_book_using(book, part_expression)

    {book_title, parts} = extract_book_title(raw_parts)
    parts_map = Enum.map(parts, fn(part) -> parse_part(part) end)
    {book_title, parts_map}
  end

  defp parse_book_containing(book, :titles) do
    raw_titles = split_book_using(book, title_expression)

    {book_title, titles} = extract_book_title(raw_titles)
    titles_map = Enum.map(titles, fn(title) -> parse_title(title) end)
    {book_title, titles_map}
  end

  # Auxiliar functions
  defp split_book_using(book, expression) do
    book
    |> String.strip
    |> String.split(expression, trim: true)
  end

  defp extract_book_title(raw_element) do
    book_title = Enum.at(raw_element, 0) |> String.strip
    elements = Enum.drop(raw_element,1)
    {book_title, elements}
  end

end
