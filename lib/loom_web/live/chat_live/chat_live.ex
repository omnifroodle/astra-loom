defmodule LoomWeb.ChatLive do
  use Phoenix.LiveView
  alias LoomWeb.Presence

  def mount(_params, session, socket) do
    # grab the user's information from the session
    {:ok, resource, _} = Loom.Guardian.resource_from_token(session["guardian_default_token"])
    # pull the users thread settings
    {:ok, threads} = Loom.Thread.get_threads(resource["sub"])

    # if we don't have messages yet, lets load them.
    # Reminder that mount is called twice and we only want to do this once.
    socket = if !Map.has_key?(socket, :messages) do
      socket = assign(socket, messages: [])
      socket = Enum.reduce(threads, socket, fn {name, _}, soc ->
        watch_thread(name, soc, nil)
      end)
    end

    {:ok, assign(socket,
                  message: "",
                  resource: resource,
                  threads: threads,
                  targets: ["lobby"]
                )}
  end

  # handle a new message sent from another web session
  def handle_info(%{payload: %{message: _} = payload}, socket) do
    {:noreply, assign(socket, messages: sort_messages(socket.assigns[:messages] ++ [payload]))}
  end

  # handle a person actively watching of ignoring a thread
  def handle_info(
    %{event: "presence_diff", payload: %{joins: _joins, leaves: _leaves}},
    socket
  ) do
    {:noreply, socket}
  end

  # handle a submitting a message to a thread
  def handle_event("send", payload, socket) do
    message = %Loom.Message{
      other_threads: Enum.map(socket.assigns.targets, &("t:#{&1}")), # t for topic, more to come
      user: socket.assigns[:resource]["name"],
      message: payload["message"],
      picture: socket.assigns[:resource]["picture"]
    }
    {:ok, saved_messages} = Loom.Message.insert_message(message)
    for thread <- saved_messages.other_threads do
      LoomWeb.Endpoint.broadcast(thread, "shout", message)
    end
    {:noreply, socket}
  end

  # handle message validate as it is typed
  def handle_event("validate", %{"message" => message}, socket) do
    tags = case Regex.scan(~r/#(\w+)/, message) do
      [] ->
        ["lobby"]
      other ->
        Enum.map(other, &List.last(&1))
    end
    {:noreply, assign(socket, targets: tags)}
  end

  # handle a change to a thread (active/de-activated)
  def handle_event("thread", event, socket) do
    threads = socket.assigns[:threads]
    resource = socket.assigns[:resource]
    thread = threads[event["name"]]

    socket = watch_thread(event["name"], socket, thread)
    {:ok, _ } = Loom.Thread.update_thread(resource["sub"], event["name"], !thread["enabled"])

    # prep the new threads list to add back to the socket
    threads = Map.put(threads, event["name"], %{"enabled" => !thread["enabled"]})
    {:noreply, assign(socket, threads: threads)}
  end

  # used by the view to decide if a message should be visiable in the DOM
  def show_message?(message, threads) do
    active_threads = Enum.reject(threads, fn {_, x} -> Map.get(x, "enabled") == false end)
                    |> Enum.map(fn { y, _} -> "t:" <> y end)
    intersection = message.other_threads -- active_threads
    intersection != message.other_threads
  end

  defp watch_thread(name, socket, _ = nil) do
    full_name = "t:" <> name
    resource = socket.assigns[:resource]

    # start listening for updates on the thread
    LoomWeb.Endpoint.subscribe(full_name)
    presence_info = %{
      online_at: :os.system_time(:milli_seconds),
      uuid: resource["uuid"],
      name: resource["name"],
      picture: resource["picture"]
    }
    Presence.track(self(), full_name, socket.id, presence_info)

    messages = socket.assigns[:messages] ++ Loom.Message.get_messages(full_name)
    assign(socket, messages: sort_messages(messages))
  end
  defp watch_thread(_, s, _), do: s

  defp sort_messages(messages) do
    messages
      |> Enum.sort(&(&1.added < &2.added))
      |> Enum.uniq_by(&(&1.id))
  end
end
