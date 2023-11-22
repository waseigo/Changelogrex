defmodule ChangelogrWeb.CommitLive.Show do
  use ChangelogrWeb, :live_view

  alias Changelogr.Commits
  alias Changelogr.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:commit, Commits.get_commit!(id)  |> Repo.preload(:changelog))}
  end

  defp page_title(:show), do: "Show Commit"
  defp page_title(:edit), do: "Edit Commit"
end
