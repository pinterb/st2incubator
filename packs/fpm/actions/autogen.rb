#!/usr/bin/env ruby
require 'yaml'
# Autogenerate Actions for ST2 and Freight

# Do not know how to model:
# * same parameter typed in multiple times
DEFAULT_DETAILS = {
  'runner_type' => 'run-remote',
  'enabled' => true,
  'entry_point' => '',
}

SOURCE_TYPES = ['dir', 'rpm', 'gem', 'python', 'empty', 'tar', 'deb']
OUTPUT_TYPES = ['deb', 'rpm']
DEFAULT_PARAMETERS = {
  'name' => {
    'type' => 'string',
    'description' => 'Package Name (e.g.: libpq)',
    'required' => true,
  },
  'description' => {
    'type' => 'string',
    'description' => 'Package Description (e.g.: Provides PostgreSQL Client libs)',
    'default' => 'Autobuilt package {{name}} by StackStorm + FPM Integration',
  },
  'source' => {
    'type' => 'string',
    'description' => 'Source type for fpm',
  },
  'version' => {
    'type' => 'string',
    'description' => 'Package Version (e.g.: 0.1.1)',
    'required' => true,
  },
  'revision' => {
    'type' => 'string',
    'description' => 'Package Revision (e.g: 2)',
    'default' => '1',
  },
  'input' => {
    'type' => 'string',
    'description' => "Inputs to the source package type. For the 'dir' type, this is the files and directories you want to include in the package. For others, like 'gem', it specifies the packages to download and use as the gem input",
    'required' => true,
  },
  'output' => {
    'type' => 'string',
    'description' => 'Package output type for fpm',
  },
  'prefix' => {
    'type' => 'string',
    'description' => 'A path to prefix files with when building the target package.',
    'default' => "/opt/{{name}}"
  },
  'after_install' => {
    'type' => 'string',
    'description' => 'A script to be run after package removal',
    'default' => '/bin/true',
  },
  'chdir' => {
    'type' => 'string',
    'description' => 'Change directory to here before searching for files',
    'default' => '{{dir}}',
  },
  'architecture' => {
    'type' => 'string',
    'description' => 'The architecture name. (usually matches `uname -a`). Use `all` for noarch',
    'default' => 'x86_64',
  },
  'maintainer' => {
    'type' => 'string',
    'description' => 'Maintainer of this package',
    'default' => 'root@product-flashflirt.stage.office.airg.lan',
  },
  'cmd' => {
    'default' => 'fpm -s {{source}} -t {{output}} -n {{name}} --version {{version}} --iteration {{revision}} --prefix {{prefix}} --after-install {{after_install}} -C {{chdir}} --maintainer {{maintainer}} --description "{{description}}" --architecture {{architecture}} {{input}}',
    'immutable' => true,
  },
}

SOURCE_TYPES.each do |source|
  OUTPUT_TYPES.each do |output|
    action_info = DEFAULT_DETAILS
    action_info['name'] = "create_#{output}_from_#{source}"
    action_info['description'] = "Create a #{output} package from #{source} with fpm"
    action_info['parameters'] = DEFAULT_PARAMETERS
    action_info['parameters']['source']['default'] = source
    action_info['parameters']['output']['default'] = output

    File.open("#{action_info['name']}.yaml", 'w') { |file| file.write(action_info.to_yaml) }
  end
end
