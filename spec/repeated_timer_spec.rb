require_relative "spec_helper"

RSpec.describe Evervault do

    describe "RepeatableTimer" do

        describe "initialize" do
            it "should start the timer and invoke the function at regular interval" do
                counter = 0
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { counter += 1 })
                expect(timer.running?).to be(true)
                sleep 0.25
                expect(counter).to be(2)
                timer.stop
            end

            it "should silently ignore exceptions thrown by the invoked function" do
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { raise "error" })
                expect(timer.running?).to be(true)
                sleep 0.15
                timer.stop
            end
        end

        describe "start" do
            it "should start a repeated timer if the timer is not already running" do
                counter = 0
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { counter += 1 })
                timer.stop
                timer.start
                expect(timer.running?).to be(true)
                sleep 0.25
                expect(counter).to be(2)
                timer.stop
            end

            it "should not start a repeated timer if the timer is already running" do
                counter = 0
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { counter += 1 })
                timer.start
                expect(timer.running?).to be(true)
                sleep 0.25
                expect(counter).to be(2)
                timer.stop
            end
        end

        describe "running?" do
            it "should return true if the timer is running" do
                counter = 0
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { counter += 1 })
                expect(timer.running?).to be(true)
                timer.stop
            end

            it "should return false if the timer is not running" do
                counter = 0
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { counter += 1 })
                timer.stop
                expect(timer.running?).to be(false)
            end
        end

        describe "update_interval" do
            it "should update the interval of the timer" do
                counter = 0
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { counter += 1 })
                sleep 0.22
                expect(counter).to be(2)
                timer.update_interval(0.2)
                expect(timer.running?).to be(true)
                sleep 0.32
                expect(counter).to be(4)
            end
        end

        describe "stop" do
            it "should stop the timer" do
                counter = 0
                timer = Evervault::Threading::RepeatedTimer.new(0.1, -> { counter += 1 })
                sleep 0.25
                timer.stop
                expect(timer.running?).to be(false)
                sleep 0.25
                expect(counter).to be(2)
            end
        end

    end

end