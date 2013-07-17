#
# Cookbook Name:: erlang
# Recipe:: default
#
# Copyright 2013, Krzysztof Rutka
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when 'centos'
  pkg_deps = %w{gcc make ncurses-devel openssl-devel}
when 'ubuntu'
  pkg_deps = %w{gcc make libssl-dev ncurses-dev}
end

pkg_deps.each do |p|
  package p do
    action :upgrade
  end
end

release = node['erlang']['release'].upcase
otp_src = "otp_src_#{release}.tar.gz"
otp_dir = "#{Chef::Config[:file_cache_path]}/#{otp_src.chomp('.tar.gz')}"
otp_src = 'otp_src_R15B03-1.tar.gz' if release == 'R15B03'

remote_file "#{Chef::Config[:file_cache_path]}/#{otp_src}" do
  source "#{node['erlang']['source_url']}#{otp_src}"
  action :create_if_missing
end

execute 'extract sources' do
  command "tar xfz #{otp_src}"
  cwd Chef::Config[:file_cache_path]
  creates otp_dir
end

prefix = node['erlang']['prefix']
flags = node['erlang']['flags'].join(' ')
release_file = File.join(prefix, '/lib/erlang/releases/RELEASES')

execute 'configure, build and install' do
  command "./configure --prefix=#{prefix} #{flags} && make install"
  cwd otp_dir
  only_if do
    if File.exists?(release_file)
      File.readlines(release_file).grep(/"#{release}"/).empty?
    else
      true
    end
  end
end

files = %w{erl erlc epmd run_erl to_erl dialyzer typer escript ct_run run_test}

if node['erlang']['link']
  files.each do |f|
    link File.join(node['erlang']['link_to'], f) do
      to File.join(prefix, '/lib/erlang/bin', f)
    end
  end
end
