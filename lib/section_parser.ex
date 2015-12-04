defmodule LawExtractor.SectionParser do
  @docmodule "SECCION = TITLE ARTICULO+"

  @section_expression ~r{Sección (PRIMERA|SEGUNDA|TERCERA|CUARTA|QUINTA|SEXTA|SEPTIMA)}

  ####################
  # Public functions
  ####################
  def section_expression do
    @section_expression
  end

  def parse_section(section) do
    section
  end

end
