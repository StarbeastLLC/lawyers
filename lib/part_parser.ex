defmodule LawExtractor.PartParser do
  @moduledoc "PARTE = TITLE? TITULO+"

  @part_expression ~r{(PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA) PARTE|PARTE (PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA)}

  import LawExtractor.TitleParser, only: [parse_title: 1, title_first_expression: 0, title_expression: 0]

  ####################
  # Public functions
  ####################
  def parse_part({part, index}) do
    titles = split_part_with_titles(part)
    part_title = "SIN TITULO"

    if part_has_title(part) do
      {part_title, titles_with_index} = extract_part_title(titles)
    else
      titles_with_index = titles |> Enum.with_index
    end

    titles_map = Enum.map(titles_with_index, &parse_title(&1))
    {"#{index_to_word(index)} PARTE: " <> part_title, titles_map}
  end

  def part_expression, do: @part_expression

  ####################
  # Private functions
  ####################
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
    titles = Enum.drop(raw_titles,1) |> Enum.with_index

    {part_title, titles}
  end

  defp index_to_word(index) do
    ["PRIMERA","SEGUNDA","TERCERA","CUARTA","QUINTA","SEXTA","SEPTIMA","OCTAVA","NOVENA","DECIMA"]
    |> Enum.at(index)
  end
end
