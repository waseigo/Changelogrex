defmodule ChangelogrWeb.FetchopLive.Show do
  use ChangelogrWeb, :live_view

  alias Changelogr.Fetchops

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:fetchop, Fetchops.get_fetchop!(id))}
  end

  defp page_title(:show), do: "Show Fetchop"
  defp page_title(:edit), do: "Edit Fetchop"
end
