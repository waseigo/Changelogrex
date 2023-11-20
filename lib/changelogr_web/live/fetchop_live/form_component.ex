defmodule ChangelogrWeb.FetchopLive.FormComponent do
  use ChangelogrWeb, :live_component

  alias Changelogr.Fetchops

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage fetchop records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="fetchop-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:timestamp]} type="datetime-local" label="Timestamp" />
        <.input field={@form[:status]} type="number" label="Status" />
        <.input field={@form[:errors]} type="text" label="Errors" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Fetchop</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{fetchop: fetchop} = assigns, socket) do
    changeset = Fetchops.change_fetchop(fetchop)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"fetchop" => fetchop_params}, socket) do
    changeset =
      socket.assigns.fetchop
      |> Fetchops.change_fetchop(fetchop_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"fetchop" => fetchop_params}, socket) do
    save_fetchop(socket, socket.assigns.action, fetchop_params)
  end

  defp save_fetchop(socket, :edit, fetchop_params) do
    case Fetchops.update_fetchop(socket.assigns.fetchop, fetchop_params) do
      {:ok, fetchop} ->
        notify_parent({:saved, fetchop})

        {:noreply,
         socket
         |> put_flash(:info, "Fetchop updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_fetchop(socket, :new, fetchop_params) do
    case Fetchops.create_fetchop(fetchop_params) do
      {:ok, fetchop} ->
        notify_parent({:saved, fetchop})

        {:noreply,
         socket
         |> put_flash(:info, "Fetchop created successfully")
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
