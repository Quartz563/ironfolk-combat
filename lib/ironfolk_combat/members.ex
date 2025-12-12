defmodule IronfolkCombat.Members do
  @moduledoc """
  The Members context - Handles member management and IFN generation
  """

  import Ecto.Query, warn: false
  alias IronfolkCombat.Repo
  alias IronfolkCombat.Members.Member
  alias IronfolkCombat.Signups.Signup

  @doc """
  Generates the next available IronFolk Number (IFN)
  Format(IFN-XXXX)
  """
  def generate_ifn do
    last_member =
      Member
      |> order_by(desc: :id)
      |> limit(1)
      |> Repo.one()

    next_number =
      case last_member do
        nil ->
          1

        member ->
          case Regex.run(~r/IFN-(\d+)/, member.ifn) do
            [_, num_str] -> String.to_integer(num_str) + 1
            _ -> 1
          end
      end

    "IFN-#{String.pad_leading(Integer.to_string(next_number), 4, "0")}"
  end

  @doc """
  Creates a member from an approved signup.
  Automatically generates an IFN.
  """
  def create_member_from_signup(%Signup{} = signup) do
    ifn = generate_ifn()

    attrs = %{
      ifn: ifn,
      first_name: signup.first_name,
      last_name: signup.last_name,
      email: signup.email,
      phone: signup.phone,
      status: "active",
      signup_id: signup.id
    }

    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, member} = result ->
        # Update the signup with the IFN and member_id
        Ecto.Changeset.change(signup, ifn: ifn, member_id: member.id)
        |> Repo.update()

        result

      error ->
        error
    end
  end

  @doc """
  Gets a member by IFN
  """
  def get_member_by_ifn(ifn) do
    Repo.get_by(Member, ifn: ifn)
  end

  @doc """
  Gets a member by their IFN, raises if not found.
  """
  def get_member_by_ifn!(ifn) do
    Repo.get_by!(Member, ifn: ifn)
  end

  def get_member(id) do
    Repo.get_by(Member, id: id)
  end

  def get_member!(id) do
    Repo.get_by!(Member, id: id)
  end

  def get_member_by_email(email) do
    Repo.get_by(Member, email: String.downcase(String.trim(email)))
  end

  def search_member_by_name(full_name) when is_binary(full_name) do
    name_parts =
      full_name
      |> String.trim()
      |> String.split(~r/\s+/, parts: 2)

    case name_parts do
      [first_name] ->
        # Only first name provided
        Member
        |> where([m], ilike(m.first_name, ^"%#{first_name}%"))
        |> limit(1)
        |> Repo.one()

      [first_name, last_name] ->
        # Both names provided
        Member
        |> where(
          [m],
          ilike(m.first_name, ^"%#{first_name}%") and ilike(m.last_name, ^"%#{last_name}%")
        )
        |> limit(1)
        |> Repo.one()

      _ ->
        nil
    end
  end

  def list_members(opts \\ []) do
    status = Keyword.get(opts, :status, :all)

    Member
    |> filter_by_status(status)
    |> order_by([m], asc: m.ifn)
    |> Repo.all()
  end

  defp filter_by_status(query, :all), do: query
  defp filter_by_status(query, status), do: where(query, [m], m.status == ^status)

  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  def deactivate_member(%Member{} = member) do
    update_member(member, %{status: "inactive"})
  end

  def extend_membership(%Member{} = member, months \\ 1) do
    current_expiry = member.membership_expires_at || Date.utc_today()

    new_expiry =
      current_expiry
      |> Date.add(months * 30)

    update_member(member, %{membership_expires_at: new_expiry})
  end

  def membership_active?(%Member{membership_expires_at: nil}), do: false

  def membership_active?(%Member{membership_expires_at: expiry}) do
    Date.compare(expiry, Date.utc_today()) in [:gt, :eq]
  end
end
