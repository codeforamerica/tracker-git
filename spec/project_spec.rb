require 'spec_helper'

describe Tracker::Project do

  let(:tracker_token) { double }
  let(:project_id) { double }
  let(:the_project) { double }
  let(:feature) { double }
  let(:bug) { double }

  describe "#initialize" do
    it "initializes the project class" do
      project = Tracker::Project.new(tracker_token, project_id)
      expect(project).to be
      expect(project.tracker_token).to eq(tracker_token)
      expect(project.project_id).to eq(project_id)
    end
  end

  describe "#finished" do

    let(:query) { double }

    before do
      expect(PivotalTracker::Project).to receive(:find).with(project_id) { the_project }
      expect(the_project).to receive(:stories) { query }
      expect(query).to receive(:all).with(state: "finished", story_type: ['bug', 'feature']) { [feature, bug] }
    end

    it "retrieves finished stories and bugs" do
      project = Tracker::Project.new(tracker_token, project_id)
      expect(project.finished).to eq([feature, bug])
    end
  end

  describe "#deliver" do
    let(:project) { Tracker::Project.new(double, double) }
    let(:story) { double }

    it "marks the story as delivered" do
      expect(story).to receive(:update).with(current_state: "delivered")
      project.deliver(story)
    end
  end

  describe "#add_label" do
    let(:project) { Tracker::Project.new(double, double) }
    let(:story) { double }

    context 'there is no label on the story' do
      it "adds a label" do
        expect(story).to receive(:labels) { '' }
        expect(story).to receive(:update).with(labels: 'label')
        project.add_label(story, 'label')
      end
    end

    context 'there is already one label on the story' do
      it "adds a label" do
        expect(story).to receive(:labels) { 'foo' }
        expect(story).to receive(:update).with(labels: 'foo,label')
        project.add_label(story, 'label')
      end
    end

    context 'there is already two labels on the story' do
      it "adds a label" do
        expect(story).to receive(:labels) { 'foo,bar' }
        expect(story).to receive(:update).with(labels: 'foo,bar,label')
        project.add_label(story, 'label')
      end
    end
  end

  describe "#comment" do
    let(:project) { Tracker::Project.new(double, double) }
    let(:story) { double }
    let(:notes_stub) { double }
    let(:server_name) {'spot instance' }

    before { allow(notes_stub).to receive(:create).with( hash_including(:text => "Delivered by script to #{server_name}")) }
    before { expect(story).to receive(:notes) { notes_stub } }

    it "comment story with server" do
      project.comment story, server_name
    end

  end

end
