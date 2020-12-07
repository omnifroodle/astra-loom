defmodule LoomWeb.ChatLive do
  use Phoenix.LiveView
  alias LoomWeb.Presence

  def mount(_params, session, socket) do
    {:ok, resource, _} = Loom.Guardian.resource_from_token(session["guardian_default_token"])
    #threads = Loom.Thread.get_by_person(resource["sub"])
    threads = resource["threads"]
    socket = assign(socket, resource: resource, threads: threads, messages: [], targets: ["lobby"])

    socket = if connected?(socket) do
      Enum.reduce(threads, socket, fn {name, %{"enabled" => enabled}}, soc ->
        thread_changed({name, enabled}, soc)
      end)
    else
      socket
    end

    # TODO consider temporary_assigns here?  that could be tricky if we support joining multiple threads
    {:ok, assign(socket, message: "")}
  end

  def handle_info(%{payload: %{message: _} = payload}, socket) do
    {:noreply, assign(socket, messages: socket.assigns[:messages] ++ [payload])}
  end

  def handle_info(
    %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
    socket
  ) do
    {:noreply, socket}
  end

  def handle_event("send", payload, socket) do
    message = %Loom.Message{
      thread: "thread:lobby",
      user: socket.assigns[:resource]["name"],
      message: payload["message"],
      picture: socket.assigns[:resource]["picture"]
    }
    {:ok, saved_message} = Loom.Message.insert_message(message)
    LoomWeb.Endpoint.broadcast("thread:lobby", "shout", saved_message)
    {:noreply, socket}
  end

  def handle_event("validate", %{"message" => message}, socket) do
    tags = case Regex.scan(~r/#(\w+)/, message) do
      [] ->
        ["lobby"]
      other ->
        Enum.map(other, &List.last(&1))
    end
    IO.inspect tags
    {:noreply, assign(socket, targets: tags)}
  end

  def handle_event("thread", event, socket) do
    threads = socket.assigns[:threads]
    thread = threads[event["name"]]

    # update messages if needed
    socket = {event["name"], !thread["enabled"] } |>
      thread_changed(socket)
    # prep the new threads list to add back to the socket
    threads = put_in(threads, [event["name"], "enabled"], !thread["enabled"])
    {:noreply, assign(socket, threads: threads)}
  end

  defp thread_changed({name, enabled = true}, socket) do
    # other prefixes may be used later, such as 'user:'
    full_name = "thread:" <> name
    resource = socket.assigns[:resource]
    LoomWeb.Endpoint.subscribe(full_name)
    presence_info = %{
      online_at: :os.system_time(:milli_seconds),
      uuid: resource["uuid"],
      name: resource["name"],
      picture: resource["picture"]
    }
    Presence.track(
      self(),
      full_name,
      socket.id,
      presence_info
    )
    Loom.Message.get_messages(full_name)
    messages = socket.assigns[:messages] ++ Loom.Message.get_messages(full_name) |>
      Enum.sort(&(&1.added < &2.added))


    #Loom.Thread.update_thread_by_person(resource, name, true)
    assign(socket, messages: messages)
  end

  defp thread_changed({name, enabled = false}, socket) do
    full_name = "thread:" <> name
    Presence.untrack(self(), full_name, socket.id)
    LoomWeb.Endpoint.unsubscribe(full_name)
    messages = Enum.filter(socket.assigns[:messages], &(&1.thread != full_name))

    #Loom.Thread.update_thread_by_person(socket.assigns[:resource]["sub"], thread)
    assign(socket, messages: messages)
  end
end
