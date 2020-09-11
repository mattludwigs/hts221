defprotocol HTS221.Register do
  @moduledoc """
  Protocol for turning a data structure into an IO request that a transport can
  use to read and/or write to the HTS221
  """

  alias HTS221.{IORead, IOWrite}

  @doc """
  Make the data structure into an `HTS221.IORead`

  If the register should not be read return `{:error, :access_error}`.
  """
  @spec read(t()) :: {:ok, IORead.t()} | {:error, :access_error}
  def read(register)

  @doc """
  Make the data structure into an `HTS221.IOWrite`

  If the register should not be written return `{:error, :access_error}`.
  """
  @spec write(t()) :: {:ok, IOWrite.t()} | {:error, :access_error}
  def write(register)
end
