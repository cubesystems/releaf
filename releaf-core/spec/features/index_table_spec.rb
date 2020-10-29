require 'rails_helper'
feature "Index tables" do
  background do
    auth_as_user
    publisher = create(:publisher, title: "ABC books")
    author = create(:author, publisher: publisher)
    another_author = create(:author, name: "Steve", publisher: nil)
    @book_1 = create(:book, title: "good book", author: author)
    @book_2 = create(:book, title: "steevs book", author: another_author)
  end

  scenario "shows books author publisher title" do
    visit admin_books_path

    within ".table.books thead tr" do
      cells = [
        "Title", "Year", "Author", "Genre", "Active", "Published at",
        "Price", "Stars", "Description", "Author publisher title"
      ]
      expect(page).to have_cells_text(cells, type: "th")
    end

    within ".table.books tbody" do
      within "tr[data-id='#{@book_1.id}']" do
        cells = ["good book", "", "Aleksandrs Lielais", "", "", "No", "", "", "", "ABC books"]
        expect(page).to have_cells_text(cells)
      end

      within "tr[data-id='#{@book_2.id}']" do
        cells = ["steevs book", "", "Steve Lielais", "", "", "No", "", "", "", ""]
        expect(page).to have_cells_text(cells)
      end
    end
  end
end
