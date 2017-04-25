if Code.ensure_loaded?(Plug) do
  defmodule Jabbax.Parser do
    @behaviour Plug.Parsers

    def parse(conn, "application", "vnd.api+json", _headers, opts) do
      conn
      |> Plug.Conn.read_body(opts)
      |> decode
    end
    def parse(conn, _type, _subtype, _headers, _opts) do
      {:next, conn}
    end

    defp decode({:more, _, conn}), do: {:error, :too_large, conn}
    defp decode({:error, :timeout}), do: raise Plug.TimeoutError
    defp decode({:error, _}), do: raise Plug.BadRequestError
    defp decode({:ok, "", conn}), do: {:ok, %Jabbax.Document{}, conn}
    defp decode({:ok, body, conn}) do
      {:ok, Jabbax.decode!(body), conn}
    rescue
      e -> raise Plug.Parsers.ParseError, exception: e
    end
  end
end
