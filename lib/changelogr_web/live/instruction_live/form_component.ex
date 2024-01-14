defmodule ChangelogrWeb.InstructionLive.FormComponent do
  use ChangelogrWeb, :live_component

  alias Changelogr.Augmentations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage instruction records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="instruction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:prompt]} type="text" label="Prompt" />
        <.input field={@form[:model]} type="text" label="Model" />
        <.input field={@form[:json]} type="checkbox" label="Json" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Instruction</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{instruction: instruction} = assigns, socket) do
    changeset = Augmentations.change_instruction(instruction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"instruction" => instruction_params}, socket) do
    changeset =
      socket.assigns.instruction
      |> Augmentations.change_instruction(instruction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"instruction" => instruction_params}, socket) do
    save_instruction(socket, socket.assigns.action, instruction_params)
  end

  defp save_instruction(socket, :edit, instruction_params) do
    case Augmentations.update_instruction(socket.assigns.instruction, instruction_params) do
      {:ok, instruction} ->
        notify_parent({:saved, instruction})

        {:noreply,
         socket
         |> put_flash(:info, "Instruction updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_instruction(socket, :new, instruction_params) do
    case Augmentations.create_instruction(instruction_params) do
      {:ok, instruction} ->
        notify_parent({:saved, instruction})

        {:noreply,
         socket
         |> put_flash(:info, "Instruction created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
