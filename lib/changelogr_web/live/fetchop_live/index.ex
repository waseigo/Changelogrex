defmodule ChangelogrWeb.FetchopLive.Index do
  use ChangelogrWeb, :live_view

  alias Changelogr.Fetchops
  alias Changelogr.Fetchops.Fetchop

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :fetchops, Fetchops.list_fetchops())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Fetchop")
    |> assign(:fetchop, Fetchops.get_fetchop!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Fetchop")
    |> assign(:fetchop, %Fetchop{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Fetchops")
    |> assign(:fetchop, nil)
  end

  @impl true
  def handle_info({ChangelogrWeb.FetchopLive.FormComponent, {:saved, fetchop}}, socket) do
    {:noreply, stream_insert(socket, :fetchops, fetchop)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fetchop = Fetchops.get_fetchop!(id)
    {:ok, _} = Fetchops.delete_fetchop(fetchop)

    {:noreply, stream_delete(socket, :fetchops, fetchop)}
  end
end
