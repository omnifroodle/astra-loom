defmodule Loom.Message do
  #TODO factor this out
  defstruct user: "", message: "", id: "", added: "", thread: "t:lobby", picture: "", other_threads: []

  def get_messages(thread) do
    {:ok, messages} = Astra.Rest.get_row("loom", "messages", thread)
    messages
  end

  def insert_message(message) do
    timed_message = %{message | id: UUID.uuid1, added: NaiveDateTime.to_iso8601(NaiveDateTime.utc_now) <> "Z"}
    sanitized_message = %{timed_message | message: HtmlSanitizeEx.strip_tags(message.message)}
    for thread <- sanitized_message.other_threads do
      #TODO, this would be much better in parallel
      {:ok, _} = Astra.Rest.add_row("loom", "messages", %{sanitized_message | thread: thread})
    end
    {:ok, sanitized_message}
  end

end
