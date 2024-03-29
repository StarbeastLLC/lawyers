defmodule LawExtractor.LawParser do

  def extract_content(file_name) do
    {:ok, file} = File.open(file_name, [:read, :utf8])
    title = IO.read(file, :line) |> String.strip
    content = IO.read(file, :all)
    {title,content}
  end

  ######################################################################################################
  # Función principal de creación del json a partir del texto plano
  ######################################################################################################
  def create_json(title,content) do
    {header, body} = extract_body(content, title)
    {preliminars, books, transitories} = extract_sections(body)
    preliminars_map = create_preliminar_map(preliminars)
    transitories_map = create_transitories_map(transitories)
    books_map = create_books_map(books)

    %{title: title, header: header, preliminars: preliminars_map, transitories: transitories_map, books: books_map}
  end

  def extract_body(content, title) do
    [header, body] = String.split(content, title, parts: 2, trim: true)
    {String.strip(header), String.strip(body)}
  end

  def extract_sections(body) do
    books_exp = ~r{LIBRO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
    raw_books = String.split(body, books_exp, trim: true)

    {preliminars, books_with_trans}  = extract_preliminars(raw_books)
    {transitories, books} = extract_transitories(books_with_trans)

    {preliminars, books, transitories}
  end

  def extract_preliminars(raw_books) do
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

  def create_books_map(books) do
    IO.inspect "Books to process #{length(books)}"
    Enum.map(books, fn(book) -> create_book(book) end)
  end


  ##############################################################
  # Procesamiento de los LIBROS
  ##############################################################
  def create_book(book) do
    part_exp = ~r{(PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA) PARTE|PARTE(PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA)}
    parts = book
    |> String.strip
    |> String.split(part_exp, trim: true)

    {book_title, parts} = extract_book_title(parts)
    # IO.inspect "Parts to process #{length(parts)}"
    parts_map = Enum.map(parts, fn(part) -> create_part(part) end)
    {book_title,parts_map}
  end


  def extract_book_title(parts) do
    book_title = ""
    if length(parts) > 1 do
      book_title = Enum.at(parts, 0) |> String.strip
      parts = Enum.drop(parts,1)
    else
      title_exp = ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
      titles = String.split(hd(parts), title_exp, trim: true)

      if length(titles) > 1 do
        book_title = Enum.at(titles,0) |> String.strip
      end
    end

    {book_title, parts}
  end

  ##############################################################
  # Procesamiento de las PARTES
  ##############################################################
  # Función que extra el titulo de la PARTE y separa los titulos
  def create_part(part) do
    title_exp = ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
    titles = part
    |> String.strip
    |> String.split(title_exp, trim: true)

    {part_title, titles} = extract_part_title(titles)
    # IO.inspect "Titles to process #{length(titles)}"
    titles_map = Enum.map(titles, fn(title) -> create_title(title) end)
    {part_title,titles_map}
  end

  def extract_part_title(titles) do
    part_title = ""
    # Si tiene mas de un elemento hay varios titulos dentro de la parte y el primer elemento es el titulo de la parte
    if length(titles) > 1 do
      part_title = Enum.at(titles, 0) |> String.strip
      title = Enum.drop(titles,1)
    else
      chapter_exp = ~r{CAPITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO|I|II|III|IV|V|VI|VII|VIII|IX|X)}
      titles = String.split(hd(titles), chapter_exp, trim: true)

      if length(titles) > 1 do
        part_title = Enum.at(titles, 0) |> String.strip
      end
    end

    {part_title, titles}
  end

  ##############################################################
  # Procesamiento de los TITULOS
  ##############################################################
  # Función que extrae el titulo del TITULO y los capitulos.
  def create_title(title) do
    chapter_exp =  ~r{CAPITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO|I|II|III|IV|V|VI|VII|VIII|IX|X)}
    chapters = title
    |> String.strip
    |> String.split(chapter_exp, trim: true)

    {chapter_title, chapters} = extract_title_title(chapters)
    # IO.inspect "Chapters to process #{length(chapters)}"
    # IO.inspect chapter_title
    chapters_map = Enum.map(chapters, fn(chapter) -> create_chapter(chapter) end)
    {chapter_title,chapters_map}
  end

  def extract_title_title(chapters) do
    title_title = ""
    # Si tiene mas de un elemento hay varios capitulos y el primer elemento es el titulo del TITULO
    if length(chapters) > 1 do
      title_title = Enum.at(chapters, 0) |> String.strip
      title = Enum.drop(chapters,1)
    else
      section_exp = ~r{\n\n\s*(\w+|\s+)+\n\n/u}
      sections = String.split(hd(chapters), section_exp, trim: true)

      if length(sections) > 1 do
        title_title = Enum.at(sections, 0) |> String.strip
      end
    end

    {title_title, chapters}
  end

  ##############################################################
  # Procesamiento de los CAPITULOS
  ##############################################################
  def create_chapter(chapter) do
    chapter
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
