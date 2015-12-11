defmodule LawExtractor.Extractor do

  ####################
  # Public functions
  ####################
  def extract_content_from_file_name(file_name) do
    {title, content} = extract_content(file_name)
    {header, body} = extract_header_body(content, title)
    {preliminars, books, transitories} = extract_main_sections(body)

    {title, header, preliminars, books, transitories}
  end

  ####################
  # Private functions
  ####################
  defp extract_content(file_name) do
    {:ok, file} = File.open(file_name, [:read, :utf8])
    title = IO.read(file, :line) |> String.strip
    content = IO.read(file, :all)
    {title,content}
  end

  defp extract_header_body(content, title) do
    [header, body] = String.split(content, title, parts: 2, trim: true)
    {String.strip(header), String.strip(body)}
  end

  defp extract_main_sections(body) do
    books_exp = ~r{LIBRO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
    raw_books = String.split(body, books_exp, trim: true)

    {preliminars, books_with_trans} = extract_preliminars(raw_books)
    {transitories, books} = extract_transitories(books_with_trans)

    books = Enum.with_index(books)
    {preliminars, books, transitories}
  end

  defp extract_preliminars(raw_books) do
    first_elem = hd(raw_books)
    preliminars = ""
    raw_preliminars = String.split(first_elem, ~r{(Preliminares)}, parts: 2, trim: true)
    if length(raw_preliminars) == 2 do
      preliminars = raw_preliminars
                    |> Enum.at(1)
                    |> String.strip
      books_without_pre = Enum.drop(raw_books,1)
    end
    {preliminars, books_without_pre}
  end

  defp extract_transitories(raw_books) do
    last_elem_index = length(raw_books) - 1
    last_elem = Enum.at(raw_books, last_elem_index)
    transitories = ""
    raw_transitories = String.split(last_elem, ~r{(Transitorios|TRANSITORIOS)}, parts: 2, trim: true)

    # Si hay mas de un elemento significa que hay transitorios, el split encontro la cadena
    # y pudo hacer la separación.
    if length(raw_transitories) == 2 do
      # Primero, de raw_transitories obtenemos y eliminamos el primer elemento que es parte del raw_books.
      [book | transitories] = raw_transitories
      transitories = hd(transitories)

      # El último elemento de raw_books tiene parte del libro y parte de transitorios,
      # por lo que hay que que reemplazar este elemento con uno que no traiga los transitorios.
      raw_books = List.replace_at(raw_books,last_elem_index, book)
    end
    {String.strip(transitories), raw_books}
  end

end
