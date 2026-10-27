defmodule IronfolkCombat.Emails.MemberEmail do
  @moduledoc """
  Email templates for member communications.
  """
  import Swoosh.Email

  @from_email {"Ironfolk Combat", "noreply@ironfolkcombat.nz"}

  @doc """
  Sends an email containing the member's IFN details.
  """
  def ifn_retrieval_email(member) do
    new()
    |> to({member.first_name <> " " <> member.last_name, member.email})
    |> from(@from_email)
    |> subject("Your Ironfolk ID Number")
    |> html_body(ifn_retrieval_html(member))
    |> text_body(ifn_retrieval_text(member))
  end

  @doc """
  Sends a welcome email to a new member who has been approved.
  Includes their IFN, welcome information, and next steps.
  """
  def welcome_email(member) do
    new()
    |> to({member.first_name <> " " <> member.last_name, member.email})
    |> from(@from_email)
    |> subject("Welcome to Ironfolk Combat!")
    |> html_body(welcome_html(member))
    |> text_body(welcome_text(member))
  end

  @doc """
  Sends a confirmation email when someone submits a signup (before approval).
  """
  def signup_confirmation_email(signup) do
    new()
    |> to({signup.first_name <> " " <> signup.last_name, signup.email})
    |> from(@from_email)
    |> subject("Thanks for Signing Up to Ironfolk Combat!")
    |> html_body(signup_confirmation_html(signup))
    |> text_body(signup_confirmation_text(signup))
  end

  # ============================================
  # IFN RETRIEVAL EMAIL TEMPLATES
  # ============================================

  defp ifn_retrieval_html(member) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Your Ironfolk ID Number</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
        .ifn-box { background: white; border: 2px solid #ec4899; border-radius: 8px; padding: 20px; margin: 20px 0; text-align: center; }
        .ifn-number { font-size: 32px; font-weight: bold; color: #ec4899; font-family: monospace; letter-spacing: 2px; }
        .button { display: inline-block; background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 14px; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Your Ironfolk ID Number</h1>
      </div>
      <div class="content">
        <p>Hi #{member.first_name},</p>

        <p>Here are your Ironfolk Combat membership details:</p>

        <div class="ifn-box">
          <p style="margin: 0 0 10px 0; color: #666; font-size: 14px;">Your Ironfolk ID Number</p>
          <div class="ifn-number">#{member.ifn}</div>
        </div>

        <p><strong>Member Name:</strong> #{member.first_name} #{member.last_name}</p>
        <p><strong>Email:</strong> #{member.email}</p>
        <p><strong>Status:</strong> #{String.capitalize(member.status)}</p>
        #{membership_status_html(member)}

        <p>Keep this number safe - you'll need it for:</p>
        <ul>
          <li>Making membership payments</li>
        </ul>

        <p>If you have any questions, don't hesitate to get in touch!</p>

        <p>See you at training,<br>
        <strong>The Ironfolk Combat Team</strong></p>
      </div>
      <div class="footer">
        <p>Ironfolk Combat - Wellington Longsword Club<br>
        <a href="https://ironfolkcombat.nz">ironfolkcombat.nz</a></p>
      </div>
    </body>
    </html>
    """
  end

  defp ifn_retrieval_text(member) do
    """
    YOUR IRONFOLK ID NUMBER

    Hi #{member.first_name},

    Here are your Ironfolk Combat membership details:

    IRONFOLK ID NUMBER: #{member.ifn}

    Member Name: #{member.first_name} #{member.last_name}
    Email: #{member.email}
    Status: #{String.capitalize(member.status)}
    #{membership_status_text(member)}

    Keep this number safe - you'll need it for:
    - Making membership payments

    If you have any questions, don't hesitate to get in touch!

    See you at training,
    The Ironfolk Combat Team

    ---
    Ironfolk Combat - Wellington Longsword Club
    https://ironfolkcombat.nz
    """
  end

  # ============================================
  # WELCOME EMAIL TEMPLATES
  # ============================================

  defp welcome_html(member) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Welcome to Ironfolk Combat!</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
        .ifn-box { background: white; border: 2px solid #ec4899; border-radius: 8px; padding: 20px; margin: 20px 0; text-align: center; }
        .ifn-number { font-size: 32px; font-weight: bold; color: #ec4899; font-family: monospace; letter-spacing: 2px; }
        .info-box { background: white; border-left: 4px solid #ec4899; padding: 15px; margin: 15px 0; }
        .button { display: inline-block; background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 10px 5px; }
        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 14px; }
        h2 { color: #ec4899; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>🗡️ Welcome to Ironfolk Combat! 🗡️</h1>
      </div>
      <div class="content">
        <p>Hi #{member.first_name},</p>

        <p>Welcome to Ironfolk Combat! We're thrilled to have you join our community. Your signup has been approved and you're now an official member of Wellington's queer friendly historic fencing club.</p>

        <div class="ifn-box">
          <p style="margin: 0 0 10px 0; color: #666; font-size: 14px;">Your Ironfolk ID Number</p>
          <div class="ifn-number">#{member.ifn}</div>
          <p style="margin: 10px 0 0 0; color: #666; font-size: 12px;">Keep this number safe - you'll need it for payments and events!</p>
        </div>

        <h2>📍 Training Locations & Times</h2>

        <div class="info-box">
          <p><strong>Thursday Evenings</strong><br>
          6:30 PM - 8:30 PM<br>
          Te Whaea - National Dance & Drama Centre<br>
          11 Hutchison Road, Newtown, Wellington 6021</p>
        </div>

        <div class="info-box">
          <p><strong>Saturday Mornings</strong><br>
          1:00 PM - 4:00 PM<br>
          Petone Central School<br>
          16 Britannia Street, Petone, Wellington 5012</p>
        </div>

        <h2>🎯 What to Bring</h2>
        <ul>
          <li><strong>Comfortable athletic clothing</strong> - Something you can move freely in</li>
          <li><strong>Athletic shoes</strong> - Closed-toe required</li>
          <li><strong>Water bottle</strong> - Stay hydrated!</li>
          <li><strong>Enthusiasm</strong> - Most important! 😊</li>
        </ul>

        <p><strong>Note:</strong> We provide all protective equipment and training weapons for beginners, so don't worry about buying gear right away.</p>

        <h2>🛡️ Safety First</h2>
        <p>Before your first session, please review our safety policies:</p>
        <ul>
          <li>Code of Conduct</li>
          <li>Relationship Policy</li>
          <li>Equipment Guidelines</li>
        </ul>
        <p>These are available on our website's <a href="https://ironfolkcombat.nz/resources">Resources page</a>.</p>

        <h2>💳 Membership Payments</h2>
        <p>Now that you've finished your trial weeks and become a full member, you can continue training with a paid membership. Payment will soon be handled though the website, but for now</p>

        <div style="text-align: center; margin: 30px 0;">
          <a href="https://ironfolkcombat.nz/resources" class="button">View Member Resources</a>
          <a href="https://ironfolkcombat.nz/faq" class="button">Read Our FAQ</a>
        </div>

        <h2>📱 Stay Connected</h2>
        <p>Follow us on social media and join our community:</p>
        <ul>
          <li><strong>Facebook:</strong> Ironfolk Combat Group</li>
          <li><strong>Instagram:</strong> @ironfolk_fencing</li>
        </ul>

        <h2>❓ Questions?</h2>
        <p>If you have any questions before your first session, feel free to reach out via email or come chat with us at training. Everyone at Ironfolk is friendly and happy to help!</p>

        <p style="margin-top: 30px;">We can't wait to see you at training!</p>

        <p><strong>Welcome to the Ironfolk family! ⚔️🏳️‍🌈</strong></p>

        <p>See you on the fencing floor,<br>
        <strong>The Ironfolk Combat Team</strong></p>
      </div>
      <div class="footer">
        <p>Ironfolk Combat - Wellington Longsword Club<br>
        <a href="https://ironfolkcombat.nz">ironfolkcombat.nz</a></p>
        <p style="font-size: 12px; margin-top: 15px;">Your IFN: #{member.ifn}</p>
      </div>
    </body>
    </html>
    """
  end

  defp welcome_text(member) do
    """
    WELCOME TO IRONFOLK COMBAT!

    Hi #{member.first_name},

    Welcome to Ironfolk Combat! We're thrilled to have you join our community. Your signup has been approved and you're now an official member of Wellington's LGBTQ+ friendly HEMA club.

    YOUR IRONFOLK ID NUMBER: #{member.ifn}
    (Keep this number safe - you'll need it for payments and events!)

    TRAINING LOCATIONS & TIMES

    Thursday Evenings
    6:30 PM - 8:30 PM
    Te Whaea - National Dance & Drama Centre
    11 Hutchison Road, Newtown, Wellington 6021

    Saturday Mornings
    01:00 PM - 04:00 PM
    Petone Central School
    16 Britannia Street, Petone, Wellington 5012

    WHAT TO BRING
    - Comfortable athletic clothing
    - Athletic shoes (closed-toe required)
    - Water bottle
    - Enthusiasm!

    We provide all protective equipment and training weapons for beginners.

    SAFETY FIRST
    Before your first session, please review our safety policies:
    - Code of Conduct
    - Relationship Policy
    - Equipment Guidelines

    Available at: https://ironfolkcombat.nz/resources

    MEMBERSHIP PAYMENTS
    You'll need to pay your club fees. Details are on the website.

    STAY CONNECTED
    - Facebook: Ironfolk Combat Group
    - Instagram: @ironfolk_fencing

    QUESTIONS?
    If you have any questions before your first session, feel free to reach out via email or come chat with us at training.

    We can't wait to see you at training!

    Welcome to the Ironfolk family!

    See you on the fencing floor,
    The Ironfolk Combat Team

    ---
    Ironfolk Combat - Wellington Longsword Club
    https://ironfolkcombat.nz

    Your IFN: #{member.ifn}
    """
  end

  # ============================================
  # SIGNUP CONFIRMATION EMAIL TEMPLATES
  # ============================================

  defp signup_confirmation_html(signup) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Thanks for Signing Up!</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
        .info-box { background: white; border-left: 4px solid #ec4899; padding: 15px; margin: 15px 0; }
        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 14px; }
        h2 { color: #ec4899; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Thanks for Signing Up!</h1>
      </div>
      <div class="content">
        <p>Hi #{signup.first_name},</p>

        <p>Thank you for your interest in joining Ironfolk Combat! We've received your signup and our team will review it shortly.</p>

        <h2>What Happens Next?</h2>

        <div class="info-box">
          <p><strong>1. Review</strong><br>
          Our team will review your application within 1-2 business days.</p>
        </div>

        <div class="info-box">
          <p><strong>2. Approval Email</strong><br>
          Once approved, you'll receive a welcome email with your Ironfolk ID Number (IFN) and all the details you need for your first session.</p>
        </div>

        <h2>📍 Training Times</h2>
        <p><strong>Thursdays:</strong> 6:00 PM - 8:00 PM at Te Whaea - National Dance & Drama Centre<br>
        <strong>Saturdays:</strong> 1:00 PM - 4:00 PM at Petone Central School</p>

        <h2>🎯 While You Wait</h2>
        <p>Feel free to explore our website to learn more about:</p>
        <ul>
          <li>What is HEMA?</li>
          <li>Our training approach</li>
          <li>Equipment requirements</li>
          <li>Club policies and safety guidelines</li>
        </ul>

        <p>Visit: <a href="https://ironfolkcombat.nz">ironfolkcombat.nz</a></p>

        <h2>❓ Questions?</h2>
        <p>If you have any questions while waiting for approval, don't hesitate to reach out to us via email or social media.</p>

        <p style="margin-top: 30px;">We're excited to welcome you to Ironfolk Combat!</p>

        <p>Best regards,<br>
        <strong>The Ironfolk Combat Team</strong></p>
      </div>
      <div class="footer">
        <p>Ironfolk Combat - Wellington Longsword Club<br>
        <a href="https://ironfolkcombat.nz">ironfolkcombat.nz</a></p>
      </div>
    </body>
    </html>
    """
  end

  defp signup_confirmation_text(signup) do
    """
    THANKS FOR SIGNING UP!

    Hi #{signup.first_name},

    Thank you for your interest in joining Ironfolk Combat! We've received your signup and our team will review it shortly.

    WHAT HAPPENS NEXT?

    1. REVIEW
    Our team will review your application within 1-2 business days.

    2. APPROVAL EMAIL
    Once approved, you'll receive a welcome email with your Ironfolk ID Number (IFN) and all the details you need for your first session.

    3. COME TRAIN!
    Show up to your first training session - we'll have everything you need!

    TRAINING TIMES
    Thursdays: 6:00 PM - 8:00 PM at Te Whaea - National Dance & Drama Centre
    Saturdays: 01:00 PM - 04:00 PM at Petone Central School

    WHILE YOU WAIT
    Feel free to explore our website to learn more about:
    - What is HEMA?
    - Our training approach
    - Equipment requirements
    - Club policies and safety guidelines

    Visit: https://ironfolkcombat.nz

    QUESTIONS?
    If you have any questions while waiting for approval, don't hesitate to reach out to us via email or social media.

    We're excited to welcome you to Ironfolk Combat!

    Best regards,
    The Ironfolk Combat Team

    ---
    Ironfolk Combat - Wellington Longsword Club
    https://ironfolkcombat.nz
    """
  end

  # ============================================
  # HELPER FUNCTIONS
  # ============================================

  defp membership_status_html(member) do
    case member.membership_expires_at do
      nil ->
        "<p><strong>Membership:</strong> Not yet activated - complete your trial sessions and join as a full member!</p>"

      expiry_date ->
        if IronfolkCombat.Members.membership_active?(member) do
          "<p><strong>Membership Expires:</strong> #{Date.to_string(expiry_date)}</p>"
        else
          "<p><strong>Membership Status:</strong> <span style='color: #dc2626;'>Expired on #{Date.to_string(expiry_date)}</span><br>
          <a href='https://ironfolkcombat.nz/payment'>Renew your membership</a></p>"
        end
    end
  end

  defp membership_status_text(member) do
    case member.membership_expires_at do
      nil ->
        "Membership: Not yet activated - complete your trial sessions!"

      expiry_date ->
        if IronfolkCombat.Members.membership_active?(member) do
          "Membership Expires: #{Date.to_string(expiry_date)}"
        else
          "Membership Status: EXPIRED on #{Date.to_string(expiry_date)}\nRenew at: https://ironfolkcombat.nz/payment"
        end
    end
  end
end
