defmodule LawExtractor.LawParserTest do
  use ExUnit.Case
  doctest LawExtractor
  alias LawExtractor.LawParser
  alias LawExtractor.Extractor

  @tag :skip
  test "extract title and content" do
    {title, content} = Extractor.extract_content("docs/2_241213.txt")
    {:ok, real_content} = File.read("test/docs/2_241213-content.txt")
    assert title == "CÓDIGO CIVIL FEDERAL"
    assert content == real_content
  end

  @tag :skip
  test "extract header and body" do
    {:ok, real_content} = File.read("test/docs/2_241213-content.txt")
    {:ok, real_header} = File.read("test/docs/2_241213-header.txt")
    {:ok, real_body} = File.read("test/docs/2_241213-body.txt")
    title = "CÓDIGO CIVIL FEDERAL"
    {header, body} = Extractor.extract_header_body(real_content, title)
    assert header == String.strip(real_header)
    assert body == String.strip(real_body)
  end

  @tag :skip
  test "extract preliminars, books and transitories" do
    {:ok, body} = File.read("test/docs/2_241213-body.txt")
    {:ok, real_preliminars} = File.read("test/docs/2_241213-preliminars.txt")
    {:ok, real_book4} = File.read("test/docs/2_241213-book4.txt")

    {:ok, real_transitories} = File.read("test/docs/2_241213-transitories.txt")
    {preliminars, books, transitories} = Extractor.extract_main_sections(String.strip(body))

    assert preliminars == String.strip(real_preliminars)
    assert String.rstrip(Enum.at(books, 3)) == String.rstrip(real_book4)
    assert transitories == String.strip(real_transitories)
  end

  @tag :skip
  test "extract preliminars_map" do
    {:ok, real_preliminars} = File.read("test/docs/2_241213-preliminars.txt")
    LawParser.parse_preliminar(String.strip(real_preliminars))
  end

  @tag :skip
  test "create book 4 map" do
    {:ok, book4} = File.read("test/docs/2_241213-book4.txt")
    {book_title, _parts_map} = LawParser.create_book(String.rstrip(book4))
    assert book_title == "De las Obligaciones"
  end

  @tag :skip
  test "create part from book 4" do
    # {:ok, part4} = File.read("test/docs/2_241213-part-book4.txt")
    # {part_title, _titles_map} = LawParser.create_part(String.rstrip(part4))
    # IO.inspect part_title
    # assert part_title == "De las Obligaciones en General"
  end

  # @tag :skip
  test "create json" do
    data = LawParser.parse_file("docs/2_241213.txt")
    # IO.inspect data.books
  end
end
