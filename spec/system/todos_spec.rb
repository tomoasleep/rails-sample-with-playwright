require 'rails_helper'

RSpec.describe "Todos", type: :system do
  before do
    driven_by(:playwright)
  end

  before do
    # Ensure playwright page is initialized.
    Capybara.current_session.driver.send(:browser)
    Capybara.current_session.driver.with_playwright_page do |playwright_page|
      playwright_page.context.tracing.start(screenshots: true, snapshots: true)
    end
  end

  after do |example|
    Capybara.current_session.driver.with_playwright_page do |playwright_page|
      save_dir = Capybara.save_path.presence || "tmp/screenshots"
      playwright_page.context.tracing.stop(path: File.join(save_dir, "#{example.metadata[:full_description]}.zip"))
    end
  end

  it "creates a new Item" do
    visit "/todos/new"
    fill_in "Title", with: "buy a coffee"
    click_button "Create Todo"

    expect(page).to have_content("Todo was successfully created.")
    expect(page).to have_content("buy a coffee")
  end

  describe 'use playwright API' do
    it "creates a new Item" do
      # Initially, playwright page is not initialized.
      # So, you need to initialize playwright page by using capybara API.
      visit "/todos/new"
      # or initialize playwright page by following code.
      # Capybara.current_session.driver.send(:browser)

      Capybara.current_session.driver.with_playwright_page do |playwright_page|
        playwright_page.get_by_label("Title").fill("buy a coffee")
        playwright_page.get_by_role("button", name: 'Create Todo').click

        expect(playwright_page.get_by_text("Todo was successfully created.").wait_for).to be_present
        expect(playwright_page.get_by_text("buy a coffee").wait_for).to be_present
      end
    end
  end
end
