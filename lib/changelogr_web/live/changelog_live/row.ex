defmodule ChangelogrWeb.ChangelogLive.Row do
  use ChangelogrWeb, :live_component

  def render(assigns) do
    IO.inspect(assigns)

    ~H"""
    <div class="max-w-xs grow p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700" id={@changelog.id}>
      <a href={~p"/changelogs/#{@changelog}"}>
        <h3 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          <%= @changelog.kernel_version %>
        </h3>
      </a>
      <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
      <%= Timex.from_now(@changelog.date) %>
      </p>
      <div class="sr-only">
        <.link navigate={~p"/changelogs/#{@changelog}"}><%= gettext("Show") %></.link>
      </div>

      <%= if not @changelog.processed do %>
      <.button
        phx-click={JS.push("start_processing", value: %{id: @changelog.id})}
      >
        <Icons.FontAwesome.Solid.gears class="w-6 h-6" fill="white" />
        <span class="sr-only">Process</span>
      </.button>
      <% else %>
      <Icons.FontAwesome.Solid.check class="w-6 h-6 m-2" fill="grey" />
      <span class="sr-only">Processed</span>

    <% end %>

    <.button
    phx-click={JS.push("delete", value: %{id: @changelog.id}) |> hide("##{@changelog.id}")}
    data-confirm={gettext("Are you sure?")}
  >
    <Icons.FontAwesome.Regular.trash_can class="w-6 h-6" fill="white" />
    <span class="sr-only">Delete</span>
  </.button>



    </div>
    """
  end
end
