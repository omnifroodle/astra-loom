defmodule Mix.Tasks.Loom.Init do
  use Mix.Task
  require Logger
  @messages_schema %{
    columnDefinitions: [
      %{name: "thread", static: false, typeDefinition: "varchar"},
      %{name: "id", static: false, typeDefinition: "timeuuid"},
      %{name: "user", static: false, typeDefinition: "varchar"},
      %{name: "added", static: false, typeDefinition: "timestamp"},
      %{name: "message", static: false, typeDefinition: "varchar"},
      %{
        name: "other_threads",
        static: false,
        typeDefinition: "frozen<set<varchar>>"
      },
      %{name: "picture", static: false, typeDefinition: "varchar"}
    ],
    name: "messages",
    primaryKey: %{clusteringKey: ["id", "user"], partitionKey: ["thread"]},
    tableOptions: %{
      clusteringExpression: [
        %{column: "id", order: "ASC"},
        %{column: "user", order: "ASC"}
      ],
      defaultTimeToLive: 0
    }
  }
  
  @shortdoc "Setup Astra tables for the app"
  def run(_) do
    keyspace = "loom"
    Mix.Task.run("app.start")

    check_for_keyspace(keyspace)
    check_for_messages_table(keyspace, "messages")
    create_users_collection(keyspace)

  end
  
  def check_for_keyspace(keyspace) do
    case Astra.Schema.Rest.get_keyspaces do
      {:ok, keyspaces} -> 
        Logger.info "checking keyspace"
        if !Enum.any?(keyspaces, &(match?(%{name: ^keyspace}, &1))) do
          Logger.error "Keyspace '#{keyspace}' does not exist"
          exit 1
        end
      other ->
        Logger.error  "an unexpected error occured #{other}"
        exit 1
    end
  end

  def check_for_messages_table(keyspace, table) do
    case Astra.Schema.Rest.get_tables(keyspace) do
      {:ok, tables} ->
        Logger.info "checking for '#{table}' table"
        if !Enum.any?(tables, &(match?(%{name: ^table}, &1))) do
          Logger.info "creating table '#{table}'"
          {:ok, _} = Astra.Schema.Rest.create_table(keyspace, @messages_schema)
          Logger.info "finished creating table '#{table}'"
        else
          Logger.info "table '#{table}' found"
        end
      other ->
        Logger.error  "an unexpected error occured #{other}"
        exit 1
    end
  end
  
  def create_users_collection(namespace) do
    Logger.info "creating 'users' collection"
    {:ok, %{documentId: docid}} = Astra.Document.post_doc(namespace, "users", %{name: "dummy"})
    {:ok, _} = Astra.Document.delete_doc(namespace, "users", docid)
    Logger.info "finished creating 'users' collection"
  end
end