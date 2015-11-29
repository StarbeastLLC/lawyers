defmodule LawExtractor.HeadlandParser do

  @headlands_exist_expression ~r{I.-}
  @headland_expression ~r{\n\n\s\s\s\s\s\s\s+I+V*\.-\s.*}

  def parse_headland(headland) do
    headland
  end

  def headlands_exist_expression do
    @headlands_exist_expression
  end

  def headland_expression do
    @headland_expression
  end

end
