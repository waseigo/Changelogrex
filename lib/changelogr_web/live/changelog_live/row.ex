defmodule ChangelogrWeb.ChangelogLive.Row do
  use ChangelogrWeb, :live_component

  import Ecto.Query
  alias Changelogr.Repo
  alias Changelogr.Kernels

  @impl true
  def mount(socket) do
    IO.inspect(self(), label: "MOUNT")

    socket =
      socket
      |> assign(total: nil, processed: nil, running: false, task_ref: nil)

    IO.inspect(socket)
    {:ok, socket}
  end

  # @impl true
  # def update(assigns, socket) do
  #   IO.inspect(self(), label: "UPDATE")
  #   socket = assign(socket, assigns)
  #   {:ok, socket}
  # end

  @impl true
  def render(assigns) do
    # IO.inspect(assigns)
    IO.inspect(self(), label: "RENDER")

    ~H"""
    <div
      class="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700"
      id={@id}
    >
      <h2 class="font-mono"><%= @id %></h2>
      <a href={~p"/changelogs/#{@changelog}"}>
        <h3 class="text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          <%= @changelog.id %>
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
            phx-click="process"
            phx-target={@myself}
            phx-value-id={@changelog.id}
            tooltip="Process"
            id={"#{@changelog.id}-process"}
          >
            <%= if @running do %>
              <.spinner />
            <% else %>
              <Icons.FontAwesome.Solid.gears class="w-6 h-6" fill="white" />
              <span class="sr-only">Process</span>
            <% end %>
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
    changelog = Kernels.get_changelog!(id)

    commits =
      changelog
      |> Repo.preload(:commits)
      |> Map.get(:commits)

    commits
    |> Enum.map(&Repo.delete(&1))

    changelog =
      changelog
      |> Ecto.Changeset.change(%{processed: false})
      |> Repo.update!()

    IO.inspect(changelog)

    # send(self(), {:wiped_changelog, changelog})

    {:noreply, assign(socket, changelog: changelog)}
  end

  @impl true
  def handle_event("process", %{"id" => id}, socket) do
    task = Task.async(fn -> process_changelog(id, socket) end)

    {:noreply, assign(socket, running: true, task_ref: task.ref)}
  end

  def process_changelog(id, socket) do
    changelog = Kernels.get_changelog!(id)

    r = Changelogr.one(changelog.id)

    r
    |> Enum.each(fn x ->
      Ecto.build_assoc(changelog, :commits, %{
        # commit: x.commit,
        id: x.commit,
        title: x.title,
        body: x.body
      })
      |> Repo.insert!()
    end)

    changelog =
      changelog
      |> Ecto.Changeset.change(%{processed: true})
      |> Repo.update!()
  end
end
