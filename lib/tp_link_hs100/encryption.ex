defmodule TpLinkHs100.Encryption do
  @moduledoc "Encryption of messages send via UDP to TP-Link devices."

  @doc """
  Encrypting a given binary.
  """
  def encrypt(input, firstKey \\ 0xAB) when is_binary(input) and firstKey in 0..255, do: do_encrypt(firstKey, input, [])

  defp do_encrypt(_key, <<>>, output) do
    output
    |> Enum.reverse
    |> :binary.list_to_bin
  end
  defp do_encrypt(key, <<byte, rest::binary>>, output) do
    use Bitwise

    byte_xor = bxor(byte, key)

    do_encrypt(
      byte_xor,            # new key
      rest,                # encrypt rest of binary
      [byte_xor | output]  # reverse list of encrypted bytes
    )
  end


  @doc """
  Decrypting a encrypted binary.
  """
  def decrypt(input, firstKey \\ 0x2B) when is_binary(input) and firstKey in 0..255, do: do_decrypt(firstKey, input, [])

  defp do_decrypt(_key, <<>>, output) do
    output
    |> Enum.reverse
    |> :binary.list_to_bin
  end
  defp do_decrypt(key, <<byte, rest::binary>>, output) do
    use Bitwise

    byte_xor = rem(bxor(byte, key), 128) # this encryption does only support ASCII, so there are no bytes > 127

    do_decrypt(
      byte,                # new key
      rest,                # rest of bytes to decrypt
      [byte_xor | output]  # reversed list of plain bytes.
    )
  end

end
