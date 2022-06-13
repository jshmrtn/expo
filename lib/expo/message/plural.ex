defmodule Expo.Message.Plural do
  @moduledoc """
  Struct for plural messages
  """

  alias Expo.Message
  alias Expo.Util

  @type t :: %__MODULE__{
          msgid: Message.msgid(),
          msgid_plural: [Message.msgid()],
          msgstr: %{required(non_neg_integer()) => Message.msgstr()},
          msgctxt: Message.msgctxt() | nil,
          comments: [String.t()],
          extracted_comments: [String.t()],
          flags: [[String.t()]],
          previous_msgids: [[String.t()]],
          previous_msgid_plurals: [[String.t()]],
          references: [[file :: String.t() | {file :: String.t(), line :: pos_integer()}]],
          obsolete: boolean()
        }

  @enforce_keys [:msgid, :msgid_plural]
  defstruct [
    :msgid,
    :msgid_plural,
    msgstr: %{},
    msgctxt: nil,
    comments: [],
    extracted_comments: [],
    flags: [],
    previous_msgids: [],
    previous_msgid_plurals: [],
    references: [],
    obsolete: false
  ]

  @doc false
  @spec key(t()) :: {String.t(), {String.t(), String.t()}}
  def key(%__MODULE__{msgctxt: msgctxt, msgid: msgid, msgid_plural: msgid_plural} = _message),
    do:
      {IO.iodata_to_binary(msgctxt || []),
       {IO.iodata_to_binary(msgid), IO.iodata_to_binary(msgid_plural)}}

  @doc """
  Rebalances all strings

  * Put one string per newline of `msgid` / `msgid_plural` / `msgstr`
  * Put all flags onto one line
  * Put all references onto a separate line

  ### Examples

      iex> Expo.Message.Plural.rebalance(%Expo.Message.Plural{
      ...>   msgid: ["", "hello", "\\n", "", "world", ""],
      ...>   msgid_plural: ["", "hello", "\\n", "", "world", ""],
      ...>   msgstr: %{0 => ["", "hello", "\\n", "", "world", ""]},
      ...>   flags: [["one", "two"], ["three"]],
      ...>   references: [[{"one", 1}, {"two", 2}], ["three"]]
      ...> })
      %Plural{
        msgid: ["hello\\n", "world"],
        msgid_plural: ["hello\\n", "world"],
        msgstr: %{0 => ["hello\\n", "world"]},
        flags: [["one", "two", "three"]],
        references: [[{"one", 1}], [{"two", 2}], ["three"]]
      }

  """
  @spec rebalance(message :: t()) :: t()
  def rebalance(
        %__MODULE__{
          msgid: msgid,
          msgid_plural: msgid_plural,
          msgstr: msgstr,
          flags: flags,
          references: references
        } = message
      ) do
    flags =
      case List.flatten(flags) do
        [] -> []
        flags -> [flags]
      end

    %__MODULE__{
      message
      | msgid: Util.rebalance_strings(msgid),
        msgid_plural: Util.rebalance_strings(msgid_plural),
        msgstr:
          Map.new(msgstr, fn {index, strings} -> {index, Util.rebalance_strings(strings)} end),
        flags: flags,
        references: references |> List.flatten() |> Enum.map(&List.wrap/1)
    }
  end
end
