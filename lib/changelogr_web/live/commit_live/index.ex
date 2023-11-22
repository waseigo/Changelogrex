defmodule ChangelogrWeb.CommitLive.Index do
  use ChangelogrWeb, :live_view

  alias Changelogr.Repo
  alias Changelogr.Commits
  alias Changelogr.Commits.Commit

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :commits, Commits.list_commits() |> Repo.preload(:changelog))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
