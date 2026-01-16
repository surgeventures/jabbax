defmodule Jabbax.ParserTest do
  use ExUnit.Case
  import Plug.Test
  import Plug.Conn
  use Jabbax.Document

  @sample_json %{
    "data" => %{
      "id" => "1",
      "type" => "user",
      "attributes" => %{
        "name" => "Sample User"
      }
    },
    "jsonapi" => %{
      "version" => "1.0"
    }
  }

  def parse(conn, opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:parsers, [Jabbax.Parser])
      |> Keyword.put_new(:json_decoder, Poison)

    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  test "JSON API document" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse()

    assert connection.body_params == @sample_json
  end

  test "plain JSON content type without JSON parser" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/json")

    assert_raise(Plug.Parsers.UnsupportedMediaTypeError, fn ->
      parse(connection)
    end)
  end

  test "no content type" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> parse()

    assert connection.body_params == %{}
  end

  test "empty request body" do
    connection =
      :post
      |> conn("/", "")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse()

    assert connection.body_params == %{}
  end

  defmodule BodyReader do
    def read_body(conn, opts) do
      {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
      {:ok, String.replace(body, "Sample", "Custom"), conn}
    end
  end

  test "custom body_reader" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse(body_reader: {BodyReader, :read_body, []})

    assert connection.body_params == %{
             "data" => %{
               "attributes" => %{
                 "name" => "Custom User"
               },
               "id" => "1",
               "type" => "user"
             },
             "jsonapi" => %{"version" => "1.0"}
           }
  end
end
