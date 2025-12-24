defmodule AppWeb.SmtHTML do
  use AppWeb, :html
  alias AppWeb.SmtLayouts

  embed_templates("smt_html/*")
end
