require 'rails_helper'

RSpec.describe GroupAssignment, type: :model do
  fixtures :assignments, :groupings, :group_assignments, :organizations, :users

  it_behaves_like 'a default scope where deleted_at is not present'

  describe 'slug uniqueness' do
    it 'verifes that the slug is unique even if the titles are unique' do
      group_assignment = group_assignments(:private_group_assignment)

      new_group_assignment_params = {
        creator: group_assignment.creator,
        organization: group_assignment.organization,
        title: group_assignment.slug.tr('-', ' '),
        grouping: group_assignment.grouping
      }

      new_group_assignment = GroupAssignment.new(new_group_assignment_params)

      expect { new_group_assignment.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'when the title is updated' do
    subject { group_assignments(:private_group_assignment) }

    it 'updates the slug' do
      subject.update_attributes(title: 'New Title')
      expect(subject.slug).to eql('new-title')
    end
  end

  describe 'uniqueness of title across organization' do
    let(:assignment)       { assignments(:private_assignment) }
    let(:group_assignment) { group_assignments(:private_group_assignment) }

    it 'validates that an Assignment in the same organization does not have the same title' do
      group_assignment.title = assignment.title

      validation_message = 'Validation failed: Your assignment title must be unique'
      expect { group_assignment.save! }.to raise_error(ActiveRecord::RecordInvalid, validation_message)
    end
  end

  describe 'uniqueness of title across application' do
    let(:private_group_assignment) { group_assignments(:private_group_assignment) }
    let(:public_group_assignment)  { group_assignments(:public_group_assignment)  }

    it 'allows two organizations to have the same GroupAssignment title and slug' do
      private_group_assignment.update_attributes(title: public_group_assignment.title)

      expect(private_group_assignment.title).to eql(public_group_assignment.title)
      expect(private_group_assignment.slug).to eql(public_group_assignment.slug)
    end
  end

  describe '#public?' do
    it 'returns true if GroupAssignments public_repo column is true' do
      expect(group_assignments(:public_group_assignment).public?).to be(true)
    end

    it 'returns false if GroupAssignments public_repo column is false' do
      expect(group_assignments(:private_group_assignment).public?).to be(false)
    end
  end

  describe '#private?' do
    it 'returns true if GroupAssignments public_repo column is false' do
      expect(group_assignments(:private_group_assignment).private?).to be(true)
    end

    it 'returns false if GroupAssignments public_repo column is true' do
      expect(group_assignments(:public_group_assignment).private?).to be(false)
    end
  end
end
