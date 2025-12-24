defmodule AppWeb.SmtHTML do
  use AppWeb, :html
  alias AppWeb.Smt.Layouts
  alias AppWeb.Smt.Surfaces

  embed_templates("smt_html/*")
end
