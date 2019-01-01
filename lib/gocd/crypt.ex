defmodule GoCD.Crypt do
  @moduledoc false

  require Logger

  @doc ~S"""
  Decrypt a GoCD secure variable.

  Currently supports:
    - AES
    - DES

  Note: DES has been replaced with AES in version 17 and will be deprecated in 18.
  """
  @spec decrypt(String.t(), map) :: {:ok, String.t()} | {:error, atom}
  def decrypt("AES:" <> iv_and_data, ciphers), do: aes_decrypt(iv_and_data, ciphers.aes)
  def decrypt(des, ciphers), do: des_decrypt(des, ciphers.des)

  @doc ~S"""
  Encrypt GoCD encrypted variable.
  """
  @spec encrypt(String.t(), map) :: {:ok, String.t()} | {:error, atom}
  def encrypt(value, ciphers) do
    cond do
      _aes = ciphers.aes ->
        {:ok, value}

      _des = ciphers.des ->
        Logger.warn(fn ->
          "GoCD: Encrypting with DEPRECATED `des` cipher. Please upgrade to `aes`."
        end)

        {:ok, value}

      :no_ciphers ->
        {:error, :no_ciphers_given}
    end
  end

  @spec aes_decrypt(String.t(), binary | nil) :: {:ok, String.t()} | {:error, atom}
  defp aes_decrypt(_data, nil), do: {:error, :missing_aes_cipher}

  defp aes_decrypt(data, cipher) do
    with [iv, data_base64] <- String.split(data, ":", trim: true),
         {:ok, iv} <- Base.decode64(iv),
         {:ok, data_bin} <- Base.decode64(data_base64),
         decrypted <- :crypto.block_decrypt(:aes_cbc128, cipher, iv, data_bin),
         padding <- :binary.last(decrypted) do
      {:ok, :binary.part(decrypted, 0, byte_size(decrypted) - padding)}
    else
      error = {:error, _} -> error
      :error -> {:error, :invalid_aes_encoding}
      _ -> {:error, :invalid_aes_secret}
    end
  end

  @spec des_decrypt(String.t(), binary | nil) :: {:ok, String.t()} | {:error, atom}
  defp des_decrypt(_data, nil), do: {:error, :missing_des_cipher}

  defp des_decrypt(data, cipher) do
    with {:ok, bin} <- Base.decode64(data),
         decrypted <- :crypto.block_decrypt(:des_cbc, cipher, <<0, 0, 0, 0, 0, 0, 0, 0>>, bin),
         padding <- :binary.last(decrypted) do
      {:ok, :binary.part(decrypted, 0, byte_size(decrypted) - padding)}
    end
  end
end
