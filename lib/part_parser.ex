defmodule LawExtractor.PartParser do
  @moduledoc "PARTE = TITLE? TITULO+"
  @part_expression ~r{(PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA) PARTE|PARTE (PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA)}

  import LawExtractor.TitleParser, only: [parse_title: 1, title_first_expression: 0, title_expression: 0]

  # Public functions
  def parse_part(part) do
    titles = split_part_with_titles(part)
    part_title = "SIN TITULO"

    if part_has_title(part) do
      {part_title, titles} = extract_part_title(titles)
    end

    titles_map = Enum.map(titles, fn(title) -> parse_title(title) end)
    {part_title, titles_map}
  end

  def part_expression do
    @part_expression
  end

  # Private functions
  defp split_part_with_titles(part) do
    part
    |> String.strip
    |> String.split(title_expression, trim: true)
  end

  defp part_has_title(part) do
    not Regex.match?(title_first_expression, String.strip(part))
  end

  defp extract_part_title(raw_titles) do
    part_title = Enum.at(raw_titles, 0) |> String.strip
    titles = Enum.drop(raw_titles,1)

    {part_title, titles}
  end

end
