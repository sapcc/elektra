require "spec_helper"

describe FlashHelper do
  describe "#flash_entry" do
    describe "default" do
      it "returns the default flash if default_{key}" do
        expect(flash_entry("default_success", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "success",
              value: "default flash",
            },
          },
        )
        expect(flash_entry("default_info", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "info",
              value: "default flash",
            },
          },
        )
        expect(flash_entry("default_notice", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "notice",
              value: "default flash",
            },
          },
        )
        expect(flash_entry("default_warning", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "warning",
              value: "default flash",
            },
          },
        )
        expect(flash_entry("default_danger", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "danger",
              value: "default flash",
            },
          },
        )
        expect(flash_entry("default_alert", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "alert",
              value: "default flash",
            },
          },
        )
        expect(flash_entry("default_error", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "error",
              value: "default flash",
            },
          },
        )
      end

      it "returns the default flash if key NO matches any of 'success', 'info', 'notice', 'warning', 'danger', 'alert', 'error'" do
        expect(flash_entry("huhu_test", "default flash")).to eq(
          {
            partial: "application/flash_default",
            locals: {
              key: "huhu_test",
              value: "default flash",
            },
          },
        )
      end
    end

    describe "dismissible flash" do
      it "return a dismissible flash if key matches any of 'success', 'info', 'notice', 'warning', 'danger', 'alert', 'error'" do
        expect(flash_entry("success", "dismissible flash")).to include(
          partial: "application/flash_dismissible",
        )
        expect(flash_entry("info", "dismissible flash")).to include(
          partial: "application/flash_dismissible",
        )
        expect(flash_entry("notice", "dismissible flash")).to include(
          partial: "application/flash_dismissible",
        )
        expect(flash_entry("warning", "dismissible flash")).to include(
          partial: "application/flash_dismissible",
        )
        expect(flash_entry("danger", "dismissible flash")).to include(
          partial: "application/flash_dismissible",
        )
        expect(flash_entry("alert", "dismissible flash")).to include(
          partial: "application/flash_dismissible",
        )
        expect(flash_entry("error", "dismissible flash")).to include(
          partial: "application/flash_dismissible",
        )
      end
    end

    describe "auto dismissible flash" do
      it "return an auto dismissible flash if key matches any of 'success', 'info', 'notice'" do
        expect(flash_entry("success", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "success",
              value: "dismissible flash",
              auto_dismissible: true,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("info", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "info",
              value: "dismissible flash",
              auto_dismissible: true,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("notice", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "notice",
              value: "dismissible flash",
              auto_dismissible: true,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("warning", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "warning",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("danger", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "danger",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("alert", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "alert",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("error", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "error",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
      end
    end

    describe "keep - no auto dismisible flash" do
      it "keep auto dismissible flashes" do
        expect(flash_entry("keep_success", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "success",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("keep_info", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "info",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("keep_notice", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "notice",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        # double check the others one have not changed
        expect(flash_entry("warning", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "warning",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("danger", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "danger",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("alert", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "alert",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
        expect(flash_entry("error", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "error",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: false,
            },
          },
        )
      end
    end

    describe "html_safe flashes" do
      it "renders html safe dismissible flashes" do
        expect(flash_entry("success_htmlsafe", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "success",
              value: "dismissible flash",
              auto_dismissible: true,
              html_safe: true,
            },
          },
        )
        expect(flash_entry("info_htmlsafe", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "info",
              value: "dismissible flash",
              auto_dismissible: true,
              html_safe: true,
            },
          },
        )
        expect(flash_entry("notice_htmlsafe", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "notice",
              value: "dismissible flash",
              auto_dismissible: true,
              html_safe: true,
            },
          },
        )
        expect(flash_entry("warning_htmlsafe", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "warning",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: true,
            },
          },
        )
        expect(flash_entry("danger_htmlsafe", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "danger",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: true,
            },
          },
        )
        expect(flash_entry("alert_htmlsafe", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "alert",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: true,
            },
          },
        )
        expect(flash_entry("error_htmlsafe", "dismissible flash")).to eq(
          {
            partial: "application/flash_dismissible",
            locals: {
              key: "error",
              value: "dismissible flash",
              auto_dismissible: false,
              html_safe: true,
            },
          },
        )
      end
    end

    it "should work everything together" do
      expect(flash_entry("keep_success_htmlsafe", "dismissible flash")).to eq(
        {
          partial: "application/flash_dismissible",
          locals: {
            key: "success",
            value: "dismissible flash",
            auto_dismissible: false,
            html_safe: true,
          },
        },
      )
      expect(flash_entry("keep_info_htmlsafe", "dismissible flash")).to eq(
        {
          partial: "application/flash_dismissible",
          locals: {
            key: "info",
            value: "dismissible flash",
            auto_dismissible: false,
            html_safe: true,
          },
        },
      )
      expect(flash_entry("keep_notice_htmlsafe", "dismissible flash")).to eq(
        {
          partial: "application/flash_dismissible",
          locals: {
            key: "notice",
            value: "dismissible flash",
            auto_dismissible: false,
            html_safe: true,
          },
        },
      )
      expect(flash_entry("warning_htmlsafe", "dismissible flash")).to eq(
        {
          partial: "application/flash_dismissible",
          locals: {
            key: "warning",
            value: "dismissible flash",
            auto_dismissible: false,
            html_safe: true,
          },
        },
      )
      expect(flash_entry("danger_htmlsafe", "dismissible flash")).to eq(
        {
          partial: "application/flash_dismissible",
          locals: {
            key: "danger",
            value: "dismissible flash",
            auto_dismissible: false,
            html_safe: true,
          },
        },
      )
      expect(flash_entry("alert_htmlsafe", "dismissible flash")).to eq(
        {
          partial: "application/flash_dismissible",
          locals: {
            key: "alert",
            value: "dismissible flash",
            auto_dismissible: false,
            html_safe: true,
          },
        },
      )
      expect(flash_entry("error_htmlsafe", "dismissible flash")).to eq(
        {
          partial: "application/flash_dismissible",
          locals: {
            key: "error",
            value: "dismissible flash",
            auto_dismissible: false,
            html_safe: true,
          },
        },
      )
    end
  end
end
