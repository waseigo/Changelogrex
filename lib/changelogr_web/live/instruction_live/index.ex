defmodule ChangelogrWeb.InstructionLive.Index do
  use ChangelogrWeb, :live_view

  alias Changelogr.Augmentations
  alias Changelogr.Augmentations.Instruction

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :instructions, Augmentations.list_instructions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Instruction")
    |> assign(:instruction, Augmentations.get_instruction!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Instruction")
    |> assign(:instruction, %Instruction{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Instructions")
    |> assign(:instruction, nil)
  end

  @impl true
  def handle_info({ChangelogrWeb.InstructionLive.FormComponent, {:saved, instruction}}, socket) do
    {:noreply, stream_insert(socket, :instructions, instruction)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    instruction = Augmentations.get_instruction!(id)
    {:ok, _} = Augmentations.delete_instruction(instruction)

    {:noreply, stream_delete(socket, :instructions, instruction)}
  end
end
