require 'rails_helper'

RSpec.describe Assignment, type: :model do
  fixtures :assignments, :groupings, :group_assignments, :organizations, :users

  it_behaves_like 'a default scope where deleted_at is not present'

  describe 'slug uniqueness' do
    it 'verifes that the slug is unique even if the titles are unique' do
      assignment = assignments(:private_assignment)

      new_assignment_params = {
        creator: assignment.creator,
        organization: assignment.organization,
        title: assignment.slug.tr('-', ' ')
      }

      new_assignment = Assignment.new(new_assignment_params)

      expect { new_assignment.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'when the title is updated' do
    subject { assignments(:private_assignment) }

    it 'updates the slug' do
      subject.update_attributes(title: 'New Title')
      expect(subject.slug).to eql('new-title')
    end
  end

  describe 'uniqueness of title across organization' do
    let(:assignment)       { assignments(:private_assignment) }
    let(:group_assignment) { group_assignments(:private_group_assignment) }

    it 'validates that a GroupAssignment in the same organization does not have the same title' do
      assignment.title = group_assignment.title

      validation_message = 'Validation failed: Your assignment title must be unique'
      expect { assignment.save! }.to raise_error(ActiveRecord::RecordInvalid, validation_message)
    end
  end

  describe 'uniqueness of title across application' do
    let(:private_assignment) { assignments(:private_assignment) }
    let(:public_assignment)  { assignments(:public_assignment)  }

    it 'allows two organizations to have the same Assignment title and slug' do
      private_assignment.update_attributes(title: public_assignment.title)

      expect(private_assignment.title).to eql(public_assignment.title)
      expect(private_assignment.slug).to eql(public_assignment.slug)
    end
  end

  describe '#public?' do
    it 'returns true if Assignments public_repo column is true' do
      expect(assignments(:public_assignment).public?).to be(true)
    end

    it 'returns false if Assignments public_repo column is false' do
      expect(assignments(:private_assignment).public?).to be(false)
    end
  end

  describe '#private?' do
    it 'returns true if Assignments public_repo column is false' do
      expect(assignments(:private_assignment).private?).to be(true)
    end

    it 'returns false if Assignments public_repo column is true' do
      expect(assignments(:public_assignment).private?).to be(false)
    end
  end
end
