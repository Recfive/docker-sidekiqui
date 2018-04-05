sha = `git rev-parse --short HEAD`.chomp
image_name = "r5/sidekiqui:#{sha}"

task :default => :test

desc "Run tests"
task :test => [:build_image] do
  system "docker run -it --env-file .env #{image_name} bundle exec ruby sidekiqui_test.rb"
end

desc "Launch a shell"
task :shell => [:build_image] do
  system "docker run -it --env-file .env #{image_name} bash"
end

desc "Run bundler"
task :bundle => [:build_image] do
  system "docker run -t -v $(pwd)/Gemfile:/app/Gemfile -v $(pwd)/Gemfile.lock:/app/Gemfile.lock #{image_name} bundle update"
end

desc "Build Docker image"
task :build_image do
  system "docker build -t #{image_name} ."
end

desc "Push Docker image to repo"
task :push_image do
  tag = "quay.io/recfive/sidekiqui:#{sha}"
  system "docker tag #{image_name} #{tag}"
  system "docker push #{tag}"
end
