defmodule LawExtractor.SubHeadLandParser do
  @docmodule "SUBAPARTADO = TITLE! CAPITULO+"

  @subheadland_expression ~r{\n\n\s\s\s\s\s\s\s+.*}

  import LawExtractor.ChapterParser,  only: [parse_chapter: 1, chapter_expression: 0]

  ####################
  # Public functions
  ####################
  def parse_subheadland({ subheadland_name, subheadland }) do
    parse_subheadland_containing(subheadland_name, subheadland, :chapters)
  end

  def subheadland_expression, do: @subheadland_expression

  ####################
  # Branchs
  ####################
  defp parse_subheadland_containing(subheadland_name, subheadland, :chapters) do
    chapters_with_index = subheadland
    |> split_subheadland_using(chapter_expression)
    |> Enum.with_index

    chapters_map = Enum.map(chapters_with_index, &parse_chapter(&1))
    {subheadland_name, chapters_map}
  end

  ####################
  # Private functions
  ####################
  defp split_subheadland_using(subheadland, expression) do
    subheadland
    |> String.strip
    |> String.split(expression, trim: true)
  end
end
