defmodule Jabbax.ParserTest do
  use ExUnit.Case
  use Plug.Test
  use Jabbax.Document

  def parse(conn, parsers) do
    Plug.Parsers.call(conn, Plug.Parsers.init(parsers: parsers))
  end

  test "JSON API document" do
    connection = conn(:post, "/", Poison.encode!(%{
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
    }))
    |> put_req_header("content-type", "application/vnd.api+json")
    |> parse([Jabbax.Parser])

    assert connection.body_params == %Document{
      data: %Resource{
        id: "1",
        type: "user",
        attributes: %{
          "name" => "Sample User"
        }
      },
      jsonapi: %{version: "1.0"}
    }
  end

  test "misc content type" do
    connection = conn(:post, "/", Poison.encode!(%{
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
    }))
    |> parse([Jabbax.Parser])

    assert connection.body_params == %{}
  end

  test "empty request body" do
    connection = conn(:post, "/", "")
    |> put_req_header("content-type", "application/vnd.api+json")
    |> parse([Jabbax.Parser])

    assert connection.body_params == %Document{
      data: nil,
      jsonapi: %{
        version: "1.0"
      }
    }
  end
end
