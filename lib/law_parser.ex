defmodule LawExtractor.LawParser do

  def extract_content(file_name) do
    {:ok, file} = File.open(file_name, [:read, :utf8])
    title = IO.read(file, :line) |> String.strip
    content = IO.read(file, :all)
    {title,content}
  end

  def extract_body(content, title) do
    [header, body] = String.split(content, title, parts: 2, trim: true)
    {String.strip(header), String.strip(body)}
  end

  def extract_preliminars(raw_books) do
    first_elem = hd(raw_books)
    preliminars = ""
    raw_preliminars = String.split(first_elem, ~r{(Preliminares)}, parts: 2, trim: true)
    if length(raw_preliminars) == 2 do
      preliminars = Enum.at(raw_preliminars,1)
      raw_books = Enum.drop(raw_books,1)
    end
    {String.strip(preliminars), raw_books}
  end

  def extract_transitories(raw_books) do
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

  def extract_sections(body) do
    books_exp = ~r{LIBRO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
    raw_books = String.split(body, books_exp, trim: true)

    {preliminars, raw_books}  = extract_preliminars(raw_books)
    {transitories, raw_books} = extract_transitories(raw_books)

    {preliminars, raw_books, transitories}
  end

  def create_preliminar_map(preliminars) do
    preliminars_map = String.split(preliminars, ~r{Artículo \d..-})
                      |> tl
                      |> Stream.with_index
                      |> Enum.map fn({k, v}) -> {"Artículo #{v + 1}", k} end
    Enum.into(preliminars_map, %{})
  end

  def create_transitories_map(transitories) do
    transitories
  end

  def create_json(title,content) do
    {header, body} = extract_body(content, title)
    {preliminars, books, transitories} = extract_sections(body)
    preliminars_map = create_preliminar_map(preliminars)
    transitories_map = create_transitories_map(transitories)

    %{title: title, header: header, preliminars: preliminars_map}
  end

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

    libro_titulo = Enum.at(titulos, 0)
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


    # IO.puts String.split(Enum.at(libros,0), ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}, trim: true)

    _titulos = Enum.map(libros, fn(libro) -> String.split(libro, ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}, trim: true) end)
  end
end
