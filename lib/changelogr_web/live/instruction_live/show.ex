defmodule ChangelogrWeb.InstructionLive.Show do
  use ChangelogrWeb, :live_view

  alias Changelogr.Augmentations

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:instruction, Augmentations.get_instruction!(id))}
  end

  defp page_title(:show), do: "Show Instruction"
  defp page_title(:edit), do: "Edit Instruction"
end
