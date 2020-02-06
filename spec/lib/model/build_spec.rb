describe Build do
  before { DatabaseCleaner.clean_with :truncation }

  let(:repository) { FactoryGirl.create(:repository_without_last_build) }

  it 'caches matrix ids' do
    build = FactoryGirl.create(:build, config: { rvm: ['1.9.3', '2.0.0'] })
    build.cached_matrix_ids.should == build.matrix_ids
  end

  it 'returns nil if cached_matrix_ids are not set' do
    build = FactoryGirl.create(:build)
    build.update_column(:cached_matrix_ids, nil)
    build.reload.cached_matrix_ids.should be_nil
  end

  it 'is cancelable if at least one job is cancelable' do
    jobs = [FactoryGirl.build(:test), FactoryGirl.build(:test)]
    jobs.first.stubs(:cancelable?).returns(true)
    jobs.second.stubs(:cancelable?).returns(false)

    build = FactoryGirl.build(:build, matrix: jobs)
    build.should be_cancelable
  end

  it 'is not cancelable if none of the jobs are cancelable' do
    jobs = [FactoryGirl.build(:test), FactoryGirl.build(:test)]
    jobs.first.stubs(:cancelable?).returns(false)
    jobs.second.stubs(:cancelable?).returns(false)

    build = FactoryGirl.build(:build, matrix: jobs)
    build.should_not be_cancelable
  end

  describe '#secure_env_enabled?' do
    it 'returns true if we\'re not dealing with pull request' do
      build = FactoryGirl.build(:build)
      build.stubs(:pull_request?).returns(false)
      build.secure_env_enabled?.should be true
    end

    it 'returns true if pull request is from the same repository' do
      build = FactoryGirl.build(:build)
      build.stubs(:pull_request?).returns(true)
      build.stubs(:same_repo_pull_request?).returns(true)
      build.secure_env_enabled?.should be true
    end

    it 'returns false if pull request is not from the same repository' do
      build = FactoryGirl.build(:build)
      build.stubs(:pull_request?).returns(true)
      build.stubs(:same_repo_pull_request?).returns(false)
      build.secure_env_enabled?.should be false
    end
  end

  describe 'class methods' do
    describe 'recent' do
      it 'returns recent finished builds ordered by id descending' do
        FactoryGirl.create(:build, state: 'passed')
        FactoryGirl.create(:build, state: 'failed')
        FactoryGirl.create(:build, state: 'created')

        Build.recent.all.map(&:state).should == [:failed, :passed]
      end
    end

    describe 'was_started' do
      it 'returns builds that are either started or finished' do
        FactoryGirl.create(:build, state: 'passed')
        FactoryGirl.create(:build, state: 'started')
        FactoryGirl.create(:build, state: 'created')

        Build.was_started.map(&:state).sort.should == [:passed, :started]
      end
    end

    describe 'on_branch' do
      it 'returns builds that are on any of the given branches' do
        FactoryGirl.create(:build, commit: FactoryGirl.create(:commit, branch: 'master'))
        FactoryGirl.create(:build, commit: FactoryGirl.create(:commit, branch: 'develop'))
        FactoryGirl.create(:build, commit: FactoryGirl.create(:commit, branch: 'feature'))

        Build.on_branch('master,develop').map(&:commit).map(&:branch).sort.should == ['develop', 'master']
      end

      it 'does not include pull requests' do
        FactoryGirl.create(:build, commit: FactoryGirl.create(:commit, branch: 'no-pull'), request: FactoryGirl.create(:request, event_type: 'pull_request'))
        FactoryGirl.create(:build, commit: FactoryGirl.create(:commit, branch: 'no-pull'), request: FactoryGirl.create(:request, event_type: 'push'))
        Build.on_branch('no-pull').count.should be == 1
      end
    end

    describe 'older_than' do
      before do
        5.times { |i| FactoryGirl.create(:build, number: i) }
        Build.stubs(:per_page).returns(2)
      end

      context "when a Build is passed in" do
        subject { Build.older_than(Build.new(number: 3)) }

        it "should limit the results" do
          expect(subject.size).to eq(2)
        end

        it "should return older than the passed build" do
          subject.map(&:number).should == ['2', '1']
        end
      end

      context "when a number is passed in" do
        subject { Build.older_than(3) }

        it "should limit the results" do
          expect(subject.size).to eq(2)
        end

        it "should return older than the passed build" do
          subject.map(&:number).should == ['2', '1']
        end
      end

      context "when not passing a build" do
        subject { Build.older_than() }

        it "should limit the results" do
          expect(subject.size).to eq(2)
        end
      end
    end

    describe 'paged' do
      it 'limits the results to the `per_page` value' do
        3.times { FactoryGirl.create(:build) }
        Build.stubs(:per_page).returns(1)

        expect(Build.descending.paged({}).size).to eq(1)
      end

      it 'uses an offset' do
        3.times { |i| FactoryGirl.create(:build) }
        Build.stubs(:per_page).returns(1)

        builds = Build.descending.paged({page: 2})
        expect(builds.size).to eq(1)
        builds.first.number.should == '2'
      end
    end

    describe 'pushes' do
      before do
        FactoryGirl.create(:build)
        FactoryGirl.create(:build, request: FactoryGirl.create(:request, event_type: 'pull_request'))
      end

      it "returns only builds which have Requests with an event_type of push" do
        Build.pushes.all.count.should == 1
      end
    end

    describe 'pull_requests' do
      before do
        FactoryGirl.create(:build)
        FactoryGirl.create(:build, request: FactoryGirl.create(:request, event_type: 'pull_request'))
      end

      it "returns only builds which have Requests with an event_type of pull_request" do
        Build.pull_requests.all.count.should == 1
      end
    end
  end

  describe 'creation' do
    describe 'previous_state' do
      it 'is set to the last finished build state on the same branch' do
        FactoryGirl.create(:build, state: 'failed')
        FactoryGirl.create(:build).reload.previous_state.should == 'failed'
      end

      it 'is set to the last finished build state on the same branch (disregards non-finished builds)' do
        FactoryGirl.create(:build, state: 'failed')
        FactoryGirl.create(:build, state: 'started')
        FactoryGirl.create(:build).reload.previous_state.should == 'failed'
      end

      it 'is set to the last finished build state on the same branch (disregards other branches)' do
        FactoryGirl.create(:build, state: 'failed')
        FactoryGirl.create(:build, state: 'passed', commit: FactoryGirl.create(:commit, branch: 'something'))
        FactoryGirl.create(:build).reload.previous_state.should == 'failed'
      end
    end

    it "updates the last_build on the build's branch" do
      build = FactoryGirl.create(:build)
      branch = Branch.where(repository_id: build.repository_id, name: build.branch).first
      branch.last_build.should == build
    end
  end

  describe 'instance methods' do
    it 'sets its number to the next build number on creation' do
      1.upto(3) do |number|
        FactoryGirl.create(:build).reload.number.should == number.to_s
      end
    end

    it 'sets previous_state to nil if no last build exists on the same branch' do
      build = FactoryGirl.create(:build, commit: FactoryGirl.create(:commit, branch: 'master'))
      build.reload.previous_state.should == nil
    end

    it 'sets previous_state to the result of the last build on the same branch if exists' do
      build = FactoryGirl.create(:build, state: :canceled, commit: FactoryGirl.create(:commit, branch: 'master'))
      build = FactoryGirl.create(:build, commit: FactoryGirl.create(:commit, branch: 'master'))
      build.reload.previous_state.should == 'canceled'
    end

    describe 'config' do
      it 'defaults to a hash with language and os set' do
        build = Build.new(repository: Repository.new(owner: User.new))
        build.config.should == { language: 'ruby', group: 'stable', dist: 'precise', os: 'linux' }
      end

      it 'deep_symbolizes keys on write' do
        build = FactoryGirl.create(:build, config: { 'foo' => { 'bar' => 'bar' } })
        build.config[:foo].should == { bar: 'bar' }
      end

      it 'downcases the language on config' do
        build = FactoryGirl.create(:build, config: { language: "PYTHON" })
        Build.last.config[:language].should == "python"
      end

      it 'sets ruby as default language' do
        build = FactoryGirl.create(:build, config: { 'foo' => { 'bar' => 'bar' } })
        Build.last.config[:language].should == "ruby"
      end
    end

    describe :pending? do
      it 'returns true if the build is finished' do
        build = FactoryGirl.create(:build, state: :finished)
        build.pending?.should be false
      end

      it 'returns true if the build is not finished' do
        build = FactoryGirl.create(:build, state: :started)
        build.pending?.should be true
      end
    end

    describe :passed? do
      it 'passed? returns true if state equals :passed' do
        build = FactoryGirl.create(:build, state: :passed)
        build.passed?.should be true
      end

      it 'passed? returns true if result does not equal :passed' do
        build = FactoryGirl.create(:build, state: :failed)
        build.passed?.should be false
      end
    end

    describe :color do
      it 'returns "green" if the build has passed' do
        build = FactoryGirl.create(:build, state: :passed)
        build.color.should == 'green'
      end

      it 'returns "red" if the build has failed' do
        build = FactoryGirl.create(:build, state: :failed)
        build.color.should == 'red'
      end

      it 'returns "yellow" if the build is pending' do
        build = FactoryGirl.create(:build, state: :started)
        build.color.should == 'yellow'
      end
    end

    it 'saves event_type before create' do
      build = FactoryGirl.create(:build,  request: FactoryGirl.create(:request, event_type: 'pull_request'))
      build.event_type.should == 'pull_request'

      build = FactoryGirl.create(:build,  request: FactoryGirl.create(:request, event_type: 'push'))
      build.event_type.should == 'push'
    end

    it 'saves branch before create' do
      build = FactoryGirl.create(:build,  commit: FactoryGirl.create(:commit, branch: 'development'))
      build.branch.should == 'development'
    end

    describe 'reset' do
      let(:build) { FactoryGirl.create(:build, state: 'finished') }

      before :each do
        build.matrix.each { |job| job.stubs(:reset) }
      end

      it 'sets the state to :created' do
        build.reset
        build.state.should == :created
      end

      it 'resets related attributes' do
        build.reset
        build.duration.should be_nil
        build.finished_at.should be_nil
      end

      it 'resets each job if :reset_matrix is given' do
        build.matrix.each { |job| job.expects(:reset) }
        build.reset(reset_matrix: true)
      end

      it 'does not reset jobs if :reset_matrix is not given' do
        build.matrix.each { |job| job.expects(:reset).never }
        build.reset
      end
    end
  end
end
