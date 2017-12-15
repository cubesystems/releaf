require 'rails_helper'
describe "Nodes services (copy, move)" do

  describe "Moving" do
    before do
      @home_page_node = create(:home_page_node, locale: "lv")
      @home_page_node_2 = create(:home_page_node, locale: "en")
      @text_page_node_3 = create(:text_page_node, parent_id: @home_page_node_2.id)
      @text_page_node_4 = create(:text_page_node, parent_id: @text_page_node_3.id)

      # it is important to reload nodes, otherwise associations will return empty set
      @home_page_node.reload
      @home_page_node_2.reload
      @text_page_node_3.reload
      @text_page_node_4.reload
    end

    context "when one of children becomes invalid" do
      before do
        @text_page_node_4.name = nil
        @text_page_node_4.save(validate: false)
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_page_node_3.move(@home_page_node.id) }.to raise_error ActiveRecord::RecordInvalid
      end

      it "raises error on node being moved, even tought descendant has error" do
        begin
          @text_page_node_3.move(@home_page_node.id)
        rescue ActiveRecord::RecordInvalid => e
          expect( e.record ).to eq @text_page_node_3
        end

        expect(@text_page_node_3.errors.messages).to eq(name: [], base: ["descendant invalid"])
      end
    end

    context "when moving existing node to other nodes child's position" do
      it "changes parent_id" do
        expect{ @text_page_node_3.move(@home_page_node.id) }.to change{ Node.find(@text_page_node_3.id).parent_id }.from(@home_page_node_2.id).to(@home_page_node.id)
      end
    end

    context "when moving to self child's position" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.move(@text_page_node_3.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when passing nil as target node" do
      it "updates parent_id" do
        allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
        @home_page_node.destroy
        expect{ @text_page_node_3.move(nil) }.to change { Node.find(@text_page_node_3.id).parent_id }.to(nil)
      end
    end

    context "when passing nonexistent target node's id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.move(998123) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

  end

  describe "Node copying", create_nodes: true do
    before create_nodes: true do
      @home_page_node = create(:home_page_node, locale: "lv")
      @home_page_node_2 = create(:home_page_node, locale: "en")
      @text_page_node_3 = create(:text_page_node, parent_id: @home_page_node_2.id)
      @text_page_node_4 = create(:text_page_node, parent_id: @text_page_node_3.id)
      @text_page_node_5 = create(:text_page_node, parent_id: @text_page_node_4.id)

      # it is important to reload nodes, otherwise associations will return empty set
      @home_page_node.reload
      @home_page_node_2.reload
      @text_page_node_3.reload
      @text_page_node_4.reload
    end

    context "when one of children becomes invalid" do
      before do
        @text_page_node_4.name = nil
        @text_page_node_4.save(validate: false)
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_page_node_3.copy(@home_page_node.id) }.to raise_error ActiveRecord::RecordInvalid
      end

      it "raises error on node being copied" do
        begin
          @text_page_node_3.copy(@home_page_node.id)
        rescue ActiveRecord::RecordInvalid => e
          expect( e.record ).to eq @text_page_node_3
        end
        expect(@text_page_node_3.errors.messages).to eq(name: [], base: ["descendant invalid"])
      end

      it "doesn't create any new nodes" do
        expect do
          begin
            @text_page_node_3.copy(@home_page_node.id)
          rescue ActiveRecord::RecordInvalid
          end
        end.to_not change { Node.count }
      end

      it "doesn't update settings timestamp" do
        expect( Node ).to_not receive(:updated)
        begin
          @text_page_node_3.copy(@home_page_node.id)
        rescue ActiveRecord::RecordInvalid
        end
      end

    end


    context "with corect parent_id" do
      it "creates node along with descendant nodes" do
        expect{ @text_page_node_3.copy(@home_page_node.id) }.to change{ Node.count }.by( @text_page_node_3.descendants.size + 1 )
      end

      it "correctly copies attributes" do
        allow( @text_page_node_3 ).to receive(:children).and_return([@text_page_node_4])
        allow( @text_page_node_4 ).to receive(:children).and_return([@text_page_node_5])

        @text_page_node_3.update_attribute(:active, false)
        @text_page_node_4.update_attribute(:active, false)

        allow( @text_page_node_3 ).to receive(:attributes_to_copy).and_return(["name", "parent_id", "content_type"])

        @text_page_node_3.copy(@home_page_node.id)

        @node_2_copy = @home_page_node.children.first
        @node_3_copy = @node_2_copy.children.first
        @node_4_copy = @node_3_copy.children.first

        # new nodes by default are active, however we stubbed
        # #attributes_to_copy of @test_node_2 to not return active attribute
        # Also we updated @test_node_2#active to be false.
        # However copy is active, because active attribute wasn't copied
        expect( @node_2_copy ).to be_active
        # for copy of @text_page_node_3 active attribute was copied however, as it
        # should have been
        expect( @node_3_copy ).to_not be_active
        expect( @node_4_copy ).to be_active

        expect( @node_2_copy.name ).to eq @text_page_node_3.name
        expect( @node_3_copy.name ).to eq @text_page_node_4.name
        expect( @node_4_copy.name ).to eq @text_page_node_5.name
      end

      it "updates settings timestamp only once" do
        expect( Node ).to receive(:updated).once.and_call_original
        @text_page_node_3.copy(@home_page_node.id)
      end

      context "when parent_id is nil" do
        it "creates new node" do
          allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
          expect{ @text_page_node_3.copy(nil) }.to change{ Node.count }.by(3)
        end
      end

      context "when copying root nodes", create_nodes: false do
        context "when root locale uniqueness is validated" do
          it "resets locale to nil" do
            @text_page_node = create(:home_page_node, locale: 'en')
            allow_any_instance_of(Node).to receive(:validate_root_locale_uniqueness?).and_return(true)
            @text_page_node.copy(nil)
            expect( Node.last.locale ).to eq nil
          end
        end

        context "when root locale uniqueness is not validated" do
          it "doesn't reset locale to nil" do
            @text_page_node = create(:home_page_node, locale: 'en')
            allow_any_instance_of(Node).to receive(:validate_root_locale_uniqueness?).and_return(false)
            @text_page_node.copy(nil)
            expect( Node.last.locale ).to eq 'en'
          end
        end
      end
    end

    context "with nonexistent parent_id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_page_node_3.copy(99991) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with same parent_id as node.id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.copy(@text_page_node_3.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when copying to child node" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.copy(@text_page_node_4.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "slug handling" do

      before do
        @nodes = {}

        @nodes[:parent_one] = create(:text_page_node, parent: @home_page_node)
        @nodes[:parent_two] = create(:text_page_node, parent: @home_page_node)

        @nodes[:child]      = create(:text_page_node, parent: @nodes[:parent_one], slug: "child-slug")
        @nodes[:grandchild] = create(:text_page_node, parent: @nodes[:child],      slug: "grandchild-slug")
        @nodes[:great_grandchild] = create(:text_page_node, parent: @nodes[:grandchild], slug: "great-grandchild-slug")

        @nodes[:other_child] = create(:text_page_node, parent: @nodes[:parent_two], slug: "other-child-slug")
      end

      context "when copying a node tree to a parent that already has a child node with the same slug" do
        it "adds incremental index to the slug of the main copied node, preserving slugs of deeper descendants" do
          @nodes[:other_child].update! slug: "child-slug"
          @nodes[:child].copy( @nodes[:parent_two].id )

          copy = @nodes[:parent_two].children.last

          expect(copy.slug).to eq "child-slug-1"
          expect(copy.children.map(&:slug)).to eq ["grandchild-slug"]
          expect(copy.children.first.children.map(&:slug)).to eq ["great-grandchild-slug"]

        end
      end

      context "when copying a node tree to a parent that does not have a child node with the same slug" do
        it "copies slugs without any changes" do
          @nodes[:child].copy( @nodes[:parent_two].id )
          copy = @nodes[:parent_two].children.last

          expect(copy.slug).to eq "child-slug"

          expect(copy.children.map(&:slug)).to eq ["grandchild-slug"]
          expect(copy.children.first.children.map(&:slug)).to eq ["great-grandchild-slug"]
        end
      end

    end

  end


  feature "Deep copying of content nodes", js: true do

    let(:node_class) { Node }
    let(:locale) { "en" }

    background do
      Rails.cache.clear
      # preload ActsAsNode classes
      Rails.application.eager_load!

      create(:home_page_node, name: "Root page", locale: "en", slug: "en")
      auth_as_user
    end

    def expect_different_values original, copy
      expect(original).to be_present
      expect(copy).to be_present
      expect(original).to_not eq copy
    end

    scenario "Deep copying of content nodes with nested associations and files" do
      visit "/admin/nodes/"
      open_toolbox("Add child", node_class.first, ".view-index .collection li")

      dummy_file_path = File.expand_path('../fixtures/dummy.png', __dir__)

      within('.dialog.content-type.initialized') do
        click_link "Banner page"
      end

      expect(page).to have_css('input[type="text"][name="resource[content_type]"][value="Banner page"]')

      fill_in 'Name', with: "Banner page"
      fill_in 'Slug', with: "banner-page"

      attach_file('Top banner', dummy_file_path)
      attach_file('Bottom banner', dummy_file_path)

      within('section.nested[data-name="banner_groups"]') do
        add_nested_item "banner_groups", 0 do
          fill_in "Title", with: "Banner group 1 title"

          within('section.nested[data-name="banners"]') do
            add_nested_item "banners", 0 do
              attach_file('Image', dummy_file_path)
              fill_in "Url", with: "Banner-1-url"
            end
            add_nested_item "banners", 1 do
              attach_file('Image', dummy_file_path)
              fill_in "Url", with: "Banner-2-url"
            end
          end
        end

        add_nested_item "banner_groups", 1 do
          fill_in "Title", with: "Banner group 2 title"
        end
      end

      wait_for_all_richtexts
      save_and_check_response "Create succeeded"

      open_toolbox("Copy")

      within('.dialog.copy.initialized') do
        find('label', text: "Root page").click
        click_button "Copy"
      end

      expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: "Copy succeeded")

      # verify record count in db
      expect(node_class.where(content_type: 'BannerPage').count).to eq 2
      expect(BannerGroup.count).to eq 4
      expect(Banner.count).to eq 4


      # verify that direct and nested files are duplicated correctly
      [
        { original: BannerPage.first, copy: BannerPage.last, accessor: :top_banner    },
        { original: BannerPage.first, copy: BannerPage.last, accessor: :bottom_banner },
        {
          original: BannerPage.first.banner_groups.first.banners.first,
          copy:     BannerPage.last.banner_groups.first.banners.first,
          accessor: :image
        }
      ].each do |entry|
        original = entry[:original]
        copy     = entry[:copy]
        accessor = entry[:accessor]
        expect(original.id).to_not eq copy.id

        # verify that uids exist and are different
        expect_different_values(original.send("#{accessor}_uid"), copy.send("#{accessor}_uid"))

        # verify files exist and are different
        original_file = original.send(accessor)
        copied_file = copy.send(accessor)

        expect_different_values(original_file.path, copied_file.path)
        expect(original_file.path).to start_with Dragonfly.app.datastore.root_path
        expect(copied_file.path).to   start_with Dragonfly.app.datastore.root_path
        expect(File.exist?(original_file.path)).to be true
        expect(File.exist?(copied_file.path)).to be true
      end


      # change values in the copied node to make sure associations are not linked
      original_id = node_class.where(content_type: "BannerPage").order(:item_position).first.id
      copy_id     = node_class.where(content_type: "BannerPage").order(:item_position).last.id
      expect(copy_id).to_not eq original_id

      visit "/admin/nodes/#{copy_id}/edit/"

      within('section.nested[data-name="banner_groups"]') do
        within('.item[data-name="banner_groups"][data-index="0"]') do
          expect(page).to have_field('Title', with: 'Banner group 1 title')
          fill_in "Title", with: "Copied banner group 1 title"

          within('.item[data-name="banners"][data-index="0"]') do
            expect(page).to have_field('Url', with: 'Banner-1-url')
            fill_in "Url", with: "Copied-banner-1-url"
          end
          within('.item[data-name="banners"][data-index="1"]') do
            expect(page).to have_field('Url', with: 'Banner-2-url')
            fill_in "Url", with: "Copied-banner-2-url"
          end
        end
        within('.item[data-name="banner_groups"][data-index="1"]') do
          expect(page).to have_field('Title', with: 'Banner group 2 title')
          fill_in "Title", with: "Copied banner group 2 title"
        end
      end

      copied_file_urls = {
        top_banner:     find('.field[data-name="top_banner"]').find_link[:href],
        bottom_banner:  find('.field[data-name="bottom_banner"]').find_link[:href],
        nested_banner:  find('.item[data-name="banner_groups"][data-index="0"] .item[data-name="banners"][data-index="0"] .field[data-name="image"]').find_link[:href]
      }

      wait_for_all_richtexts
      save_and_check_response "Update succeeded"

      # verify that the original banner page still has the old values
      visit "/admin/nodes/#{original_id}/edit/"

      within('section.nested[data-name="banner_groups"]') do
        within('.item[data-name="banner_groups"][data-index="0"]') do
          expect(page).to have_field('Title', with: 'Banner group 1 title')

          within('.item[data-name="banners"][data-index="0"]') do
            expect(page).to have_field('Url', with: 'Banner-1-url')
          end
          within('.item[data-name="banners"][data-index="1"]') do
            expect(page).to have_field('Url', with: 'Banner-2-url')
          end
        end
        within('.item[data-name="banner_groups"][data-index="1"]') do
          expect(page).to have_field('Title', with: 'Banner group 2 title')
        end
      end

      original_file_urls = {
        top_banner:     find('.field[data-name="top_banner"]').find_link[:href],
        bottom_banner:  find('.field[data-name="bottom_banner"]').find_link[:href],
        nested_banner:  find('.item[data-name="banner_groups"][data-index="0"] .item[data-name="banners"][data-index="0"] .field[data-name="image"]').find_link[:href]
      }

      # make sure that original and copied file urls are different and working
      original_file_urls.each do |key, original_url|
        expect_different_values(original_url, copied_file_urls[key])

        [original_url, copied_file_urls[key]].each do |file_url|
          visit file_url
          expect(page.status_code).to eq 200
        end
      end

    end

  end



end
