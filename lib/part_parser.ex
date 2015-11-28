defmodule LawExtractor.PartParser do
  alias LawExtractor.PartParser

  @title_expression ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
  @title_first_expression ~r{^TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}

  def parse_part(part) do
    titles = split_titles_from_part(part)
    part_title = "SIN TITULO"

    if part_has_title(part) do
      {part_title, titles} = extract_part_title(titles)
    end

    titles_map = Enum.map(titles, fn(title) -> PartParser.create_title(title) end)
    {part_title, titles_map}
  end

  def split_titles_from_part(part) do
    part
    |> String.strip
    |> String.split(@title_expression, trim: true)
  end

  defp part_has_title(part) do
    not Regex.match?(@title_first_expression, String.strip(part))
  end

  defp extract_part_title(titles) do
    part_title = Enum.at(titles, 0) |> String.strip
    titles = Enum.drop(titles,1)

    {part_title, titles}
  end

end
