defmodule Jabbax.Serializer do
  @moduledoc false

  use Jabbax.Document
  alias Jabbax.StructureError

  def call(doc = %Document{}) do
    doc
    |> dig_and_serialize_data
    |> dig_and_serialize_included
    |> dig_and_serialize_meta
    |> dig_and_serialize_errors
    |> dig_and_serialize_links
    |> struct_to_map_with_present_keys
    |> put_empty_data
    |> put_version
  end

  def call(arg) do
    raise(StructureError, context: "document", expected: "Document", actual: arg)
  end

  defp dig_and_serialize_data(parent = %{}) do
    Map.update!(parent, :data, &serialize_data/1)
  end

  defp serialize_data(nil), do: nil
  defp serialize_data(list) when is_list(list), do: Enum.map(list, &serialize_data/1)

  defp serialize_data(resource_identifier = %ResourceId{}) do
    resource_identifier
    |> dig_and_serialize_type
    |> dig_and_serialize_id
    |> dig_and_serialize_meta
    |> struct_to_map_with_present_keys
  end

  defp serialize_data(resource_object = %Resource{}) do
    resource_object
    |> dig_and_serialize_type
    |> dig_and_serialize_id
    |> dig_and_serialize_attributes
    |> dig_and_serialize_meta
    |> dig_and_serialize_relationships
    |> dig_and_serialize_links
    |> struct_to_map_with_present_keys
  end

  defp serialize_data(arg) do
    raise(StructureError,
      context: "data",
      expected: ~w{Resource ResourceId [Resource] [ResourceId]},
      actual: arg
    )
  end

  defp dig_and_serialize_included(parent = %{}) do
    Map.update!(parent, :included, &serialize_included/1)
  end

  defp serialize_included([]), do: nil
  defp serialize_included(list) when is_list(list), do: serialize_data(list)

  defp serialize_included(arg) do
    raise(StructureError, context: "included", expected: "[Resource]", actual: arg)
  end

  defp dig_and_serialize_relationships(parent = %{}) do
    Map.update!(parent, :relationships, &serialize_relationships/1)
  end

  defp serialize_relationships(nil), do: nil
  defp serialize_relationships(relationship_map) when relationship_map == %{}, do: nil

  defp serialize_relationships(relationship_map = %{}) do
    relationship_map
    |> Enum.map(&serialize_relationship_pair/1)
    |> Enum.into(%{})
  end

  defp serialize_relationships(arg) do
    raise(StructureError, context: "relationships", expected: "%{key => Relationship}", actual: arg)
  end

  defp serialize_relationship_pair({name, relationship}) do
    {serialize_key(name), serialize_relationship(relationship)}
  end

  defp serialize_relationship(relationship = %Relationship{}) do
    relationship
    |> dig_and_serialize_data
    |> dig_and_serialize_meta
    |> dig_and_serialize_links
    |> struct_to_map_with_present_keys
    |> put_empty_data
  end

  defp serialize_relationship(data) when is_list(data) or is_map(data) do
    %{
      data: serialize_data(data)
    }
  end

  defp serialize_relationship(arg) do
    raise(StructureError, context: "relationship", expected: "Relationship", actual: arg)
  end

  defp dig_and_serialize_links(parent = %{}) do
    Map.update!(parent, :links, &serialize_links/1)
  end

  defp serialize_links(nil), do: nil
  defp serialize_links(link_map) when link_map == %{}, do: nil

  defp serialize_links(link_map = %{}) do
    link_map
    |> Enum.map(&serialize_link_pair/1)
    |> Enum.into(%{})
  end

  defp serialize_links(arg) do
    raise(StructureError, context: "links", expected: "%{key => Link}", actual: arg)
  end

  defp serialize_link_pair({name, link}) do
    {serialize_key(name), serialize_link(link)}
  end

  defp serialize_link(href) when is_binary(href), do: href
  defp serialize_link(%{href: href, meta: nil} = %Link{}) when is_binary(href), do: href

  defp serialize_link(%{href: href, meta: meta} = %Link{}) when is_binary(href) and meta == %{} do
    href
  end

  defp serialize_link(link = %{href: href} = %Link{}) when is_binary(href) do
    link
    |> dig_and_serialize_meta
    |> struct_to_map_with_present_keys
  end

  defp serialize_link(%Link{href: arg}) do
    raise(StructureError, context: "Link.href", expected: "binary", actual: arg)
  end

  defp serialize_link(arg) do
    raise(StructureError, context: "link", expected: "Link", actual: arg)
  end

  defp dig_and_serialize_errors(parent = %{}), do: Map.update!(parent, :errors, &serialize_errors/1)

  defp serialize_errors(nil), do: nil
  defp serialize_errors([]), do: nil

  defp serialize_errors(error_list) when is_list(error_list) do
    Enum.map(error_list, &serialize_error/1)
  end

  defp serialize_errors(arg) do
    raise(StructureError, context: "errors", expected: "[Error]", actual: arg)
  end

  defp serialize_error(error = %Error{}) do
    error
    |> dig_and_serialize_meta
    |> dig_and_serialize_key(:code)
    |> dig_and_serialize_status
    |> dig_and_serialize_error_source
    |> dig_and_serialize_links
    |> struct_to_map_with_present_keys
  end

  defp dig_and_serialize_status(parent = %{}), do: Map.update!(parent, :status, &serialize_status/1)

  defp serialize_status(nil), do: nil

  # Phoenix 1.6 renamed HTTP 422 from "Unprocessable Entity" to "Unprocessable Content" (RFC 9110).
  # 35+ repos across the org depend on "unprocessable-entity" string, so we hardcode it.
  # Note: 422 uses hyphen format for historical reasons, other codes use underscore.
  defp serialize_status(status) when is_atom(status),
    do: status |> Atom.to_string() |> serialize_status()

  defp serialize_status(status) when is_binary(status) do
    normalized = status |> String.downcase() |> String.replace(["-", "_"], "")

    case normalized do
      "unprocessableentity" -> "unprocessable-entity"
      "unprocessablecontent" -> "unprocessable-entity"
      _ -> status
    end
  end

  defp serialize_status(status) when is_integer(status), do: Integer.to_string(status)

  defp dig_and_serialize_error_source(parent = %{}) do
    Map.update!(parent, :source, &serialize_error_source/1)
  end

  defp serialize_error_source(nil), do: nil

  defp serialize_error_source(error_source = %ErrorSource{}) do
    error_source
    |> dig_and_serialize_key(:parameter)
    |> dig_and_serialize_key(:pointer)
    |> struct_to_map_with_present_keys
  end

  defp serialize_error_source(arg) do
    raise(StructureError, context: "error source", expected: "ErrorSource", actual: arg)
  end

  defp dig_and_serialize_attributes(parent = %{}) do
    Map.update!(parent, :attributes, &serialize_key_values/1)
  end

  defp dig_and_serialize_meta(parent = %{}) do
    Map.update!(parent, :meta, &serialize_key_values/1)
  end

  defp dig_and_serialize_type(parent = %{}), do: dig_and_serialize_key(parent, :type)

  defp dig_and_serialize_id(parent = %{}), do: Map.update!(parent, :id, &serialize_id/1)

  defp serialize_id(id) when is_integer(id), do: Integer.to_string(id)
  defp serialize_id(id) when is_binary(id), do: id

  defp serialize_id(arg) do
    raise(StructureError, context: "id", expected: ~w{binary integer}, actual: arg)
  end

  defp dig_and_serialize_key(parent = %{}, key), do: Map.update!(parent, key, &serialize_key/1)

  defp serialize_key(nil), do: nil
  defp serialize_key(key) when is_atom(key), do: key |> Atom.to_string() |> serialize_key
  defp serialize_key(key) when is_binary(key), do: String.replace(key, "_", "-")

  defp serialize_key(arg) do
    raise(StructureError, context: "key", expected: ~w{binary atom}, actual: arg)
  end

  defp serialize_key_values(nil), do: nil
  defp serialize_key_values(key_values_map) when key_values_map == %{}, do: nil

  defp serialize_key_values(key_values_map = %{}) do
    key_values_map
    |> Enum.map(&serialize_key_value_pair/1)
    |> Enum.into(%{})
  end

  defp serialize_key_values(arg) do
    raise(StructureError, context: "attributes/meta", expected: "%{key => value}", actual: arg)
  end

  defp serialize_key_value_pair({name, value}) do
    {serialize_key(name), serialize_value(value)}
  end

  defp serialize_value(value) when is_struct(value), do: value

  defp serialize_value(key_values_map) when is_map(key_values_map) do
    serialize_key_values(key_values_map)
  end

  defp serialize_value(value_list) when is_list(value_list) do
    Enum.map(value_list, &serialize_value/1)
  end

  defp serialize_value(value), do: value

  defp struct_to_map_with_present_keys(struct = %{}) do
    struct
    |> Map.from_struct()
    |> Enum.filter(fn {_, value} -> value != nil end)
    |> Enum.into(%{})
  end

  defp put_empty_data(doc = %{data: _}), do: doc
  defp put_empty_data(doc = %{meta: _}), do: doc
  defp put_empty_data(doc = %{errors: _}), do: doc
  defp put_empty_data(doc = %{}), do: Map.put(doc, :data, nil)

  defp put_version(doc = %{jsonapi: _}), do: doc
  defp put_version(doc = %{}), do: Map.put(doc, :jsonapi, %{version: "1.0"})
end
