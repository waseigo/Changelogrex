defmodule ChangelogrWeb.ChangelogLive.Index do
  use ChangelogrWeb, :live_view

  alias Changelogr.Kernels
  alias Changelogr.Kernels.Changelog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :changelogs, Kernels.list_changelogs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Changelog")
    |> assign(:changelog, Kernels.get_changelog!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Changelog")
    |> assign(:changelog, %Changelog{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Changelogs")
    |> assign(:changelog, nil)
  end

  @impl true
  def handle_info({ChangelogrWeb.ChangelogLive.FormComponent, {:saved, changelog}}, socket) do
    {:noreply, stream_insert(socket, :changelogs, changelog)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    changelog = Kernels.get_changelog!(id)
    {:ok, _} = Kernels.delete_changelog(changelog)

    {:noreply, stream_delete(socket, :changelogs, changelog)}
  end

  def handle_event("process", %{"id" => id}, socket) do
    changelog = Kernels.get_changelog!(id)

    IO.inspect(changelog)

    # {:ok, _} = Kernels.delete_changelog(changelog)
    r = Changelogr.one(changelog.kernel_version)

    r
    |> Enum.map(fn x ->
      Ecto.build_assoc(changelog, :commits, %{
        commit: x.commit,
        body: x.body |> Enum.intersperse("\n\n") |> List.to_string()
      })
      |> Changelogr.Repo.insert!()
    end)

    {:noreply, push_navigate(socket, to: ~p"/commits")}
  end
end
