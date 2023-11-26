defmodule ChangelogrWeb.ChangelogLive.Row do
  use ChangelogrWeb, :live_component

  import Ecto.Query
  alias Changelogr.Repo
  alias Changelogr.Kernels

  @impl true
  def render(assigns) do
    # IO.inspect(assigns)

    ~H"""
    <div
      class="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700"
      id={@id}
    >
      <h2 class="font-mono"><%= @id %></h2>
      <a href={~p"/changelogs/#{@changelog}"}>
        <h3 class="text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          <%= @changelog.kernel_version %>
        </h3>
      </a>
      <p class="font-normal text-gray-700 dark:text-gray-400">
        <%= Timex.from_now(@changelog.date) %>
      </p>
      <div class="sr-only">
        <.link navigate={~p"/changelogs/#{@changelog}"}><%= gettext("Show") %></.link>
      </div>

      <div class="flex flex-row gap-2 justify-end">
        <%= if not @changelog.processed do %>
          <.button
            class="bg-green-500"
            phx-click={JS.push("start_processing", value: %{id: @changelog.id})}
            tooltip="Process"
            id={"#{@changelog.id}-process"}
          >
            <Icons.FontAwesome.Solid.gears class="w-6 h-6" fill="white" />
            <span class="sr-only">Process</span>
          </.button>
        <% else %>
          <.button
            class="bg-neutral-200 hover:pointer-events-auto"
            tooltip="Already processed!"
            id={"#{@changelog.id}-processed"}
          >
            <Icons.FontAwesome.Solid.check class="w-6 h-6" fill="grey" />
            <span class="sr-only">Processed</span>
          </.button>
        <% end %>

        <%= if @changelog.processed do %>
          <.button
            class="bg-amber-500"
            phx-click="wipe"
            phx-target={@myself}
            phx-value-id={@changelog.id}
            tooltip="Wipe commits"
            id={"#{@id}-wipe"}
          >
            <Icons.FontAwesome.Solid.broom class="w-6 h-6" fill="white" />
            <span class="sr-only">Wipe</span>
          </.button>
        <% else %>
          <.button
            class="bg-red-500"
            phx-click={JS.push("delete", value: %{id: @changelog.id}) |> hide("##{@changelog.id}")}
            data-confirm={gettext("Are you sure?")}
            tooltip="Delete"
            id={"#{@changelog.id}-delete"}
          >
            <Icons.FontAwesome.Regular.trash_can class="w-6 h-6" fill="white" />
            <span class="sr-only">Delete</span>
          </.button>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("wipe", %{"id" => id}, socket) do
    IO.inspect(id)
    changelog = Kernels.get_changelog!(id)

    commits =
      changelog
      |> Repo.preload(:commits)
      |> Map.get(:commits)

    commits
    |> Enum.map(&Repo.delete(&1))

    changelog
    |> Ecto.Changeset.change(%{processed: false})
    |> Repo.update!()

    {:noreply, socket}
  end
end
