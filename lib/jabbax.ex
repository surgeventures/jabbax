defmodule Jabbax do
  alias Jabbax.{Serializer, Deserializer}

  def decode!(input) do
    input
    |> Application.get_env(:jabbax, :json_decoder).decode!
    |> Deserializer.call
  end

  def encode!(input) do
    input
    |> Serializer.call
    |> Application.get_env(:jabbax, :json_encoder).encode!
  end

  def encode_to_iodata!(input) do
    input
    |> Serializer.call
    |> Application.get_env(:jabbax, :json_encoder).encode_to_iodata!
  end
end
