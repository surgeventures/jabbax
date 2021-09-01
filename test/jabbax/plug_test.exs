defmodule Jabbax.PlugTest do
  use ExUnit.Case
  use Plug.Test
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

  @sample_doc %Document{
    data: %Resource{
      id: "1",
      type: "user",
      attributes: %{
        "name" => "Sample User"
      }
    },
    jsonapi: %{version: "1.0"}
  }

  def parse(conn, parsers) do
    Plug.Parsers.call(conn, Plug.Parsers.init(parsers: parsers, json_decoder: Poison))
  end

  test "JSON API document" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse([Jabbax.Parser])
      |> Jabbax.Plug.call(Jabbax.Plug.init(nil))

    assert connection.assigns[:doc] == @sample_doc
  end

  test "JSON API document with custom assign name" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse([Jabbax.Parser])
      |> Jabbax.Plug.call(Jabbax.Plug.init(assign: :custom_doc))

    assert connection.assigns[:custom_doc] == @sample_doc
  end

  test "other content type" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/json")
      |> parse([:json, Jabbax.Parser])
      |> Jabbax.Plug.call(Jabbax.Plug.init(nil))

    assert connection.assigns[:custom_doc] == nil
  end

  test "malformed body" do
    malformed_body = %{
      "data" => %{
        "type" => "employees",
        "relationships" => %{
          "service" => %{
            "dataaa" => %{
              "type" => "services",
              "id" => "21"
            }
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert_raise(Plug.Parsers.ParseError, fn ->
      :post
      |> conn("/", Poison.encode!(malformed_body))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse([Jabbax.Parser])
      |> Jabbax.Plug.call(Jabbax.Plug.init(nil))
    end)
  end
end
