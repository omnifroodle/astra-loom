defmodule Loom.Message do
  #TODO factor this out
  defstruct user: "", message: "", id: "", added: "", thread: "room:lobby", picture: ""

  def get_messages(thread) do
    {:ok, messages} = Astra.Rest.get_row("loom", "messages", thread)
    #TODO should these be coerced into Message structs?
    messages
  end

  def insert_message(message) do
    timed_message = %{message | id: UUID.uuid1, added: NaiveDateTime.to_iso8601(NaiveDateTime.utc_now) <> "Z"}
    sanitized_message = %{timed_message | message: HtmlSanitizeEx.strip_tags(message.message)}
    {:ok, _} = Astra.Rest.add_row("loom", "messages", sanitized_message)
    {:ok, sanitized_message}
    # columns = map_columns(sanitized_message)
    # {:ok, token} = Loom.Astra.TokenManager.get_token()
    # case Loom.Astra.Actions.upsert(token, "messages", columns) do
    #   {:ok, _} ->
    #     {:ok, sanitized_message}
    #   {:error, message} ->
    #     IO.inspect message
    #     {:error, "could not upsert"}
    # end
  end

end
