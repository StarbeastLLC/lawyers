defmodule LawExtractor.LawParser do
  alias LawExtractor.Extractor
  import LawExtractor.BookParser, only: [parse_book: 1]

  ######################################################################################################
  # Función principal de inicio del parseo del contenido del archivo
  ######################################################################################################

  def parse_file(file_name) do
    {title, header, _preliminars, books, _transitories} = parse_content_from_file(file_name)
    books_map = Enum.map(books, fn(book) -> parse_book(book) end)

    %{title: title, header: header, books: books_map}
  end

  def parse_content_from_file(file_name) do
    {title, content} = Extractor.extract_content(file_name)
    {header, body} = Extractor.extract_header_body(content, title)
    {preliminars, books, transitories} = Extractor.extract_main_sections(body)

    {title, header, preliminars, books, transitories}
  end

  def parse_preliminar(preliminars) do
    preliminars_map = String.split(preliminars, ~r{Artículo \d..-})
    |> tl
    |> Stream.with_index
    |> Enum.map fn({k, v}) -> {"Artículo #{v + 1}", k} end
    Enum.into(preliminars_map, %{})
  end


 ##########################################################################################################################
  def parse_law_2 do
    # {:ok, content} = File.read("2_241213.txt")
    {:ok, file} = File.open("docs/2_241213.txt", [:read, :utf8])
    _titulo = IO.read(file, :line)
    content = IO.read(file, :all)
    [_header, body] = String.split(content, "DECRETO", parts: 2, trim: true)
    libros = String.split(body, ~r{LIBRO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}, trim: true)

    _decreto = Enum.at(libros, 0)
    libros = Enum.drop(libros,1)

    # BUSCAR POR:
    # (PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA) PARTE

    # Hasta aqui:
    # decreto tiene la introducción del decreto
    # libros es una lista que contiene en cada elemento un libro con titulos y capitulos

    libro = Enum.at(libros,0) # Tomamos un libro

    titulos = String.split(libro, ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}, trim: true)

    _libro_titulo = Enum.at(titulos, 0)
    titulos = Enum.drop(titulos,1)

    # Hasta aqui:
    # libro_titulo tiene el nombre del libro
    # titulos contiene la lista de cada titulo que existe en este libro especifico

    titulo = Enum.at(titulos, 0) # Tomamos un titulo
    capitulos = String.split(titulo, ~r{CAPITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO|I|II|III|IV|V|VI|VII|VIII|IX|X)}, trim: true)

    if length(capitulos) > 1 do
      capitulo_titulo = Enum.at(capitulos, 0)
      capitulos = Enum.drop(capitulos,1)
    end

    # Hasta aqui:
    # capitulo_titulo tiene el titulo del capitulo
    # capitulos tiene la lista de capitulos que hay en este titulo en particular

    capitulo = Enum.at(capitulos, 0) # Tomamos un capitulo
    articulos = String.split(capitulo, ~r{Artículo }, trim: true)

    if length(capitulos) == 1 do
      capitulo_titulo = Enum.at(articulos, 0)
      articulos = Enum.drop(articulos,1)
    end

    IO.puts capitulo_titulo
    IO.puts Enum.at(articulos, 0)

    _titulos = Enum.map(libros, fn(libro) -> String.split(libro, ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}, trim: true) end)
  end
end
