defmodule LawExtractor.ArticleParser do
  @article_expression ~r{Artículo\s}

  def parse_article(article) do
    article
  end

  def article_expression do
    @article_expression
  end
end
