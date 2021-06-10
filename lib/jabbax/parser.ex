if Code.ensure_loaded?(Plug) do
  defmodule Jabbax.Parser do
    @moduledoc false
    @behaviour Plug.Parsers

    def parse(conn, "application", "vnd.api+json", _headers, opts) do
      decoder = Keyword.get(opts, :json_decoder) ||
        raise(ArgumentError, "Jabbax parser expects a :json_decoder option")

      conn
      |> Plug.Conn.read_body(opts)
      |> decode(decoder)
    end
    def parse(conn, _type, _subtype, _headers, _opts) do
      {:next, conn}
    end

    defp decode({:more, _, conn}, _decoder), do: {:error, :too_large, conn}
    defp decode({:error, :timeout}, _decoder), do: raise Plug.TimeoutError
    defp decode({:error, _}, _decoder), do: raise Plug.BadRequestError
    defp decode({:ok, "", conn}, _decoder), do: {:ok, %{}, conn}
    defp decode({:ok, body, conn}, decoder) do
      case decoder.decode!(body) do
        terms when is_map(terms) ->
          {:ok, terms, conn}
        terms ->
          raise(Jabbax.StructureError, context: "document", expected: "Map", actual: terms)
      end
    rescue
      # credo:disable-for-next-line Credo.Check.Warning.RaiseInsideRescue
      e -> raise Plug.Parsers.ParseError, exception: e
    end
  end
end
