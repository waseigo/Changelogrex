defmodule ChangelogrWeb.CommitLive.Index do
  use ChangelogrWeb, :live_view

  alias Changelogr.Repo
  alias Changelogr.Commits
  alias Changelogr.Commits.Commit

  @impl true
  def mount(_params, _session, socket) do
    # params = %{page: 1, page_size: 5}
    # {:ok, {commits, meta}} = Commits.list_commits(params)
    # {:ok, stream(socket, :commits, commits |> Repo.preload(:changelog))}
    {:ok, stream(socket, :commits, %{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    IO.inspect(params)
    # params =
    #   case params do
    #     %{} -> %{page: 1, page_size: 5}
    #     _ -> params
    #   end
    # IO.inspect(params)

    case Commits.list_commits(params) do
      {:ok, {commits, meta}} ->
        commits = commits |> Repo.preload(:changelog)

        IO.inspect(meta)
        # meta = %Flop.Meta{meta | opts: [page_links: :hide]} # doesn't work

        {:noreply,
         socket
         |> assign(:meta, meta)
         |> stream(:commits, commits, reset: true)}

      {:error, _meta} ->
        # This will reset invalid parameters. Alternatively, you can assign
        # only the meta and render the errors, or you can ignore the error
        # case entirely.
        {:noreply, push_navigate(socket, to: ~p"/commits")}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Commit")
    |> assign(:commit, Commits.get_commit!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Commit")
    |> assign(:commit, %Commit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Commits")
    |> assign(:commit, nil)
  end

  @impl true
  def handle_info({ChangelogrWeb.CommitLive.FormComponent, {:saved, commit}}, socket) do
    {:noreply, stream_insert(socket, :commits, commit)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    commit = Commits.get_commit!(id)
    {:ok, _} = Commits.delete_commit(commit)

    {:noreply, stream_delete(socket, :commits, commit)}
  end
end
