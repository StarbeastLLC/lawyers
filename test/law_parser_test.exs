defmodule LawExtractor.LawParserTest do
  use ExUnit.Case
  doctest LawExtractor
  alias LawExtractor.LawParser

  # @tag :skip
  test "extract title and content" do
    {title, content} = LawParser.extract_content("docs/2_241213.txt")
    {:ok, real_content} = File.read("test/docs/2_241213-content.txt")
    assert title == "CÓDIGO CIVIL FEDERAL"
    assert content == real_content
  end

  # @tag :skip
  test "extract header and body" do
    {:ok, real_content} = File.read("test/docs/2_241213-content.txt")
    {:ok, real_header} = File.read("test/docs/2_241213-header.txt")
    {:ok, real_body} = File.read("test/docs/2_241213-body.txt")
    title = "CÓDIGO CIVIL FEDERAL"
    {header, body} = LawParser.extract_body(real_content, title)
    assert header == String.strip(real_header)
    assert body == String.strip(real_body)
  end

  # @tag :skip
  test "extract preliminars, books and transitories" do
    {:ok, body} = File.read("test/docs/2_241213-body.txt")
    {:ok, real_preliminars} = File.read("test/docs/2_241213-preliminars.txt")
    {:ok, real_book4} = File.read("test/docs/2_241213-book4.txt")
    {:ok, real_transitories} = File.read("test/docs/2_241213-transitories.txt")
    {preliminars, books, transitories} = LawParser.extract_sections(String.strip(body))

    assert preliminars == String.strip(real_preliminars)
    assert String.rstrip(Enum.at(books, 3)) == String.rstrip(real_book4)
    assert transitories == String.strip(real_transitories)
  end

  # @tag :skip
  test "extract preliminars_map" do
    {:ok, real_preliminars} = File.read("test/docs/2_241213-preliminars.txt")
    LawParser.create_preliminar_map(String.strip(real_preliminars))
  end

  # @tag :skip
  test "create book 4 map" do
    {:ok, book4} = File.read("test/docs/2_241213-book4.txt")
    {book_title, _parts_map} = LawParser.create_book(String.rstrip(book4))
    assert book_title == "De las Obligaciones"
  end

  @tag :skip
  test "create json" do
    {title, content} = LawParser.extract_content("docs/2_241213.txt")
    LawParser.create_json(title, content)
  end
end
