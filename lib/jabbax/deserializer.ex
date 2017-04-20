defmodule Jabbax.Deserializer do
  use Jabbax.Document

  def init(_opts), do: nil

  def call(conn = %{body_params: %{}}, _opts) do
    case conn.__struct__.get_req_header(conn, "content-type") do
      ["application/vnd.api+json"] -> Map.update!(conn, :body_params, &call/1)
      _ -> conn
    end
  end

  def call(doc = %{}) do
    %Document{
      data: dig_and_deserialize_data(doc),
      included: dig_and_deserialize_included(doc),
      meta: dig_and_deserialize_meta(doc),
      links: dig_and_deserialize_links(doc),
      errors: dig_and_deserialize_errors(doc),
      jsonapi: dig_and_deserialize_version(doc)
    }
  end

  defp dig_and_deserialize_data(%{"data" => data}), do: deserialize_data(data)
  defp dig_and_deserialize_data(_), do: nil

  defp deserialize_data(nil), do: nil
  defp deserialize_data(data_list) when is_list(data_list) do
    Enum.map(data_list, &deserialize_data/1)
  end
  defp deserialize_data(data), do: deserialize_data_type(detect_data_type(data), data)

  defp deserialize_data_type(Resource, resource = %{"type" => type}) do
    %Resource{
      id: deserialize_id(resource["id"]),
      type: deserialize_type(type),
      attributes: dig_and_deserialize_attributes(resource),
      relationships: dig_and_deserialize_relationships(resource),
      links: dig_and_deserialize_links(resource),
      meta: dig_and_deserialize_meta(resource)
    }
  end
  defp deserialize_data_type(ResourceId, resource = %{"type" => type}) do
    %ResourceId{
      id: deserialize_id(resource["id"]),
      type: deserialize_type(type)
    }
  end

  defp dig_and_deserialize_included(%{"included" => data}), do: deserialize_data(data)
  defp dig_and_deserialize_included(_), do: []

  defp dig_and_deserialize_relationships(%{"relationships" => relationships}) do
    deserialize_relationships(relationships)
  end
  defp dig_and_deserialize_relationships(_), do: %{}

  defp deserialize_relationships(relationship_map) do
    relationship_map
    |> Enum.map(&deserialize_relationship_pair/1)
    |> Enum.into(%{})
  end

  defp deserialize_relationship_pair({name, relationship = %{}}) do
    {deserialize_key(name), deserialize_relationship(relationship)}
  end

  defp deserialize_relationship(data_list) when is_list(data_list), do: deserialize_data(data_list)
  defp deserialize_relationship(relationship = %{"meta" => _}) do
    deserialize_relationship_struct(relationship)
  end
  defp deserialize_relationship(relationship = %{"links" => _}) do
    deserialize_relationship_struct(relationship)
  end
  defp deserialize_relationship(%{"data" => data}), do: deserialize_data(data)

  defp deserialize_relationship_struct(relationship = %{}) do
    %Relationship{
      data: dig_and_deserialize_data(relationship),
      meta: dig_and_deserialize_meta(relationship),
      links: dig_and_deserialize_links(relationship)
    }
  end

  defp dig_and_deserialize_links(%{"links" => links}) do
    deserialize_links(links)
  end
  defp dig_and_deserialize_links(_), do: %{}

  defp deserialize_links(link_map) do
    link_map
    |> Enum.map(&deserialize_link_pair/1)
    |> Enum.into(%{})
  end

  defp deserialize_link_pair({name, link}) do
    {deserialize_key(name), deserialize_link(link)}
  end

  defp deserialize_link(href) when is_binary(href), do: href
  defp deserialize_link(link = %{"href" => href}) do
    %Link{
      href: href,
      meta: dig_and_deserialize_meta(link)
    }
  end

  defp dig_and_deserialize_errors(%{"errors" => errors}) do
    deserialize_errors(errors)
  end
  defp dig_and_deserialize_errors(_), do: []

  defp deserialize_errors(error_list) when is_list(error_list) do
    Enum.map(error_list, &deserialize_error/1)
  end

  defp deserialize_error(error = %{}) do
    %Error{
      id: error["id"],
      title: error["title"],
      detail: error["detail"],
      status: error["status"],
      code: dig_and_deserialize_key(error, "code"),
      meta: dig_and_deserialize_meta(error),
      source: dig_and_deserialize_error_source(error),
      links: dig_and_deserialize_links(error)
    }
  end

  defp dig_and_deserialize_error_source(%{"source" => source}), do: deserialize_error_source(source)
  defp dig_and_deserialize_error_source(_), do: nil

  defp deserialize_error_source(source = %{}) do
    %ErrorSource{
      pointer: dig_and_deserialize_key(source, "pointer"),
      parameter: dig_and_deserialize_key(source, "parameter"),
    }
  end

  defp dig_and_deserialize_attributes(%{"attributes" => attributes}) do
    deserialize_key_values(attributes)
  end
  defp dig_and_deserialize_attributes(_), do: %{}

  defp dig_and_deserialize_meta(%{"meta" => meta}) do
    deserialize_key_values(meta)
  end
  defp dig_and_deserialize_meta(_), do: %{}

  defp dig_and_deserialize_version(%{"jsonapi" => %{"version" => "1.0"}}) do
    %{
      version: "1.0"
    }
  end

  defp deserialize_type(type), do: deserialize_key(type)

  defp deserialize_id(id) when is_binary(id), do: id
  defp deserialize_id(nil), do: nil

  defp dig_and_deserialize_key(map, key) do
    case map do
      %{^key => value} -> deserialize_key(value)
      _ -> nil
    end
  end

  defp deserialize_key(key) when is_binary(key), do: String.replace(key, "-", "_")

  defp deserialize_key_values(nil), do: %{}
  defp deserialize_key_values(key_values_map = %{}) do
    key_values_map
    |> Enum.map(&deserialize_key_value_pair/1)
    |> Enum.into(%{})
  end

  defp deserialize_key_value_pair({name, value}) do
    {deserialize_key(name), deserialize_value(value)}
  end

  defp deserialize_value(key_values_map = %{}), do: deserialize_key_values(key_values_map)
  defp deserialize_value(value_list) when is_list(value_list) do
    Enum.map(value_list, &deserialize_value/1)
  end
  defp deserialize_value(value), do: value

  defp detect_data_type(%{"type" => _, "attributes" => _}), do: Resource
  defp detect_data_type(%{"type" => _, "relationships" => _}), do: Resource
  defp detect_data_type(%{"type" => _, "links" => _}), do: Resource
  defp detect_data_type(%{"type" => _, "meta" => _}), do: Resource
  defp detect_data_type(%{"type" => _}), do: ResourceId
end
