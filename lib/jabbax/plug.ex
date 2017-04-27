if Code.ensure_loaded?(Plug) do
  defmodule Jabbax.Plug do
    def init(opts) do
      [
        assign: Keyword.get(opts || [], :assign, :doc)
      ]
    end

    def call(conn = %{body_params: %{}}, opts) do
      case Plug.Conn.get_req_header(conn, "content-type") do
        ["application/vnd.api+json"] ->
          Plug.Conn.assign(conn, opts[:assign], Jabbax.Deserializer.call(conn.body_params))

        _ ->
          conn
      end
    end
  end
end
