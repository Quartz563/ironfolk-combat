defmodule IronfolkCombatWeb.MisconductReportLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Misconduct
  alias IronfolkCombat.Misconduct.MisconductReport, as: Report

  @impl true
  def mount(_params, _session, socket) do
    changeset = Report.changeset(%Report{}, %{})

    socket =
      socket
      |> assign(:page_title, "Report a Misconduct Incident")
      |> assign(:form, to_form(changeset))
      |> assign(:submitted, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"misconduct_report" => misconduct_params}, socket) do
    changeset =
      %Report{}
      |> Report.changeset(misconduct_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"misconduct_report" => misconduct_params}, socket) do
    case Misconduct.create_report(misconduct_params) do
      {:ok, _report} ->
        {:noreply,
         socket
         |> assign(:submitted, true)
         |> put_flash(:info, "Misconduct report successfully submitted. Thank you.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("reset_form", _params, socket) do
    changeset = Report.changeset(%Report{}, %{})

    {:noreply,
     socket
     |> assign(
       :form,
       to_form(changeset)
       |> assign(:submitted, false)
     )}
  end
end
