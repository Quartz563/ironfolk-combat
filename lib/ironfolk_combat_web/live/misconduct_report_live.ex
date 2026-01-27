defmodule IronfolkCombatWeb.MisconductReportLive do
  use IronfolkCombatWeb, :live_view
  alias IronfolkCombat.Misconduct
  alias IronfolkCombat.Misconduct.MisconductReport
  alias IronfolkCombat.Members

  @impl true
  def mount(_params, _session, socket) do
    changeset = MisconductReport.changeset(%MisconductReport{}, %{})

    socket =
      socket
      |> assign(:page_title, "Ironfolk Code of Conduct Reporting Form")
      |> assign(:form, to_form(changeset))
      |> assign(:submitted, false)
      |> assign(:identification_method, "anonymous")
      |> assign(:ifn_input, "")
      |> assign(:ifn_lookup_result, nil)
      |> assign(:violation_text, "")
      |> assign(:has_immediate_threat, false)
      |> assign(:is_custom_violation, false)
      |> assign(:is_affected_other, false)
      |> assign(:is_follow_up, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("change_identification", %{"method" => method}, socket) do
    {:noreply, assign(socket, :identification_method, method)}
  end

  @impl true
  def handle_event("toggle_immediate_threat", %{"value" => value}, socket) do
    has_immediate_threat = value == "yes"
    {:noreply, assign(socket, :has_immediate_threat, has_immediate_threat)}
  end

  @impl true
  def handle_event(
        "toggle_custom_violation",
        %{"misconduct_report" => %{"violation_type" => value}},
        socket
      ) do
    has_custom_violation = value == "CUSTOM"
    {:noreply, assign(socket, :is_custom_violation, has_custom_violation)}
  end

  @impl true
  def handle_event("update_ifn_input", %{"ifn_lookup" => ifn}, socket) do
    {:noreply, assign(socket, :ifn_input, ifn)}
  end

  @impl true
  def handle_event("lookup_ifn", _params, socket) do
    ifn = Map.get(socket.assigns, :ifn_input, "")
    IO.inspect(ifn)

    if ifn == "" do
      {:noreply, put_flash(socket, :error, "Please enter an IFN first.")}
    else
      case Members.get_member_by_ifn(String.upcase(ifn)) do
        nil ->
          IO.puts(ifn)

          {:noreply,
           socket
           |> assign(:ifn_lookup_result, :not_found)
           |> put_flash(:error, "IFN not found. Please check your Ironfolk ID Number.")}

        member ->
          {:noreply,
           socket
           |> assign(:ifn_lookup_result, {:found, member})
           |> clear_flash()}
      end
    end
  end

  @impl true
  def handle_event("update_violation_text", %{"text" => text}, socket) do
    {:noreply, assign(socket, :violation_text, text)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    # Extract the main report params for the changeset
    report_params = Map.get(params, "misconduct_report", %{})

    # Update UI state variables to prevent them from resetting
    # IMPORTANT: Track immediate_threat from form to ensure severity calculation works
    has_immediate_threat =
      case report_params["immediate_threat"] do
        "true" -> true
        true -> true
        _ -> false
      end

    socket =
      socket
      |> assign(
        :identification_method,
        Map.get(params, "identification_method", socket.assigns.identification_method)
      )
      |> assign(:is_custom_violation, report_params["violation_type"] == "CUSTOM")
      |> assign(:is_affected_other, report_params["affected"] == "OTHER")
      |> assign(:has_immediate_threat, has_immediate_threat)

    # Process the changeset for the rest of the form
    changeset =
      %MisconductReport{}
      |> MisconductReport.changeset(report_params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset.errors, label: "CHANGESET ERRORS")
    IO.inspect(changeset.valid?, label: "IS VALID?")
    IO.inspect(has_immediate_threat, label: "HAS IMMEDIATE THREAT")
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("submit", %{"misconduct_report" => params}, socket) do
    # 1. Clean up Violation Text
    params =
      if params["violation_type"] != "CUSTOM",
        do: Map.put(params, "violation_text", nil),
        else: params

    # 2. Handle Identification logic
    params =
      case socket.assigns.identification_method do
        "anonymous" ->
          params |> Map.put("name", "ANON") |> Map.put("email", "")

        "ifn" ->
          case socket.assigns.ifn_lookup_result do
            {:found, member} ->
              params
              |> Map.put("name", "#{member.first_name} #{member.last_name}")
              |> Map.put("email", member.email)

            _ ->
              params |> Map.put("name", "ANON") |> Map.put("email", "")
          end

        "manual" ->
          params
      end

    # 3. Get immediate threat status from socket (now properly tracked)
    has_threat = socket.assigns.has_immediate_threat
    params = Map.put(params, "immediate_threat", has_threat)

    # 4. Assess Severity based on violation type and immediate threat
    severity =
      Misconduct.assess_severity(
        Map.get(params, "violation_type", ""),
        has_threat
      )

    params = Map.put(params, "severity", severity)

    IO.inspect(has_threat, label: "SUBMITTING WITH IMMEDIATE THREAT")
    IO.inspect(severity, label: "CALCULATED SEVERITY")

    # 5. Database Attempt
    case Misconduct.create_report(params) do
      {:ok, _report} ->
        {:noreply,
         socket
         |> assign(:submitted, true)
         |> put_flash(:info, "Your report has been submitted. Thank you.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: "INSERTION ERRORS")

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(:error, "Something went wrong! Please try again.")}
    end
  end

  @impl true
  def handle_event("submit_another", _params, socket) do
    changeset = MisconductReport.changeset(%MisconductReport{}, %{})

    {:noreply,
     socket
     |> assign(:submitted, false)
     |> assign(:form, to_form(changeset))
     |> assign(:identification_method, "ANON")
     |> assign(:ifn_lookup_result, nil)
     |> assign(:violation_text, "")
     |> assign(:has_immediate_threat, false)
     |> clear_flash()}
  end
end
